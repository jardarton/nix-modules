#!/usr/bin/env bash
set -euo pipefail

if ! command -v nix >/dev/null 2>&1; then
  echo "error: nix is not in PATH" >&2
  exit 1
fi

if ! command -v systemctl >/dev/null 2>&1; then
  echo "error: systemctl is not in PATH" >&2
  exit 1
fi

cert="$(nix config show | sed -n 's/^ssl-cert-file = //p')"

if [[ -z "$cert" ]]; then
  echo "error: could not read ssl-cert-file from 'nix config show'" >&2
  exit 1
fi

dropin_dir="/etc/systemd/system/nix-daemon.service.d"
if ! sudo test -w /etc/systemd/system; then
  dropin_dir="/run/systemd/system/nix-daemon.service.d"
fi

dropin_file="$dropin_dir/99-ca-fix.conf"

echo "Using cert: $cert"
echo "Writing drop-in: $dropin_file"

sudo mkdir -p "$dropin_dir"
sudo tee "$dropin_file" >/dev/null <<EOF
[Service]
UnsetEnvironment=NIX_CURL_FLAGS CURL_CA_BUNDLE
Environment="CURL_CA_BUNDLE=$cert"
Environment="NIX_CURL_FLAGS=--cacert $cert"
EOF

sudo systemctl daemon-reload
sudo systemctl restart nix-daemon

echo
echo "nix-daemon environment:"
systemctl show nix-daemon.service --property=Environment

echo
echo "Done. Next step:"
echo "  sudo nixos-rebuild switch --flake .#$(hostname)"
