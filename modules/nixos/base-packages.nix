_:
{
  pkgs,
  ...
}:
{
  environment.variables.EDITOR = "catsVim"; # "nvim";

  programs.zsh = {
    enable = true;
    shellInit = "set -o vi";
    enableCompletion = true;
  };

  environment.systemPackages = with pkgs; [
    tealdeer
    fastfetch
    vim
    htop
    neovim
    just
    git
    fzf
    zsh
    dust
    dua
    gcc
    cmake
    powertop

    pciutils

    # archives
    zip
    xz
    zstd
    unzipNLS
    p7zip

    # Text Processing
    # Docs: https://github.com/learnbyexample/Command-line-text-processing
    gnugrep # GNU grep, provides `grep`/`egrep`/`fgrep`
    gnused # GNU sed, very powerful(mainly for replacing text in files)
    gawk # GNU awk, a pattern scanning and processing language
    jq # A lightweight and flexible command-line JSON processor

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    wget
    curl
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # misc
    file
    findutils
    which
    tree
    gnutar
    rsync
    dust
    fd
    ripgrep
    dysk
    setxkbmap
    bc
  ];
}
