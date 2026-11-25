{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./networking.nix
    ./storage.nix
    ./users.nix
    ./virtualisation.nix
    ./incus.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  environment.etc."nixos/flake.nix".source = "/mnt/wt-core/watchtowerup/machines/flake.nix";

  # Desligamento automático à meia-noite
  systemd.services.auto-poweroff = {
    description = "Automatic shutdown at midnight";

    serviceConfig.Type = "oneshot";

    script = ''
      ${pkgs.systemd}/bin/systemctl --no-block poweroff
    '';
  };

  systemd.timers.auto-poweroff = {
    description = "Daily midnight shutdown";

    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnCalendar = "*-*-* 00:00:00";
      AccuracySec = "1s";
      Persistent = false;
    };
  };

  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };
  console.keyMap = "br-abnt2";

  environment.systemPackages = with pkgs; [
    usbutils
    qemu
    python314
    smartmontools
  ];

  programs.git.enable = false;

  programs.nix-ld.enable = true;

  system.copySystemConfiguration = false;
  system.stateVersion = "26.05"; # Don't change it
}
