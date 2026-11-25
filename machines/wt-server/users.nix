{ pkgs, ... }:
{
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
    ];
    packages = with pkgs; [ ];
  };

  programs.bash.loginShellInit = ''
    if [[ $- == *i* && "$USER" == "vinicius" ]]; then
      if [[ -d /mnt/wt-core/watchtowerup ]]; then
        cd /mnt/wt-core/watchtowerup
      fi
    fi
  '';
}
