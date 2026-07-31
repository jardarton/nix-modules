{
  flake-parts-lib,
  self,
  inputs,
  ...
}:
let
  inherit (flake-parts-lib) importApply;
  moduleFlake = inputs.nix-modules or self;
in
{
  flake.homeModules = {

    default = importApply ./base-home.nix { localFlake = moduleFlake; };
    xdg = importApply ./xdg { localFlake = moduleFlake; };
    media = importApply ./media.nix { localFlake = moduleFlake; };
    presentation = importApply ./presentation.nix { localFlake = moduleFlake; };
    firefox = importApply ./firefox { localFlake = moduleFlake; };
    vscode = importApply ./vscode.nix { localFlake = moduleFlake; };
    zsh = importApply ./zsh.nix { localFlake = moduleFlake; };
    ghostty = importApply ./ghostty.nix { localFlake = moduleFlake; };
    tmux = importApply ./tmux.nix { localFlake = moduleFlake; };
    yazi = importApply ./yazi.nix { localFlake = moduleFlake; };
    starship = importApply ./starship.nix { localFlake = moduleFlake; };
    taskwarrior = importApply ./taskwarrior.nix { localFlake = moduleFlake; };
    neovim = importApply ./neovim.nix { localFlake = moduleFlake; };
    reverse-engineering = importApply ./reverse-engineering.nix { localFlake = moduleFlake; };
    catsvim = importApply ./catsvim { localFlake = moduleFlake; };
    aerospace = importApply ./aerospace { localFlake = moduleFlake; };
    bitwarden = importApply ./bitwarden.nix { localFlake = moduleFlake; };
    screenshot = importApply ./screenshot.nix { localFlake = moduleFlake; };
    dstask = importApply ./dstask { localFlake = moduleFlake; };
    ai = importApply ./ai { localFlake = moduleFlake; };
    television = importApply ./television.nix { localFlake = moduleFlake; };
    nh = importApply ./nh.nix { localFlake = moduleFlake; };
    herdr = importApply ./herdr.nix { localFlake = moduleFlake; };
  };
}
