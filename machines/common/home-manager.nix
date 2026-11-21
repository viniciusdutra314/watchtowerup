{ config, lib, ... }:
{
  options.watchtower.homeManager.repositoryDirectory = lib.mkOption {
    type = lib.types.str;
    default = "/mnt/wt-core/watchtowerup";
    description = "Absolute path to the local Watchtower checkout.";
  };

  config = {
    programs.home-manager.enable = true;

    # Let the standard CLI discover the writable checkout from any directory.
    xdg.configFile."home-manager".source = config.lib.file.mkOutOfStoreSymlink
      "${config.watchtower.homeManager.repositoryDirectory}/machines";
  };
}
