{ lib, ... }:
{
  imports = [
    ../common/git.nix
    ../common/zsh.nix
    ../common/develop.nix
    ../common/cli.nix
    ../common/codex.nix
    ../wt-laptop/ssh.nix
  ];
  nixpkgs.config.allowUnfree = true;
  news.display = "silent";
  home.username = "vinicius";
  home.homeDirectory = "/home/vinicius";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
  targets.genericLinux.enable = true;
}
