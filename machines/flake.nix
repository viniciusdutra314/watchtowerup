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
      checksFor = prefix: build:
        nixpkgs.lib.mapAttrs' (name: config: nixpkgs.lib.nameValuePair "${prefix}-${name}" (build config));
    in
    {
      homeConfigurations."vinicius@wt-laptop" = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = sharedArgs // { inherit vocalinux; };
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
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
        modules = [ ./wt-devbox/home.nix ];
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
      checks.x86_64-linux =
        checksFor "home" (config: config.activationPackage) self.homeConfigurations
        // checksFor "nixos" (config: config.config.system.build.toplevel) self.nixosConfigurations;

      apps.x86_64-linux.home-manager = {
        type = "app";
        program = "${homeManager}/bin/home-manager";
      };

      devShells.x86_64-linux.bootstrap = pkgs.mkShellNoCC {
        packages = [ homeManager ];
      };

    };
}
