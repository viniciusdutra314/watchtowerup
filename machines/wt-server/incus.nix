let
  httpsPort = 8443;
in
{
  virtualisation.incus = {
    enable = true;
    ui.enable = true;
    preseed.config."core.https_address" = ":${toString httpsPort}";
  };
  users.users.vinicius.extraGroups = [ "incus-admin" ];

  networking.nftables.enable = true;
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ httpsPort ];
  networking.networkmanager.unmanaged = [ "interface-name:incusbr0" ];
  networking.firewall.interfaces.incusbr0 = {
    allowedTCPPorts = [
      53
      67
    ];
    allowedUDPPorts = [
      53
      67
    ];
  };

  fileSystems."/var/lib/incus" = {
    device = "/mnt/wt-core/incus";
    fsType = "none";
    depends = [ "/mnt/wt-core" ];
    options = [
      "bind"
      "nofail"
    ];
  };

  # The daemon and sockets must wait for the SSD before writing any state.
  systemd.sockets.incus.unitConfig.RequiresMountsFor = [ "/var/lib/incus" ];
  systemd.sockets.incus-user.unitConfig.RequiresMountsFor = [ "/var/lib/incus" ];
  systemd.services.incus.unitConfig.RequiresMountsFor = [ "/var/lib/incus" ];
}
