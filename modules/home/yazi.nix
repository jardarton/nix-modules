_:
{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.home.yazi;
in
{

  options.modules.home.yazi = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = true;
      description = "enable yazi";
    };
  };

  config = mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "y";
      settings = {
        mgr = {
          show_hidden = false;
          sort_by = "mtime";
          sort_dir_first = true;
        };
        previewers = [
          {
            name = "*/";
            run = "folder";
            sync = true;
          }
          {
            mime = "text/*";
            run = "bat";
          }
          {
            mime = "*/xml";
            run = "bat";
          }
          {
            mime = "*/cs";
            run = "bat";
          }
          {
            mime = "*/javascript";
            run = "bat";
          }
          {
            mime = "*/x-wine-extension-ini";
            run = "bat";
          }
        ];
        opener = {
          pdff = [
            {
              run = ''zathura "$@"'';
              desc = "zathura";
              block = true;
              for = "unix";
            }
          ];
          play = [
            {
              run = ''mpv "$@"'';
              orphan = true;
              for = "unix";
            }
          ];
          open = [
            {
              run = ''xdg-open "$@"'';
              desc = "Open";
            }
          ];
          edit = [
            {
              run = ''$EDITOR "$@"'';
              block = true;
              for = "unix";
            }
          ];

        };

        open = {
          prepend_rules = [
            {
              url = "*.json";
              use = "edit";
            }
            {
              url = "*.html";
              use = [
                "open"
                "edit"
              ];
            }
            {
              url = "*.pdf";
              use = [
                "pdff"
                "open"
              ];
            }
          ];

        };
      };
    };
    home.shellAliases = {
      y = "yazi";
    };
  };
}
