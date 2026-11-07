_: {
  # Unlike most features here, importing this one does not enable it. The module
  # cannot do anything without a consumer-supplied ntfy topic, and a placeholder
  # default would post alerts to an unrelated endpoint.
  flake.modules.nixos.disk-monitor.imports = [ ./disk-monitor/nixos.nix ];

  # Export groups evaluated together by this flake's module checks.
  nixModules.checkCompositions.nixos.server = [ "disk-monitor" ];
}
