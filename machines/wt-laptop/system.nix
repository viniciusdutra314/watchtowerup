{ lib, ... }:

let
  nfsServer = "wt-server";
  unlockLuks =
    name: uuid: keyFile:
    let
      unit = "watchtower-storage-${name}";
      unlockUnit = "watchtower-unlock-${name}";
      source = "/dev/disk/by-uuid/${uuid}";
    in
    {
      systemd.services.${unlockUnit} = {
        description = "Unlock Watchtower ${name} with its key file";
        partOf = [ "${unit}.target" ];
        restartIfChanged = false;
        unitConfig.ConditionPathExists = source;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          TimeoutStartSec = "30s";
          TimeoutStopSec = "30s";
          ExecStart = "/usr/lib/systemd/systemd-cryptsetup attach watchtower-${name} ${source} ${keyFile} luks,headless";
          ExecStop = "/usr/lib/systemd/systemd-cryptsetup detach watchtower-${name}";
        };
      };

      systemd.services."${unit}-local" = {
        wants = [ "${unlockUnit}.service" ];
        after = [ "${unlockUnit}.service" ];
      };

      # A connected but locked disk must not silently fall back to NFS.
      systemd.services."${unit}-nfs".unitConfig.ConditionPathExists = lib.mkForce "!${source}";
    };

  mountLocalOrNfs =
    name: device: fsType:
    let
      unit = "watchtower-storage-${name}";
      mountPoint = "/mnt/wt-${name}";
      commonService = {
        partOf = [ "${unit}.target" ];
        restartIfChanged = false;
        unitConfig.ConditionPathIsMountPoint = "!${mountPoint}";
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          TimeoutStartSec = "30s";
          TimeoutStopSec = "30s";
          ExecStartPre = "/usr/bin/mkdir -p ${mountPoint}";
          ExecStop = "/usr/bin/umount ${mountPoint}";
        };
      };
    in
    {
      systemd.targets.${unit} = {
        description = "Watchtower ${name}: local disk or NFS";
        wantedBy = [ "multi-user.target" ];
        # Finish the optional mount attempts before allowing login.
        before = [
          "multi-user.target"
          "systemd-user-sessions.service"
          "display-manager.service"
        ];
        wants = [
          "${unit}-local.service"
          "${unit}-nfs.service"
        ];
      };

      systemd.services."${unit}-local" = lib.mkMerge [
        commonService
        {
          description = "Watchtower ${name}: local disk";
          after = [ "cryptsetup.target" ];
          unitConfig.ConditionPathExists = device;
          serviceConfig.ExecStart = "/usr/bin/mount -t ${fsType} -o defaults,nofail ${device} ${mountPoint}";
        }
      ];

      systemd.services."${unit}-nfs" = lib.mkMerge [
        commonService
        {
          description = "Watchtower ${name}: NFS when local disk is absent";
          wants = [ "network-online.target" ];
          after = [
            "${unit}-local.service"
            "network-online.target"
            "tailscaled.service"
          ];
          unitConfig.ConditionPathExists = "!${device}";
          serviceConfig.ExecStart = "/usr/bin/mount -t nfs -o rw,hard,nofail,_netdev,vers=4 ${nfsServer}:${mountPoint} ${mountPoint}";
        }
      ];

    };
in
{
  imports = [
    (mountLocalOrNfs "core" "/dev/mapper/watchtower-core" "btrfs")
    (mountLocalOrNfs "library" "/dev/disk/by-uuid/111c2127-50c6-4005-a541-e2441d7c2cba" "xfs")
    (mountLocalOrNfs "personal" "/dev/mapper/watchtower-personal" "btrfs")
    (unlockLuks "core" "8d79280b-06d8-4006-9540-325ccf44ae89" "/watchtower-core-key")
    (unlockLuks "personal" "d7210228-d2d7-4e2f-bb64-ce360035fd49" "/watchtower-personal-key")
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  # Fedora ainda não é uma distribuição oficialmente testada.
  system-manager.allowAnyDistro = true;

  # Não assumir o controle do Nix instalado no Fedora.
  nix.enable = false;
  systemd.mounts = [
    {
      what = "/dev/disk/by-uuid/c7af6ee8-a567-468b-94b6-e4f7e09d4d4c";
      where = "/mnt/ssd_256gb";
      type = "btrfs";
      options = "defaults,nofail";
      wantedBy = [ "local-fs.target" ];
    }
  ];

  # Primeiro teste de ativação.
  environment.etc."watchtower-system-manager-test".text = ''
    Managed by System Manager.
  '';
}
