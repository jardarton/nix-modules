# End-to-end test against a local ntfy server. The test driver plays the phone:
# it reads requests with the phone user's credentials and replays the
# notification's own Approve or Deny action.
{ self }:
{ pkgs, ... }:
let
  # Test-only credentials; these bcrypt hashes are for phone-test-password and
  # unused-test-password.
  phoneHash = "$2a$10$qHOfQwSTxxl33gWOAwLB5OArmmjat82RsXA/7l3PuYbCNbYngxFj.";
  unusedHash = "$2a$10$XrwOXaLa3Zu2p0HYhDIxNuoC5DAguHmOOoRW84enpqK.MAwS2gk8G";
  hostToken = "tk_hosttoken00000000000000000000";
  replyToken = "tk_replytoken0000000000000000000";
in
{
  name = "sudo-approval";

  nodes.machine = {
    imports = [ self.nixosModules.sudo-approval ];

    services.ntfy-sh = {
      enable = true;
      settings = {
        base-url = "http://localhost:2586";
        listen-http = ":2586";
        auth-file = "/var/lib/ntfy-sh/user.db";
        auth-default-access = "deny-all";
        auth-users = [
          "phone:${phoneHash}:user"
          "sudo-host:${unusedHash}:user"
          "sudo-reply:${unusedHash}:user"
        ];
        auth-tokens = [
          "sudo-host:${hostToken}"
          "sudo-reply:${replyToken}"
        ];
        auth-access = [
          "phone:sudo-approval:read-only"
          "sudo-host:sudo-approval:write-only"
          "sudo-host:sudo-approval-reply:read-only"
          "sudo-reply:sudo-approval-reply:write-only"
        ];
      };
    };

    environment.etc = {
      "sudo-approval/host-token" = {
        text = hostToken;
        mode = "0400";
      };
      "sudo-approval/reply-token" = {
        text = replyToken;
        mode = "0400";
      };
    };

    modules.nixos.sudo-approval = {
      enable = true;
      timeout = 15;
      ntfy = {
        url = "http://localhost:2586";
        hostTokenFile = "/etc/sudo-approval/host-token";
        replyTokenFile = "/etc/sudo-approval/reply-token";
      };
    };

    users.users.alice = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      password = "alice-password";
    };

    environment.systemPackages = [ pkgs.curl ];
  };

  testScript = ''
    import json
    import shlex

    machine.wait_for_unit("ntfy-sh.service")
    machine.wait_for_open_port(2586)
    machine.wait_for_unit("multi-user.target")
    # Mimic an agent binary by name, the way process-tree detection sees it.
    machine.succeed("ln -s ${pkgs.bash}/bin/bash /tmp/claude")

    phone = "-u phone:phone-test-password"

    def requests():
        out = machine.succeed(f"curl -sf {phone} 'http://localhost:2586/sudo-approval/json?poll=1'")
        return [json.loads(line) for line in out.splitlines() if line.strip()]

    def run_as_alice(name, script):
        machine.succeed(f"rm -f /tmp/{name}.status")
        wrapped = f"{script}; echo $? > /tmp/{name}.status"
        # Append mode, so sudo and the helper do not overwrite each other.
        machine.succeed(f"su - alice -c {shlex.quote(wrapped)} >>/tmp/{name}.log 2>&1 &")

    def status(name):
        machine.wait_until_succeeds(f"test -s /tmp/{name}.status", timeout=60)
        return int(machine.succeed(f"cat /tmp/{name}.status").strip())

    def next_request(seen):
        machine.wait_until_succeeds(
            f"test $(curl -sf {phone} 'http://localhost:2586/sudo-approval/json?poll=1' | wc -l) -gt {seen}",
            timeout=30,
        )
        return requests()[-1]

    def tap(request, label):
        action = next(a for a in request["actions"] if a["label"] == label)
        headers = " ".join(f"-H {shlex.quote(k + ': ' + v)}" for k, v in action["headers"].items())
        machine.succeed(
            f"curl -sf -X {action['method']} {headers} -d {shlex.quote(action['body'])} {shlex.quote(action['url'])}"
        )

    with subtest("approved agent call runs without a password"):
        seen = len(requests())
        run_as_alice("approve", "CLAUDECODE=1 sudo -n true")
        request = next_request(seen)
        assert request["message"].startswith("sudo -n true"), request
        tap(request, "Approve")
        assert status("approve") == 0
        machine.succeed("grep -q approved /tmp/approve.log")

    with subtest("denied agent call fails, detected through process ancestry"):
        seen = len(requests())
        run_as_alice("deny", "/tmp/claude -c 'sudo true; exit $?'")
        tap(next_request(seen), "Deny")
        assert status("deny") != 0

    with subtest("unanswered agent call times out"):
        seen = len(requests())
        run_as_alice("timeout", "CLAUDECODE=1 sudo -n true")
        next_request(seen)
        assert status("timeout") != 0
        machine.succeed("grep -q 'timed out' /tmp/timeout.log")

    with subtest("cached timestamp still requires approval"):
        seen = len(requests())
        run_as_alice("cached", "echo alice-password | sudo -S -v && CLAUDECODE=1 sudo -n true")
        request = next_request(seen)
        tap(request, "Approve")
        assert status("cached") == 0

    with subtest("humans keep password authentication without approval"):
        seen = len(requests())
        run_as_alice("human", "echo alice-password | sudo -S true")
        assert status("human") == 0
        run_as_alice("wrong", "echo wrong-password | sudo -S true")
        assert status("wrong") != 0
        run_as_alice("nopass", "sudo -n true")
        assert status("nopass") != 0
        assert len(requests()) == seen

    machine.succeed("journalctl -t sudo-approval | grep -q 'approve for'")
  '';
}
