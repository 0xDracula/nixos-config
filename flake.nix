{
  description = "Your new nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-stable.url = "github:nixos/nixpkgs/nixos";
    
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
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    espanso-fix.url = "github:pitkling/nixpkgs/espanso-fix-capabilities-export";
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    stylix,
    espanso-fix,
    nixos-hardware,
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
    
    #nixosModules = genAttrs (map nameOf (listFilesRecursive ./modules)) (
      #name: import ./modules/nixos/${name}.nix
    #);
    homeManagerModules = import ./modules/home;

    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs; nix-config = self;};
        modules = [
          stylix.nixosModules.stylix
          espanso-fix.nixosModules.espanso-capdacoverride
          ./nixos/configuration.nix
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-gpu-nvidia
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          home-manager.nixosModules.home-manager
            {
              home-manager.users.dracula = ./home/home.nix;
              home-manager.extraSpecialArgs = { inherit inputs outputs; };
              home-manager.backupFileExtension = "backup";
            }
        ];
      };
    };
    gtk.gtk2.force = true;
  };
}
