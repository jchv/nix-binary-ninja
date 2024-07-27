{
  description = "Flake for building Binary Ninja";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
        sources = pkgs.callPackage ./sources.nix { };
        editions = lib.mapAttrs' (binaryNinjaEdition: value: {
          name = "binary-ninja-${binaryNinjaEdition}";
          value = pkgs.callPackage ./package.nix { inherit binaryNinjaEdition; };
        }) sources.editions;
        packages = editions // {
          default = editions.binary-ninja-free;
        };
      in
      {
        inherit packages;
      }
    );
}
