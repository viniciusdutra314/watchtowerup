{
  description = "Watchtower Infrastructure";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
     nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.8.0";
  };
  
  outputs =
    {
      nixpkgs,
      home-manager,
      system-manager,
      nix-flatpak,
      ...
    }:
    {
      homeConfigurations."vinicius@wt-laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
           nix-flatpak.homeManagerModules.nix-flatpak
          ./wt-laptop/home.nix
        ];
      };
      homeConfigurations."chloe@wt-devbox" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./wt-devbox/home.nix ];
      };
      nixosConfigurations.wt-server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./wt-server/system.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.users.vinicius = import ./wt-server/home.nix;
          }
        ];
      };
      systemConfigs.devbox = system-manager.lib.makeSystemConfig {
        modules = [ ./wt-devbox/system.nix ];
      };
      systemConfigs.laptop = system-manager.lib.makeSystemConfig {
        modules = [ ./wt-laptop/system.nix ];
      };
      apps.x86_64-linux.home-manager = {
        type = "app";
        program = "${home-manager.packages.x86_64-linux.home-manager}/bin/home-manager";
      };

      apps.x86_64-linux.system-manager = {
        type = "app";
        program = "${system-manager.packages.x86_64-linux.default}/bin/system-manager";
      };

    };
}
