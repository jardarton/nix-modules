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
      checks.herdr-plugins =
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

      packages = {
        herdr-plugin-jj-workspace = pkgs.callPackage ./herdr/jj-workspace-plugin.pkg.nix {
          src = moduleFlake.inputs.herdr-plugin-jj-workspace;
        };
        herdr-plugin-worktrunk = pkgs.callPackage ./herdr/worktrunk-plugin.pkg.nix {
          src = moduleFlake.inputs.herdr-worktrunk;
        };
      };
    };
}
