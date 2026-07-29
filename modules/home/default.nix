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
    stylix = importApply ./stylix.nix { localFlake = moduleFlake; };
    xdg = importApply ./xdg { localFlake = moduleFlake; };
    hyprland = importApply ./hyprland { localFlake = moduleFlake; };
    devops = importApply ./devops { localFlake = moduleFlake; };
    dwm = importApply ./dwm { localFlake = moduleFlake; };
    waybar = importApply ./waybar { localFlake = moduleFlake; };
    media = importApply ./media.nix { localFlake = moduleFlake; };
    firefox = importApply ./firefox { localFlake = moduleFlake; };
    vscode = importApply ./vscode.nix { localFlake = moduleFlake; };
    btop = importApply ./btop.nix { localFlake = moduleFlake; };
    bat = importApply ./bat.nix { localFlake = moduleFlake; };
    zsh = importApply ./zsh.nix { localFlake = moduleFlake; };
    ghostty = importApply ./ghostty.nix { localFlake = moduleFlake; };
    zathura = importApply ./zathura.nix { localFlake = moduleFlake; };
    git = importApply ./git.nix { localFlake = moduleFlake; };
    jujutsu = importApply ./jujutsu.nix { localFlake = moduleFlake; };
    eza = importApply ./eza.nix { localFlake = moduleFlake; };
    kitty = importApply ./kitty.nix { localFlake = moduleFlake; };
    tmux = importApply ./tmux.nix { localFlake = moduleFlake; };
    fonts = importApply ./fonts.nix { localFlake = moduleFlake; };
    yazi = importApply ./yazi.nix { localFlake = moduleFlake; };
    starship = importApply ./starship.nix { localFlake = moduleFlake; };
    fzf = importApply ./fzf.nix { localFlake = moduleFlake; };
    taskwarrior = importApply ./taskwarrior.nix { localFlake = moduleFlake; };
    i3 = importApply ./i3.nix { localFlake = moduleFlake; };
    sway = importApply ./sway.nix { localFlake = moduleFlake; };
    neovim = importApply ./neovim.nix { localFlake = moduleFlake; };
    cli-tools = importApply ./cli-tools.nix { localFlake = moduleFlake; };
    reverse-engineering = importApply ./reverse-engineering.nix { localFlake = moduleFlake; };
    direnv = importApply ./direnv.nix { localFlake = moduleFlake; };
    catsvim = importApply ./catsvim { localFlake = moduleFlake; };
    aerospace = importApply ./aerospace { localFlake = moduleFlake; };
    mango = importApply ./mango { localFlake = moduleFlake; };
    bitwarden = importApply ./bitwarden.nix { localFlake = moduleFlake; };
    screenshot = importApply ./screenshot.nix { localFlake = moduleFlake; };
    dstask = importApply ./dstask { localFlake = moduleFlake; };
    bun = importApply ./bun.nix { localFlake = moduleFlake; };
    ai = importApply ./ai { localFlake = moduleFlake; };
    television = importApply ./television.nix { localFlake = moduleFlake; };
    fsel = importApply ./fsel.nix { localFlake = moduleFlake; };
    node = importApply ./node.nix { localFlake = moduleFlake; };
    gondolin = importApply ./gondolin.nix { localFlake = moduleFlake; };
    nh = importApply ./nh.nix { localFlake = moduleFlake; };
    herdr = importApply ./herdr.nix { localFlake = moduleFlake; };
  };
}
