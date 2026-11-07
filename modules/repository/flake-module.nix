# The flake module consumers import to get every reusable feature. This flake
# imports it too, so its own outputs come from the same definition.
{ inputs, self, ... }:
let
  flakeModule =
    { lib, ... }:
    {
      imports = [
        inputs.flake-parts.flakeModules.modules
        inputs.home-manager.flakeModules.home-manager
        ../.
      ];

      # Capture this flake so imported features never depend on the name a
      # consumer assigned to the input.
      nixModules.sourceFlake = lib.mkDefault self;
    };
in
{
  imports = [ flakeModule ];

  flake.flakeModule = flakeModule;
}
