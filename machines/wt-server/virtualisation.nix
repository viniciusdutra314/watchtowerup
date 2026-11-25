{ config, ... }:
{
  security.polkit.enable = true;

  virtualisation.docker = {
    enable = true;
    liveRestore = true;
  };

  systemd.services.docker.unitConfig.RequiresMountsFor = [
    "/mnt/wt-core"
  ];

  systemd.services.wt-startup = {
    description = "Start Watchtower containers";
    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" ];
    after = [ "docker.service" ];
    unitConfig.RequiresMountsFor = [
      "/mnt/wt-core"
      "/mnt/wt-library"
      "/mnt/wt-personal"
    ];
    path = [ config.virtualisation.docker.package ];
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
