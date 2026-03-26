{
  description = "NixOS";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    # Spicetify
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";


    quickshell = {
      # add ?ref=<tag> to track a tag
      url = "github:quickshell-mirror/quickshell";

      # THIS IS IMPORTANT
      # Mismatched system dependencies will lead to crashes and other issues.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs: {
    nixosConfigurations.nixie = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        ./modules/common/default.nix
        ./modules/shared/gaming.nix

        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;


            extraSpecialArgs = { inherit inputs; };


            backupFileExtension = "backup";
          };
        }
      ];
    };
  };
}