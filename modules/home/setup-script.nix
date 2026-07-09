{ localFlake }:
{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  cfg = config.modules.home.setup-script;
in
{
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
      description = "NixOS sops-nix secret name containing the script body.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellScriptBin cfg.commandName ''
        export PATH=${
          lib.makeBinPath [
            pkgs.gh
            pkgs.git
          ]
        }:$PATH
        exec ${pkgs.bash}/bin/bash ${osConfig.sops.secrets.${cfg.secretName}.path} "$@"
      '')
    ];
  };
}
