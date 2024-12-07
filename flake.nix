{
  description = "Flake for building Binary Ninja";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      mkPackages =
        pkgs:
        let
          lib = pkgs.lib;
          sources = import ./sources.nix pkgs;
          editions = lib.mapAttrs' (binaryNinjaEdition: value: {
            name = "binary-ninja-${binaryNinjaEdition}";
            value = pkgs.callPackage ./package.nix { inherit binaryNinjaEdition; };
          }) sources.editions;
          editionsWayland = lib.mapAttrs' (name: value: {
            name = "${name}-wayland";
            value = value.override { forceWayland = true; };
          }) editions;
        in
        editions // editionsWayland;
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        sources = pkgs.callPackage ./sources.nix { };
        packages = mkPackages pkgs;
      in
      {
        inherit (sources) version;
        checks = {
          simple = pkgs.callPackage ./tests/simple-nixos.nix { inherit self; };
        };
        packages = packages // {
          default = packages.binary-ninja-free;
        };
      }
    )
    // {
      overlays.default = final: prev: mkPackages prev;
      nixosModules.binaryninja = import ./module.nix inputs;
      darwinModules.binaryninja = import ./module.nix inputs;
      hmModules.binaryninja = import ./hm-module.nix inputs;
    };
}
