{ localFlake }:
{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.modules.home.setup-script;
in
{
  imports = [
    localFlake.inputs.sops-nix.homeManagerModules.sops
  ];

  options.modules.home.setup-script = {
    enable = lib.mkEnableOption "sops-managed setup script";

    commandName = lib.mkOption {
      type = lib.types.str;
      default = "setup-script";
      description = "Command installed into the user profile that executes the decrypted script.";
    };

    secretName = lib.mkOption {
      type = lib.types.str;
      default = "setup-script";
      description = "sops-nix secret name containing the script body.";
    };

    sopsFile = lib.mkOption {
      type = lib.types.path;
      default = ../../secrets/setup-script.sops.yaml;
      description = "SOPS-encrypted YAML file containing the script secret.";
    };

    ageKeyFile = lib.mkOption {
      type = lib.types.path;
      default = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      description = "age identity file used by Home Manager sops-nix.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops = {
      age.keyFile = cfg.ageKeyFile;
      secrets.${cfg.secretName} = {
        inherit (cfg) sopsFile;
        mode = "0500";
      };
    };

    home.packages = [
      (pkgs.writeShellScriptBin cfg.commandName ''
        export PATH=${lib.makeBinPath [ pkgs.gh pkgs.git ]}:$PATH
        exec ${config.sops.secrets.${cfg.secretName}.path} "$@"
      '')
    ];
  };
}
