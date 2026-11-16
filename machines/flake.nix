{
  description = "Watchtower Infrastructure";
  inputs = {
    ai-voice-usage = {
      url = "github:viniciusdutra314/AI-VoiceUsage";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      ai-voice-usage,
      ...
    }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      homeManager = home-manager.packages.x86_64-linux.home-manager;
      systemManager = system-manager.packages.x86_64-linux.default;
      standaloneManagers = {
        # Home Manager installs its own CLI through programs.home-manager.enable.
        home.packages = [ systemManager ];
      };
    in
    {
      homeConfigurations."vinicius@wt-laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          standaloneManagers
           nix-flatpak.homeManagerModules.nix-flatpak
          { home.packages = [ ai-voice-usage.packages.${pkgs.stdenv.hostPlatform.system}.default ]; }
          ./wt-laptop/home.nix
        ];
      };
      homeConfigurations."chloe@wt-devbox" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ standaloneManagers ./wt-devbox/home.nix ];
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
      systemConfigs.wt-devbox = system-manager.lib.makeSystemConfig {
        modules = [ ./wt-devbox/system.nix ];
      };
      systemConfigs.wt-laptop = system-manager.lib.makeSystemConfig {
        modules = [ ./wt-laptop/system.nix ];
      };
      apps.x86_64-linux.home-manager = {
        type = "app";
        program = "${homeManager}/bin/home-manager";
      };

      apps.x86_64-linux.system-manager = {
        type = "app";
        program = "${systemManager}/bin/system-manager";
      };

      devShells.x86_64-linux.bootstrap = pkgs.mkShellNoCC {
        packages = [ homeManager systemManager ];
      };

    };
}
