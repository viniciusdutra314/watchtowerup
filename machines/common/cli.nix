{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bat
    btop
    fastfetch
    imagemagick
    jq
    speedtest-cli
    neovim
    psmisc
    ripgrep
    tmux
    tree
    wget
    yt-dlp
  ];
}
