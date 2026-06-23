# ❄️ nix-modules

Reusable NixOS and Home Manager modules packaged as a
  flake.This
  repository
  is
  the
  public
  module layer: shared defaults, application modules, desktop wiring, packages, and small utilities. It intentionally does not contain host composition, secrets, private network layout, users, SSH keys, or machine-specific state. Those belong in the consuming configuration repo.

## What is included

### Home Manager modules

- `default` / `base-home`
- `aerospace`
- `ai`
- `bat`
- `bitwarden`
- `btop`
- `bun`
- `catsvim`
- `cli-tools`
- `devops`
- `direnv`
- `dstask`
- `dwm`
- `eza`
- `firefox`
- `fonts`
- `fsel`
- `fzf`
- `ghostty`
- `git`
- `herdr`
- `hyprland`
- `i3`
- `jujutsu`
- `kitty`
- `mango`
- `media`
- `neovim`
- `node`
- `screenshot`
- `starship`
- `stylix`
- `sway`
- `taskwarrior`
- `television`
- `tmux`
- `vscode`
- `waybar`
- `xdg`
- `yazi`
- `zathura`
- `zsh`

### NixOS modules

- `base-packages`
- `bluetooth`
- `fonts`
- `home-assistant`
- `kanata`
- `keyd`
- `laptop-base`
- `mango`
- `oryx`
- `stylix`
- `wifi`

### Packages and utilities

- `packages.cclip`
- `utils/fix-nix-daemon-ca.sh`

## Use from another flake

Add this repository as an input:

```nix
{
inputs = {
nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
home-manager.url = "github:nix-community/home-manager";
nix-modules.url = "github:USER/nix-modules";
};
}
```

For local development before publishing, use a path input:

```nix
nix-modules.url = "path:/home/jdr/nix-modules";
```

## Import modules directly

### NixOS

```nix
{
inputs,
...
}:
{
imports = [
inputs.nix-modules.nixosModules.base-packages
inputs.nix-modules.nixosModules.bluetooth
inputs.nix-modules.nixosModules.fonts
];
}
```

### Home Manager

```nix
{
inputs,
...
}:
{
imports = [
inputs.nix-modules.homeModules.default
inputs.nix-modules.homeModules.git
inputs.nix-modules.homeModules.firefox
inputs.nix-modules.homeModules.zsh
];

modules.home.firefox = {
enable = true;
profile = "default";
};
}
```

## Import the whole module set with flake-parts

If your consuming repository also uses `flake-parts`, import the module tree and let it expose the module collections:

```nix
{
inputs,
...
}:
{
imports = [
"${inputs.nix-modules}/modules"
];
}
```

This makes the exported `homeModules`, `nixosModules`, and packages available to the consuming flake while keeping this repository as the owner of module-specific inputs.
