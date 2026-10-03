{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.nixos.sudo-approval;
  pam = config.security.pam.services.sudo.rules;

  helper = pkgs.writers.writePython3 "sudo-approval" {
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ./sudo-approval.py);

  # Only token paths are recorded here; the tokens stay in their files.
  helperConfig = pkgs.writeText "sudo-approval.json" (
    builtins.toJSON {
      inherit (cfg) timeout priority;
      inherit (cfg.agents) processNames environmentVariables;
      inherit (cfg.ntfy)
        url
        requestTopic
        replyTopic
        hostTokenFile
        replyTokenFile
        ;
      hostname = config.networking.hostName;
    }
  );

  # seteuid keeps the helper out of reach of the invoking user, who could
  # otherwise ptrace it and read the ntfy tokens.
  pamExecArgs = [
    "quiet"
    "seteuid"
    "${helper}"
    "${helperConfig}"
  ];
in
{
  options.modules.nixos.sudo-approval = {
    enable = lib.mkEnableOption ''
      phone approval through ntfy for sudo calls made by coding agents.
      Agents skip the password but every sudo invocation, including one with a
      cached timestamp, waits for an Approve or Deny tap. Other callers keep
      regular password authentication. Detection relies on the caller's
      environment and process ancestry, so it protects against accidents rather
      than an agent that deliberately hides its origin
    '';

    timeout = lib.mkOption {
      type = lib.types.ints.positive;
      default = 120;
      description = "Seconds to wait for a decision before denying.";
    };

    priority = lib.mkOption {
      type = lib.types.ints.between 1 5;
      default = 4;
      description = "ntfy priority of approval requests.";
    };

    noninteractiveAuth = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether `sudo -n` still runs PAM authentication. Agents commonly pass
        `-n`; password prompts still fail under it, so humans are unaffected.
      '';
    };

    ntfy = {
      url = lib.mkOption {
        type = lib.types.str;
        example = "https://ntfy.example.com";
        description = "Base URL of the ntfy server, without a topic.";
      };

      requestTopic = lib.mkOption {
        type = lib.types.str;
        default = "sudo-approval";
        description = ''
          Topic that receives approval requests. Only the approving device
          should be able to read it, because requests embed the reply token.
        '';
      };

      replyTopic = lib.mkOption {
        type = lib.types.str;
        default = "sudo-approval-reply";
        description = "Topic that receives Approve and Deny replies.";
      };

      hostTokenFile = lib.mkOption {
        type = lib.types.path;
        description = ''
          Root-readable file with an ntfy access token that may write the
          request topic and read the reply topic.
        '';
      };

      replyTokenFile = lib.mkOption {
        type = lib.types.path;
        description = ''
          Root-readable file with an ntfy access token that may only write the
          reply topic. It is embedded in the notification's action buttons.
        '';
      };
    };

    agents = {
      processNames = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "claude"
          "codex"
          "opencode"
          "pi"
        ];
        description = ''
          Process names that mark an agent when found among the ancestors of
          sudo. Names are compared after removing Nix `.<name>-wrapped`
          decoration from comm, executable, and argv[0].
        '';
      };

      environmentVariables = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "CLAUDECODE"
          "PI_CODING_AGENT_DIR"
        ];
        description = "Environment variables whose presence in sudo's environment marks an agent.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.security.sudo.enable;
        message = "modules.nixos.sudo-approval requires security.sudo.enable";
      }
    ];

    security.sudo.extraConfig = lib.mkIf cfg.noninteractiveAuth "Defaults noninteractive_auth";

    security.pam.services.sudo.rules = {
      # Lets agents skip the password; on any other result the regular stack runs.
      auth.sudo-approval = {
        order = pam.auth.unix.order - 10;
        control = "[success=done default=ignore]";
        modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
        args = pamExecArgs;
      };
      # sudo calls account management on every invocation, after any cached
      # timestamp check, so this is where agent calls are approved.
      account.sudo-approval = {
        order = pam.account.unix.order + 10;
        control = "required";
        modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
        args = pamExecArgs;
      };
    };
  };
}
