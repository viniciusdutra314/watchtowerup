{ ... }:
{
  imports = [
    ../common/cli.nix
    ../common/git.nix
    ../common/zsh.nix
  ];

  home.username = "vinicius";
  home.homeDirectory = "/home/vinicius";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
  news.display = "silent";
}
