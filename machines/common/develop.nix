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
    cloc
    cmake
    direnv
    gdb
    gh
    ghc
    git
    git-lfs
    gnumake
    hyperfine
    jujutsu
    just
    lldb
    mojo-bin
    ninja
    nixd
    nixfmt
    rustup
    texliveFull
    typst
    uv
    zig
  ];
}
