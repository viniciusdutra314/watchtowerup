{ config, pkgs, ... }:
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
      vhostUserPackages = [ pkgs.virtiofsd ];
    };
    onShutdown = "shutdown";
  };
  security.polkit.enable = true;

  virtualisation.docker = {
    enable = true;
    liveRestore = true;
  };

  systemd.services.docker.unitConfig.RequiresMountsFor = [
    "/mnt/wt-core"
  ];

  systemd.services.libvirtd.unitConfig.RequiresMountsFor = [
    "/mnt/wt-core"
  ];

  systemd.services.wt-startup = {
    description = "Start Watchtower containers and development VM";
    wantedBy = [ "multi-user.target" ];
    requires = [
      "docker.service"
      "libvirtd.service"
    ];
    after = [
      "docker.service"
      "libvirtd.service"
    ];
    unitConfig.RequiresMountsFor = [
      "/mnt/wt-core"
      "/mnt/wt-library"
      "/mnt/wt-personal"
    ];
    path = [
      config.virtualisation.docker.package
      config.virtualisation.libvirtd.package
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/mnt/wt-core/watchtowerup/containers";
    };
    script = ''
      docker compose up -d
    '';
  };
}
