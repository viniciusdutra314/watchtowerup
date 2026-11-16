{ config, lib, pkgs, ... }:
{
  options.watchtower.codex.skillsDirectory = lib.mkOption {
    type = lib.types.str;
    default = "/mnt/wt-core/watchtowerup/chloe/skills";
    description = "Absolute path to the skills directory in the local Watchtower checkout.";
  };

  options.watchtower.codex.configFile = lib.mkOption {
    type = lib.types.str;
    default = "/mnt/wt-core/watchtowerup/machines/common/codex/config.toml";
    description = "Absolute path to the writable Codex config in the local Watchtower checkout.";
  };

  config = {
    home.packages = [ pkgs.codex ];
    home.file.".codex/config.toml".source = config.lib.file.mkOutOfStoreSymlink
      config.watchtower.codex.configFile;
    home.file.".agents/skills".source = config.lib.file.mkOutOfStoreSymlink
      config.watchtower.codex.skillsDirectory;
  };
}
