{ localFlake }:
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.nixos.setup-script;
in
{
  imports = [
    localFlake.inputs.sops-nix.nixosModules.sops
  ];

  options.modules.nixos.setup-script = {
    enable = lib.mkEnableOption "sops-managed setup script secret";

    secretName = lib.mkOption {
      type = lib.types.str;
      default = "setup-script";
      description = "sops-nix secret name containing the setup script body.";
    };

    sopsFile = lib.mkOption {
      type = lib.types.path;
      default = ../../secrets/setup-script.sops.yaml;
      description = "SOPS-encrypted YAML file containing the script secret.";
    };

    owner = lib.mkOption {
      type = lib.types.str;
      default = config.myvars.username or "root";
      description = "User allowed to execute the decrypted setup script.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "users";
      description = "Group for the decrypted setup script.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.${cfg.secretName} = {
      inherit (cfg) sopsFile owner group;
      mode = "0400";
    };
  };
}
