{
  description = "Flake for building Binary Ninja";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
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
          lib = nixpkgs.lib;
          sources = import ./sources.nix {
            inherit lib;
            inherit (pkgs) fetchurl requireFile;
          };
          variants = {
            system-qt = { };
            bundled-qt = {
              useSystemQt = false;
            };
            bundled-qt-fhs = {
              useSystemQt = false;
              useFHS = true;
            };
          };
          sets = lib.mapAttrs (
            _: args:
            let
              editions = lib.mapAttrs (
                binaryNinjaEdition: _: pkgs.callPackage ./package.nix (args // { inherit binaryNinjaEdition; })
              ) sources.editions;
            in
            editions
            // lib.mapAttrs' (
              name: package: lib.nameValuePair "${name}-wayland" (package.override { forceWayland = true; })
            ) editions
          ) variants;
          flat = lib.concatMapAttrs (
            variant: editions:
            lib.mapAttrs' (
              edition: package: lib.nameValuePair "binary-ninja-${edition}-${variant}" package
            ) editions
          ) sets;
          aliases = lib.mapAttrs' (
            edition: package: lib.nameValuePair "binary-ninja-${edition}" package
          ) sets.system-qt;
        in
        {
          inherit sets;
          packages = flat // aliases;
        };
    in
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        sources = pkgs.callPackage ./sources.nix { };
        variants = mkPackages pkgs;
      in
      {
        inherit (sources) version;
        checks = pkgs.lib.mapAttrs' (
          variant: editions:
          pkgs.lib.nameValuePair "simple-${variant}" (
            pkgs.callPackage ./tests/simple-nixos.nix {
              inherit self;
              package = editions.free;
            }
          )
        ) variants.sets;
        legacyPackages.binary-ninja = variants.sets;
        packages = variants.packages // {
          default = variants.packages.binary-ninja-free;
        };
      }
    )
    // {
      overlays.default =
        final: prev:
        let
          variants = mkPackages final;
        in
        variants.packages // { binary-ninja = variants.sets; };
      nixosModules.binaryninja = import ./module.nix inputs;
      darwinModules.binaryninja = import ./module.nix inputs;
      hmModules.binaryninja = import ./hm-module.nix inputs;
    };
}
