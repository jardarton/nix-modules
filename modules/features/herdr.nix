{
  config,
  inputs,
  self,
  moduleWithSystem,
  ...
}:
let
  moduleFlake = config.nixModules.sourceFlake;
in
{
  flake.modules.homeManager.herdr = moduleWithSystem (
    { config, ... }:
    { lib, pkgs, ... }:
    {
      imports = [ ./herdr/home.nix ];

      modules.home.herdr = {
        enable = lib.mkDefault true;
        package =
          lib.mkDefault
            moduleFlake.inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default;
        plugins.jjWorkspace.package = lib.mkDefault config.packages.herdr-plugin-jj-workspace;
        plugins.worktrunk.package = lib.mkDefault config.packages.herdr-plugin-worktrunk;
        plugins.nvim.package = lib.mkDefault config.packages.herdr-plugin-nvim;
        plugins.navigator.package = lib.mkDefault config.packages.herdr-plugin-navigator;
        plugins.annotate.package = lib.mkDefault config.packages.herdr-plugin-annotate;
      };
    }
  );

  perSystem =
    { pkgs, ... }:
    let
      mkHome =
        settings:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            self.homeModules.herdr
            self.homeModules.git
            {
              home.username = "herdr-test";
              home.homeDirectory =
                if pkgs.stdenv.hostPlatform.isDarwin then "/Users/herdr-test" else "/home/herdr-test";
              home.stateVersion = "26.05";
              modules.home.git.worktrunk.enable = true;
              modules.home.herdr = settings;
            }
          ];
        };
      disabled = mkHome { plugins.jjWorkspace.enable = false; };
      combined = mkHome {
        plugins.jjWorkspace.enable = true;
        plugins.worktrunk.enable = true;
        plugins.nvim.enable = true;
        plugins.navigator.enable = true;
        plugins.annotate.enable = true;
      };
      navigatorEnabled = mkHome {
        plugins.jjWorkspace.enable = false;
        plugins.navigator = {
          enable = true;
          settings.picker.vim_mode = true;
        };
      };
      navigatorPackage = self.packages.${pkgs.stdenv.hostPlatform.system}.herdr-plugin-navigator;
      navigatorOverride = navigatorPackage.overrideAttrs (_: {
        pname = "herdr-navigator-override";
      });
      navigatorNoKeys = mkHome {
        plugins.jjWorkspace.enable = false;
        plugins.navigator = {
          enable = true;
          package = navigatorOverride;
          keybinds.enable = false;
          settings.picker.check_updates = true;
        };
      };
      nvimEnabled = mkHome {
        plugins.jjWorkspace.enable = false;
        plugins.nvim = {
          enable = true;
          settings.sidebar.position = "left";
          keybinds.pickFile = "prefix+f";
        };
      };
      nvimNoKeys = mkHome {
        plugins.jjWorkspace.enable = false;
        plugins.nvim.enable = true;
        plugins.nvim.keybinds.enable = false;
      };
      annotateEnabled = mkHome {
        plugins.jjWorkspace.enable = false;
        plugins.annotate = {
          enable = true;
          keybinds.capture = "prefix+shift+s";
        };
      };
      annotateNoKeys = mkHome {
        plugins.jjWorkspace.enable = false;
        plugins.annotate.enable = true;
        plugins.annotate.keybinds.enable = false;
      };
      enabled = mkHome {
        plugins.jjWorkspace.enable = false;
        plugins.worktrunk = {
          enable = true;
          keybinds.open = "prefix+shift+w";
          settings = {
            picker_placement = "popup";
            show_remote_branches = true;
          };
        };
      };
      pluginPackage = self.packages.${pkgs.stdenv.hostPlatform.system}.herdr-plugin-worktrunk;
      overriddenPackage = pluginPackage.overrideAttrs (_: {
        name = "herdr-worktrunk-override";
      });
      overridden = mkHome {
        plugins.jjWorkspace.enable = false;
        plugins.worktrunk = {
          enable = true;
          package = overriddenPackage;
          keybinds.enable = false;
        };
      };
      extra = mkHome {
        plugins.jjWorkspace.enable = false;
        extraPlugins = [
          {
            id = "worktrunk";
            package = pluginPackage;
            enabled = false;
          }
        ];
      };
      duplicate = mkHome {
        plugins.worktrunk.enable = true;
        extraPlugins = [
          {
            id = "worktrunk";
            package = pluginPackage;
          }
        ];
      };
      mismatched = mkHome {
        plugins.jjWorkspace.enable = false;
        extraPlugins = [
          {
            id = "wrong-id";
            package = pluginPackage;
          }
        ];
      };
    in
    {
      checks.herdr-combined-plugins = pkgs.runCommand "check-herdr-combined-plugins" { } ''
        test -x ${combined.config.home.path}/bin/herdr-nvim
        test -x ${combined.config.home.path}/bin/herdr-navigator
        test -x ${
          self.packages.${pkgs.stdenv.hostPlatform.system}.herdr-plugin-annotate
        }/bin/plannotator-tui.exe
        test ! -e ${combined.config.home.path}/herdr-plugin.toml
        touch "$out"
      '';

      checks.herdr-plugins =
        assert !disabled.config.modules.home.herdr.plugins.navigator.enable;
        assert !(disabled.config.xdg.configFile ? "herdr/plugins/config/herdr-navigator/config.toml");
        assert !disabled.config.modules.home.herdr.plugins.nvim.enable;
        assert !(disabled.config.xdg.configFile ? "herdr-nvim/config.toml");
        assert !disabled.config.modules.home.herdr.plugins.worktrunk.enable;
        assert !(disabled.config.xdg.configFile ? "herdr/plugins.json");
        assert !(disabled.config.xdg.configFile ? "herdr/plugins/config/worktrunk/config.toml");
        assert overridden.config.modules.home.herdr.plugins.worktrunk.package == overriddenPackage;
        assert
          overridden.config.modules.home.herdr.plugins.worktrunk.manifestFile
          == overriddenPackage.manifestFile;
        assert !(builtins.tryEval duplicate.activationPackage.drvPath).success;
        assert
          !(builtins.tryEval mismatched.config.xdg.configFile."herdr/plugins.json".source.drvPath).success;
        assert
          enabled.config.modules.home.herdr.plugins.worktrunk.package
          == self.packages.${pkgs.stdenv.hostPlatform.system}.herdr-plugin-worktrunk;
        pkgs.runCommand "check-herdr-plugins" { nativeBuildInputs = [ pkgs.jq ]; } ''
          jq -e 'length == 1 and .[0].plugin_id == "worktrunk" and .[0].enabled' \
            ${enabled.config.xdg.configFile."herdr/plugins.json".source}
          grep -F 'prefix+shift+w' ${enabled.config.xdg.configFile."herdr/config.toml".source}
          grep -F 'prefix+shift+x' ${enabled.config.xdg.configFile."herdr/config.toml".source}
          grep -F 'popup' ${enabled.config.xdg.configFile."herdr/plugins/config/worktrunk/config.toml".source}
          if grep -F 'worktrunk.open' ${overridden.config.xdg.configFile."herdr/config.toml".source}; then
            echo "Disabled plugin keybindings are still present" >&2
            exit 1
          fi
          jq -e --arg root '${overriddenPackage}' '.[0].plugin_root == $root' \
            ${overridden.config.xdg.configFile."herdr/plugins.json".source}
          jq -e 'length == 1 and .[0].plugin_id == "worktrunk" and (.[0].enabled | not)' \
            ${extra.config.xdg.configFile."herdr/plugins.json".source}
          touch "$out"
        '';

      checks.herdr-nvim = pkgs.runCommand "check-herdr-nvim" { nativeBuildInputs = [ pkgs.jq ]; } ''
        jq -e 'length == 1 and .[0].plugin_id == "chmarax.herdr-nvim" and .[0].enabled and (.[0].link_handlers | length == 2)' \
          ${nvimEnabled.config.xdg.configFile."herdr/plugins.json".source}
        grep -F 'prefix+e' ${nvimEnabled.config.xdg.configFile."herdr/config.toml".source}
        grep -F 'prefix+f' ${nvimEnabled.config.xdg.configFile."herdr/config.toml".source}
        grep -F 'left' ${nvimEnabled.config.xdg.configFile."herdr-nvim/config.toml".source}
        if grep -F 'chmarax.herdr-nvim' ${nvimNoKeys.config.xdg.configFile."herdr/config.toml".source}; then
          echo "Disabled Neovim keybindings are still present" >&2
          exit 1
        fi
        test -x ${self.packages.${pkgs.stdenv.hostPlatform.system}.herdr-plugin-nvim}/bin/herdr-nvim
        test -f ${
          self.packages.${pkgs.stdenv.hostPlatform.system}.herdr-plugin-nvim
        }/lua/herdr-nvim/init.lua
        touch "$out"
      '';

      checks.herdr-annotate =
        pkgs.runCommand "check-herdr-annotate" { nativeBuildInputs = [ pkgs.jq ]; }
          ''
            jq -e 'length == 1 and .[0].plugin_id == "annotate" and .[0].enabled and (.[0].actions | length == 7) and (.[0].panes | length == 3) and (.[0].link_handlers | length == 1)' \
              ${annotateEnabled.config.xdg.configFile."herdr/plugins.json".source}
            grep -F 'prefix+shift+s' ${annotateEnabled.config.xdg.configFile."herdr/config.toml".source}
            grep -F 'annotate.open' ${annotateEnabled.config.xdg.configFile."herdr/config.toml".source}
            if grep -F 'annotate.' ${annotateNoKeys.config.xdg.configFile."herdr/config.toml".source}; then
              echo "Disabled Annotate keybindings are still present" >&2
              exit 1
            fi
            test -x ${annotateEnabled.config.home.path}/bin/bun
            test -x ${
              self.packages.${pkgs.stdenv.hostPlatform.system}.herdr-plugin-annotate
            }/bin/plannotator-tui.exe
            cmp ${self.packages.${pkgs.stdenv.hostPlatform.system}.herdr-plugin-annotate}/herdr-plugin.toml ${
              self.packages.${pkgs.stdenv.hostPlatform.system}.herdr-plugin-annotate.manifestFile
            }
            touch "$out"
          '';

      checks.herdr-navigator =
        assert navigatorNoKeys.config.modules.home.herdr.plugins.navigator.package == navigatorOverride;
        assert
          navigatorNoKeys.config.modules.home.herdr.plugins.navigator.manifestFile
          == navigatorOverride.manifestFile;
        pkgs.runCommand "check-herdr-navigator" { nativeBuildInputs = [ pkgs.jq ]; } ''
          jq -e 'length == 1 and .[0].plugin_id == "herdr-navigator" and .[0].enabled and (.[0].actions | length == 3) and (.[0].panes | length == 2)' \
            ${navigatorEnabled.config.xdg.configFile."herdr/plugins.json".source}
          grep -F 'prefix+tab' ${navigatorEnabled.config.xdg.configFile."herdr/config.toml".source}
          grep -F 'prefix+shift+tab' ${navigatorEnabled.config.xdg.configFile."herdr/config.toml".source}
          grep -F 'prefix+shift+a' ${navigatorEnabled.config.xdg.configFile."herdr/config.toml".source}
          grep -F 'last_pane = "prefix+a"' ${
            navigatorEnabled.config.xdg.configFile."herdr/config.toml".source
          }
          if grep -F 'herdr-workspace-fzf' ${
            navigatorEnabled.config.xdg.configFile."herdr/config.toml".source
          }; then
            echo "Old workspace picker binding is still present" >&2
            exit 1
          fi
          grep -F 'last_pane = "prefix+a"' ${navigatorNoKeys.config.xdg.configFile."herdr/config.toml".source}
          grep -F 'herdr-workspace-fzf' ${navigatorNoKeys.config.xdg.configFile."herdr/config.toml".source}
          grep -F 'vim_mode = true' ${
            navigatorEnabled.config.xdg.configFile."herdr/plugins/config/herdr-navigator/config.toml".source
          }
          grep -F 'check_updates = false' ${
            navigatorEnabled.config.xdg.configFile."herdr/plugins/config/herdr-navigator/config.toml".source
          }
          grep -F 'check_updates = true' ${
            navigatorNoKeys.config.xdg.configFile."herdr/plugins/config/herdr-navigator/config.toml".source
          }
          if grep -F 'herdr-navigator.' ${
            navigatorNoKeys.config.xdg.configFile."herdr/config.toml".source
          }; then
            echo "Disabled Navigator keybindings are still present" >&2
            exit 1
          fi
          test -x ${navigatorPackage}/target/release/herdr-navigator
          cmp ${navigatorPackage}/herdr-plugin.toml ${navigatorPackage.manifestFile}
          touch "$out"
        '';

      packages = {
        herdr-plugin-annotate = pkgs.callPackage ./herdr/annotate-plugin.pkg.nix {
          src = moduleFlake.inputs.herdr-annotate;
        };
        herdr-plugin-navigator = pkgs.callPackage ./herdr/navigator-plugin.pkg.nix {
          src = moduleFlake.inputs.herdr-navigator;
        };
        herdr-plugin-nvim = pkgs.callPackage ./herdr/nvim-plugin.pkg.nix {
          src = moduleFlake.inputs.herdr-nvim;
        };
        herdr-plugin-jj-workspace = pkgs.callPackage ./herdr/jj-workspace-plugin.pkg.nix {
          src = moduleFlake.inputs.herdr-plugin-jj-workspace;
        };
        herdr-plugin-worktrunk = pkgs.callPackage ./herdr/worktrunk-plugin.pkg.nix {
          src = moduleFlake.inputs.herdr-worktrunk;
        };
      };
    };
}
