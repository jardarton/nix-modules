{ inputs, ... }:
let
  featureDir = ./features;
  featureModules = builtins.map (name: featureDir + "/${name}") (
    builtins.filter (
      name:
      let
        type = (builtins.readDir featureDir).${name};
      in
      type == "regular" && builtins.match ".*\\.nix" name != null
    ) (builtins.attrNames (builtins.readDir featureDir))
  );
in
{
  # Files directly below features/ are automatically discovered flake-parts
  # modules. Subdirectories hold lower-level modules, packages, assets and
  # extra flake-parts modules (such as checks) imported by their owning feature.
  imports = [ inputs.flake-parts.flakeModules.modules ] ++ featureModules;
}
