{ lib, ... }:
{
  imports = [
    ../common/git.nix
    ../common/zsh.nix
    ../common/develop.nix
    ../common/cli.nix
    ../common/codex.nix
    ../common/home-manager.nix
    ../wt-laptop/ssh.nix
  ];
  nixpkgs.config.allowUnfree = true;
  news.display = "silent";
  home.username = "chloe";
  home.homeDirectory = "/home/chloe";
  home.stateVersion = "26.05";
  targets.genericLinux.enable = true;
}
