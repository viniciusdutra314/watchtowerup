let
  httpsPort = 8443;
  coreMount = "/mnt/wt-core";
  checkoutPath = "${coreMount}/watchtowerup";
  poolName = "default";
  bridgeName = "incusbr0";
in
{
  security.apparmor.enable = true;

  virtualisation.incus = {
    enable = true;
    ui.enable = true;
    preseed = {
      config."core.https_address" = ":${toString httpsPort}";

      storage_pools = [
        {
          name = poolName;
          driver = "btrfs";
          config.source = "${coreMount}/@incus";
        }
      ];

      networks = [
        {
          name = bridgeName;
          type = "bridge";
          config = {
            "ipv4.address" = "10.100.0.1/24";
            "ipv4.dhcp" = "true";
            "ipv4.nat" = "true";
            "ipv6.address" = "none";
          };
        }
      ];

      profiles = [
        {
          name = "default";
          devices = {
            root = {
              type = "disk";
              path = "/";
              pool = poolName;
            };
            eth0 = {
              type = "nic";
              name = "eth0";
              network = bridgeName;
            };
            watchtowerup = {
              type = "disk";
              source = checkoutPath;
              path = checkoutPath;
              shift = "true";
              readonly = "false";
            };
          };
        }
      ];
    };
  };
  users.users.vinicius.extraGroups = [ "incus-admin" ];

  networking.nftables.enable = true;
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ httpsPort ];
  networking.networkmanager.unmanaged = [ "interface-name:${bridgeName}" ];
  networking.firewall.interfaces.${bridgeName} = {
    allowedTCPPorts = [
      53
      67
    ];
    allowedUDPPorts = [
      53
      67
    ];
  };
  systemd.services.incus.unitConfig.RequiresMountsFor = [ coreMount ];
  systemd.services.incus-preseed.unitConfig.RequiresMountsFor = [ coreMount ];
}
