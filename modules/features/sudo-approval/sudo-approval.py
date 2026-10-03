"""PAM helper that gates sudo calls from coding agents behind ntfy approval.

pam_exec runs this once per PAM phase with PAM_TYPE set. The parent process
is sudo, whose environment and ancestry decide whether an agent is calling.

auth:    exit 0 for agents so they skip the password, otherwise exit 1 so the
         stack falls through to the regular password modules.
account: sudo runs this phase on every invocation, including cached
         timestamps. Agents must be approved from the phone; everyone else
         passes through.
"""

import json
import os
import secrets
import shlex
import sys
import syslog
import time
import urllib.request

ALLOW, DENY = 0, 1


def log(priority, message):
    syslog.syslog(priority, message)


def read_proc(pid, name):
    with open(f"/proc/{pid}/{name}", "rb") as f:
        return f.read()


def normalize(name):
    # Nix wrappers rename executables to .<name>-wrapped.
    name = os.path.basename(name).lstrip(".")
    return name[: -len("-wrapped")] if name.endswith("-wrapped") else name


def process_names(pid):
    names = set()
    try:
        names.add(normalize(read_proc(pid, "comm").decode(errors="replace").strip()))
    except OSError:
        pass
    try:
        names.add(normalize(os.readlink(f"/proc/{pid}/exe")))
    except OSError:
        pass
    try:
        argv0 = read_proc(pid, "cmdline").split(b"\0", 1)[0]
        names.add(normalize(argv0.decode(errors="replace")))
    except OSError:
        pass
    names.discard("")
    return names


def parent_pid(pid):
    stat = read_proc(pid, "stat").decode(errors="replace")
    # comm may contain spaces or parentheses, so split after the last ')'.
    return int(stat.rsplit(")", 1)[1].split()[1])


def detect_agent(config, sudo_pid):
    """Return a label for the agent that invoked sudo, or None."""
    try:
        environ = read_proc(sudo_pid, "environ").split(b"\0")
        keys = {entry.split(b"=", 1)[0].decode(errors="replace") for entry in environ}
        for variable in config["environmentVariables"]:
            if variable in keys:
                return f"${variable}"
    except OSError:
        pass

    wanted = {normalize(name) for name in config["processNames"]}
    pid = parent_pid(sudo_pid)
    seen = set()
    while pid > 1 and pid not in seen:
        seen.add(pid)
        matched = process_names(pid) & wanted
        if matched:
            return sorted(matched)[0]
        try:
            pid = parent_pid(pid)
        except (OSError, ValueError, IndexError):
            break
    return None


def describe(sudo_pid):
    try:
        argv = [a.decode(errors="replace") for a in read_proc(sudo_pid, "cmdline").split(b"\0") if a]
        # The setuid wrapper runs sudo by its store path, which is just noise.
        command = shlex.join([os.path.basename(argv[0]), *argv[1:]])
    except OSError:
        command = "sudo (command unavailable)"
    try:
        cwd = os.readlink(f"/proc/{sudo_pid}/cwd")
    except OSError:
        cwd = "?"
    if len(command) > 1500:
        command = command[:1500] + " …"
    return command, cwd


def tell_caller(sudo_pid, message):
    # Agents usually run without a terminal, so write straight to sudo's stderr.
    try:
        with open(f"/proc/{sudo_pid}/fd/2", "a") as f:
            f.write(f"sudo-approval: {message}\n")
    except OSError:
        pass


def read_token(path):
    with open(path) as f:
        return f.read().strip()


def request(url, token, data=None):
    req = urllib.request.Request(url, data=data, headers={"Authorization": f"Bearer {token}"})
    with urllib.request.urlopen(req, timeout=10) as response:
        return response.read()


def ask_phone(config, agent, command, cwd):
    base = config["url"].rstrip("/")
    host_token = read_token(config["hostTokenFile"])
    reply_token = read_token(config["replyTokenFile"])
    nonce = secrets.token_hex(16)
    reply_url = f"{base}/{config['replyTopic']}"
    user = os.environ.get("PAM_RUSER") or os.environ.get("PAM_USER") or "?"

    def action(label, decision):
        return {
            "action": "http",
            "label": label,
            "url": reply_url,
            "method": "POST",
            "headers": {"Authorization": f"Bearer {reply_token}"},
            "body": json.dumps({"id": nonce, "decision": decision}),
            "clear": True,
        }

    since = int(time.time()) - 1
    request(base, host_token, json.dumps({
        "topic": config["requestTopic"],
        "title": f"sudo on {config['hostname']} ({agent})",
        "message": f"{command}\n\nuser: {user}\ncwd: {cwd}",
        "priority": config["priority"],
        "tags": ["lock"],
        "actions": [action("Approve", "approve"), action("Deny", "deny")],
    }).encode())

    return wait_for_reply(f"{reply_url}/json?since={since}", host_token, nonce, config["timeout"])


def wait_for_reply(url, token, nonce, timeout):
    # Stream instead of polling: ntfy rate-limits requests per client IP, and
    # proxies can put every host and the phone behind a single address.
    deadline = time.monotonic() + timeout
    while (remaining := deadline - time.monotonic()) > 0:
        req = urllib.request.Request(url, headers={"Authorization": f"Bearer {token}"})
        try:
            # The read timeout bounds how far a quiet stream can overrun the
            # deadline; reconnecting replays replies since the request.
            with urllib.request.urlopen(req, timeout=min(remaining, 15)) as response:
                for line in response:
                    decision = parse_reply(line, nonce)
                    if decision:
                        return decision
                    if time.monotonic() >= deadline:
                        break
        except TimeoutError:
            continue
        except OSError as error:
            log(syslog.LOG_WARNING, f"waiting for replies failed: {error}")
            time.sleep(min(5, max(0, deadline - time.monotonic())))
    return "timeout"


def parse_reply(line, nonce):
    try:
        event = json.loads(line)
        if event.get("event") != "message":
            return None
        reply = json.loads(event.get("message", ""))
    except (ValueError, AttributeError):
        return None
    if isinstance(reply, dict) and reply.get("id") == nonce:
        return reply.get("decision")
    return None


def main():
    with open(sys.argv[1]) as f:
        config = json.load(f)
    syslog.openlog("sudo-approval", 0, syslog.LOG_AUTHPRIV)
    phase = os.environ.get("PAM_TYPE")
    sudo_pid = os.getppid()

    try:
        agent = detect_agent(config, sudo_pid)
    except Exception as error:  # noqa: BLE001
        # Never lock humans out because process inspection failed.
        log(syslog.LOG_ERR, f"agent detection failed: {error!r}")
        agent = None

    if phase == "auth":
        return ALLOW if agent else DENY
    if phase != "account" or agent is None:
        return ALLOW

    command, cwd = describe(sudo_pid)
    tell_caller(sudo_pid, f"waiting up to {config['timeout']}s for phone approval")
    try:
        decision = ask_phone(config, agent, command, cwd)
    except Exception as error:  # noqa: BLE001
        log(syslog.LOG_ERR, f"approval request failed for {agent}: {command}: {error!r}")
        tell_caller(sudo_pid, "approval request failed, denying")
        return DENY

    approved = decision == "approve"
    log(syslog.LOG_NOTICE, f"{decision} for {agent} (cwd {cwd}): {command}")
    outcome = {"approve": "approved", "deny": "denied from phone", "timeout": "timed out, denied"}
    tell_caller(sudo_pid, outcome.get(decision, f"unexpected reply {decision!r}, denied"))
    return ALLOW if approved else DENY


if __name__ == "__main__":
    sys.exit(main())
