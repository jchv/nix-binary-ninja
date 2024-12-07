{ lib, pkgs, ... }:
{
  options = {
    programs.binary-ninja = {
      enable = lib.mkEnableOption "Binary Ninja";
      package = lib.mkOption {
        type = lib.types.package;
        description = ''
          Package to install. Defaults to the free (as in beer) edition of Binary Ninja.

          This overlay provides the following editions:
          - `binary-ninja-free`
          - `binary-ninja-personal`
          - `binary-ninja-commercial`
          - `binary-ninja-ultimate`
          - `binary-ninja-free-wayland`
          - `binary-ninja-personal-wayland`
          - `binary-ninja-commercial-wayland`
          - `binary-ninja-ultimate-wayland`
        '';
        default = pkgs.binary-ninja-free;
        defaultText = lib.literalExpression ''pkgs.binary-ninja-free'';
        example = lib.literalExpression ''
          pkgs.binary-ninja-personal-wayland.override {
            # Use a local copy of Binary Ninja, stored in your Nix configuration.
            # (Please be mindful to not leak your licensed copy of binary ninja.)
            overrideSource = ./binaryninja_personal_linux.zip;
          };
        '';
      };
    };
  };
}
