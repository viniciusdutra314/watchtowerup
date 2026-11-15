{ pkgs, ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.juliaup/bin"
  ];
  home.packages = with pkgs; [
    bat
    btop
    cloc
    cmake
    direnv
    fastfetch
    gdb
    gh
    ghc
    git
    git-lfs
    gnumake
    hyperfine
    imagemagick
    jq
    jujutsu
    just
    lldb
    ninja
    nixd
    nixfmt
    ripgrep
    rustup
    texliveFull
    tmux
    tree
    typst
    uv
    yt-dlp
    zig
  ];
}
