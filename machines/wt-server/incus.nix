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
}
