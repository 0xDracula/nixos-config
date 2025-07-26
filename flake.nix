{
  description = "Your new nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    hyprland.url = "github:hyprwm/Hyprland";

  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    stylix,
    ...
  } @ inputs: let
   inherit (nixpkgs.lib) genAttrs replaceStrings;
   inherit (nixpkgs.lib.filesystem) packagesFromDirectoryRecursive listFilesRecursive;
   inherit (self) outputs;
    systems = [
      "x86_64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
    nameOf = path: replaceStrings [ ".nix" ] [ "" ] (baseNameOf (toString path));
    pkgs = nixpkgs.legacyPackages."x86_64-linux";
  in {
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    overlays = import ./overlays {inherit inputs;};
    
    nixosModules = genAttrs (map nameOf (listFilesRecursive ./modules)) (
      name: import ./modules/nixos/${name}.nix
    );
    homeManagerModules = import ./modules/home;

    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs; nix-config = self;};
        modules = [
          stylix.nixosModules.stylix
          ./nixos/configuration.nix
          home-manager.nixosModules.home-manager
            {
              home-manager.users.dracula = ./home/home.nix;
              home-manager.extraSpecialArgs = { inherit inputs outputs; };
            }
        ];
      };
    };
    gtk.gtk2.force = true;
  };
}
