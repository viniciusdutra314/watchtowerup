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
    vocalinux = {
      url = "github:VocaHQ/vocalinux/v0.18.6";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      system-manager,
      nix-flatpak,
      ai-voice-usage,
      vocalinux,
      ...
    }:
    let
      sharedArgs = {
        IP_WT-LAPTOP = "100.90.150.48";
      };
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      homeManager = home-manager.packages.x86_64-linux.home-manager;
      systemManager = system-manager.packages.x86_64-linux.default;
      checksFor = prefix: build:
        nixpkgs.lib.mapAttrs' (name: config: nixpkgs.lib.nameValuePair "${prefix}-${name}" (build config));
      standaloneManagers = {
        # Home Manager installs its own CLI through programs.home-manager.enable.
        home.packages = [ systemManager ];
      };
    in
    {
      homeConfigurations."vinicius@wt-laptop" = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = sharedArgs // { inherit vocalinux; };
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          standaloneManagers
           nix-flatpak.homeManagerModules.nix-flatpak
          { home.packages = [ ai-voice-usage.packages.${pkgs.stdenv.hostPlatform.system}.default ]; }
          vocalinux.homeManagerModules.vocalinux
          ./wt-laptop/vocalinux.nix
          ./wt-laptop/home.nix
        ];
      };
      homeConfigurations."chloe@wt-devbox" = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = sharedArgs;
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ standaloneManagers ./wt-devbox/home.nix ];
      };
      nixosConfigurations.wt-server = nixpkgs.lib.nixosSystem {
        specialArgs = sharedArgs;
        system = "x86_64-linux";
        modules = [
          ./wt-server/system.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.extraSpecialArgs = sharedArgs;
            home-manager.users.vinicius = import ./wt-server/home.nix;
          }
        ];
      };
      systemConfigs.wt-devbox = system-manager.lib.makeSystemConfig {
        specialArgs = sharedArgs;
        modules = [ ./wt-devbox/system.nix ];
      };
      systemConfigs.wt-laptop = system-manager.lib.makeSystemConfig {
        specialArgs = sharedArgs;
        modules = [ ./wt-laptop/system.nix ];
      };

      checks.x86_64-linux =
        checksFor "home" (config: config.activationPackage) self.homeConfigurations
        // checksFor "system" (config: config) self.systemConfigs
        // checksFor "nixos" (config: config.config.system.build.toplevel) self.nixosConfigurations;

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
