{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bat
    btop
    fastfetch
    imagemagick
    jq
    neovim
    psmisc
    ripgrep
    tmux
    tree
    wget
    yt-dlp
  ];
}
