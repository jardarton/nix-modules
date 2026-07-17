{ ... }:
{ config
, lib
, ...
}:
with lib;
let
  cfg = config.modules.nixos.keyd;
in
{
  options.modules.nixos.keyd = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "enable keyd macos copy paste";
    };
  };

  imports = [
  ];

  config = mkIf cfg.enable {
    services.keyd = {
      enable = true;
      keyboards = {
        default = {
          ids = [ "*" ];
          settings = {
            #macos style keybinds
            meta = {
              x = "C-x";
              c = "C-c";
              v = "C-S-v";
              a = "C-a";
              f = "C-f";
              r = "C-r";
              z = "C-z";
            };
          };
        };
      };
    };
  };
}
