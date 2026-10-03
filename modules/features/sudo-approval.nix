{ self, ... }:
{
  # Unlike most features here, importing this one does not enable it. The module
  # needs a consumer-supplied ntfy server and access tokens.
  flake.modules.nixos.sudo-approval.imports = [ ./sudo-approval/nixos.nix ];

  perSystem =
    { lib, pkgs, ... }:
    {
      checks = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        sudo-approval = pkgs.testers.runNixOSTest (import ./sudo-approval/test.nix { inherit self; });
      };
    };
}
