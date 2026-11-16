{ config, pkgs, ... }:

let
  IP_WT-LAPTOP = "100.122.93.55";
in
{
  imports = [
    ./hardware-configuration.nix
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.etc."nixos/flake.nix".source =
  "/mnt/wt-core/watchtowerup/machines/flake.nix";
  boot.kernelModules = [
    "kvm-intel" #important for qemu/kvm
  ];
  boot.kernelParams = [
    "usb-storage.quirks=0bda:9210:u"
  ];
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd = {
    availableKernelModules = [
      "r8169" #ethernet cable driver
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
          ''command="systemctl default" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIALu7q6/1Huhb+QU4h9ymJ/kkzZwkjWee1N7wos45eCN watchtower initrd''
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
 swapDevices = [{
  device = "/var/lib/swapfile";
  size = 32*1024; # 32 GiB
 }];
 boot.zswap.enable = true;
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
  
  programs.bash.loginShellInit = ''
    if [[ $- == *i* && "$USER" == "vinicius" ]]; then
      if [[ -d /mnt/wt-core/watchtowerup ]]; then
        cd /mnt/wt-core/watchtowerup
      fi
    fi
  '';
  networking.hostName = "wt-server";
  networking.networkmanager.enable = true;

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
  programs.zsh.enable = true;
  users.users."vinicius" = {
    isNormalUser = true;
    shell = pkgs.zsh;
    linger = true;
    description = "vinicius";
    extraGroups = [
      "networkmanager"
      "wheel"
      "kvm"
      "docker"
      "libvirtd"
    ];
    packages = with pkgs; [ ];
  };

  environment.systemPackages = with pkgs; [
    usbutils
    qemu
    python314
    smartmontools
  ];
  
 virtualisation.libvirtd = {
  enable = true;
  qemu = {
    package = pkgs.qemu_kvm;
    swtpm.enable = true;
    vhostUserPackages=[pkgs.virtiofsd];
  };
  onShutdown = "shutdown";
 };
  security.polkit.enable = true;

  virtualisation.docker = {
    enable = true;
    liveRestore = true;
  };
  programs.git.enable = false;
  networking.firewall = {
    enable=true;
    allowedTCPPorts=[8096];
  };
  programs.nix-ld.enable=true;
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
      fsType="xfs";
      options=[
        "nofail"
      ];
    };
   "/mnt/wt-personal" = {
     device="/dev/mapper/watchtower-personal";
     fsType="btrfs";
     options=[
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


  networking = {
    interfaces.enp3s0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.0.100";
        prefixLength = 24;
      }];
    };
    defaultGateway = "192.168.0.1";
    nameservers = [
      "192.168.0.1"
      "1.1.1.1"
    ];
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

      case "$(virsh -c qemu:///system domstate wt-devbox)" in
        "shut off")
          virsh -c qemu:///system start wt-devbox
          ;;
        running)
          echo "wt-devbox already running"
          ;;
        *)
          echo "Unexpected VM state" >&2
          exit 1
          ;;
      esac
    '';
  };


  #network things
  services = {
    openssh = {
      enable = true;
      openFirewall = true;
      settings={AllowTCPForwarding=true;};
    };
    tailscale = {
      enable = true;
    };
  };

  system.copySystemConfiguration = false;
  system.stateVersion = "26.05"; # Don't change it

}
