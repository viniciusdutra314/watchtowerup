{
  networking.hostName = "wt-server";
  networking.networkmanager.enable = true;

  networking = {
    interfaces.enp3s0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.0.100";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = "192.168.0.1";
    nameservers = [
      "192.168.0.1"
      "1.1.1.1"
    ];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 8096 ];
  };

  services = {
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        AllowTCPForwarding = true;
      };
    };
    tailscale = {
      enable = true;
    };
  };
}
