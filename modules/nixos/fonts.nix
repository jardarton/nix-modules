_:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.nixos.fonts;
in
{
  options.modules.nixos.fonts = with lib; {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable fonts ";
    };
  };

  config = lib.mkIf cfg.enable {
    # all fonts are linked to /nix/var/nix/profiles/system/sw/share/X11/fonts
    fonts = {
      enableDefaultPackages = false;
      fontDir.enable = true;

      packages = with pkgs; [
        # icon fonts
        material-design-icons
        material-symbols

        noto-fonts-color-emoji # 彩色的表情符号字体
        nerd-fonts.symbols-only # symbols icon only
        nerd-fonts.monaspace
        monaspace
      ];
    };
  };
}
