{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config = {
    nvidia.acceptLicense = true;
    permittedInsecurePackages = [
      "firefox-esr-140-bin-unwrapped-140.17.0esr"
    ];
  };
  news.display = "silent";
  home.username = "vinicius";
  home.homeDirectory = "/home/vinicius";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  xdg.configFile."sway/config.d/90-bar.conf".text = ''
    # Waybar iniciada pelo Home Manager/Sway.
    # Desativa a barra padrão do Fedora.
  '';
  targets.genericLinux.enable = true; # make GPU acceleration work
  # Mantenha a versão em sincronia com o driver instalado no Fedora.
  targets.genericLinux.gpu.nvidia = {
    enable = true;
    version = "620.70.06";
    sha256 = "sha256-KRGOOr0IwHVZvMo9nHYjjQOUkK8DYqLlvPy+cgSv1LE=";
  };
  home.sessionVariables.GTK_IM_MODULE = "simple"; # make ~ work in ghostty

  home.file = let
    calculator = {
      source = ../scripts/overenginerring-calculator.py;
      executable = true;
    };
  in {
    ".local/bin/over-engineering-calculator" = calculator;
    ".local/bin/overenginerring-calculator" = calculator;
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.juliaup/bin"
  ];

  home.packages = with pkgs; [
    flatpak
    flameshot
    woomer
  ];

  imports = [
    ../common/git.nix
    ./sway.nix
    ../common/zsh.nix
    ./ssh.nix
    ./waybar.nix
    ../common/develop.nix
    ../common/cli.nix
    ../common/develop-desktop.nix
    ./commands.nix
    ./flatpaks.nix
  ];
}
