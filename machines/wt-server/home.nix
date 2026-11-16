{ ... }:
{
  imports = [
    ../common/cli.nix
    ../common/develop.nix
    ../common/git.nix
    ../common/zsh.nix
    ../common/home-manager.nix
  ];

  home.username = "vinicius";
  home.homeDirectory = "/home/vinicius";
  home.stateVersion = "26.05";
  news.display = "silent";
}
