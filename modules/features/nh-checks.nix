# Exercise option overrides and conditional output independently of the broad
# Home Manager composition check.
{ inputs, self, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      mkHome =
        settings:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            self.homeModules.nh
            {
              home.username = "module-test";
              home.homeDirectory =
                if pkgs.stdenv.hostPlatform.isDarwin then "/Users/module-test" else "/home/module-test";
              home.stateVersion = "26.05";
              modules.home.nh = settings;
            }
          ];
        };
      disabled = mkHome { enable = false; };
      overridden = mkHome {
        package = pkgs.hello;
        flake = "/tmp/test-flake";
      };
    in
    {
      checks.nh-conditional-overrides =
        assert !(builtins.elem pkgs.nh disabled.config.home.packages);
        assert !(disabled.config.home.sessionVariables ? NH_FLAKE);
        assert builtins.elem pkgs.hello overridden.config.home.packages;
        assert !(builtins.elem pkgs.nh overridden.config.home.packages);
        assert overridden.config.home.sessionVariables.NH_FLAKE == "/tmp/test-flake";
        assert builtins.all (item: item.assertion) overridden.config.assertions;
        pkgs.runCommand "check-nh-conditional-overrides" { } "touch $out";
    };
}
