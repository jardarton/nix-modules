{
  inputs,
  self,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    {
      checks = pkgs.lib.mapAttrs' (
        name: module:
        let
          inherit
            (
              (inputs.home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                modules = [
                  module
                  {
                    home = {
                      username = "module-test";
                      homeDirectory = "/home/module-test";
                      stateVersion = "26.05";
                    };
                  }
                ];
              })
            )
            activationPackage
            ;
          evaluated = builtins.addErrorContext "while evaluating homeModules.${name}: " activationPackage.drvPath;
        in
        pkgs.lib.nameValuePair "home-module-${name}" (
          builtins.seq evaluated (pkgs.runCommand "check-home-module-${name}" { } "touch $out")
        )
      ) self.homeModules;
    };
}
