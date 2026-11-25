{ IP_WT-LAPTOP, ... }:
{
  environment.etc."crypttab".text = ''
    watchtower-personal UUID=d7210228-d2d7-4e2f-bb64-ce360035fd49 /var/lib/watchtower/keys/personal.key luks,nofail,headless
    watchtower-core UUID=8d79280b-06d8-4006-9540-325ccf44ae89 /var/lib/watchtower/keys/core-key luks,nofail,headless
  '';
  fileSystems = {
    "/mnt/wt-core" = {
      device = "/dev/mapper/watchtower-core";
      fsType = "btrfs";
      options = [
        "nofail"
      ];
    };
    "/mnt/wt-library" = {
      device = "UUID=111c2127-50c6-4005-a541-e2441d7c2cba";
      fsType = "xfs";
      options = [
        "nofail"
      ];
    };
    "/mnt/wt-personal" = {
      device = "/dev/mapper/watchtower-personal";
      fsType = "btrfs";
      options = [
        "nofail"
      ];
    };
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/wt-core    ${IP_WT-LAPTOP}/32(rw,sync,root_squash,no_subtree_check,mp,fsid=101)
      /mnt/wt-library ${IP_WT-LAPTOP}/32(rw,sync,root_squash,no_subtree_check,mp,fsid=102)
      /mnt/wt-personal ${IP_WT-LAPTOP}/32(rw,sync,root_squash,no_subtree_check,mp,fsid=103)
    '';
  };
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 2049 ];

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024; # 32 GiB
    }
  ];
  boot.zswap.enable = true;
}
