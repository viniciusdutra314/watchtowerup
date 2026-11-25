{ pkgs, ... }:
{
  boot.kernelModules = [
    "kvm-intel" # important for qemu/kvm
  ];
  boot.kernelParams = [
    "usb-storage.quirks=0bda:9210:u"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd = {
    availableKernelModules = [
      "r8169" # ethernet cable driver
    ];
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;
        hostKeys = [
          "/etc/secrets/initrd/ssh_host_ed25519_key"
        ];
        authorizedKeys = [
          ''command="systemctl default" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQLLIm5lkUC0PX86Hrs9H87VDKoNJFnZd7Oc46Tp55c watchtower initrd''
        ];
      };
    };
    systemd = {
      network = {
        enable = true;
        networks."10-ethernet" = {
          matchConfig.Name = "enp3s0";
          address = [
            "192.168.0.100/24"
          ];

          routes = [
            { Gateway = "192.168.0.1"; }
          ];
          linkConfig.RequiredForOnline = "routable";
        };
      };
    };
  };
}
