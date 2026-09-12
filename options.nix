{ lib, pkgs, ... }:
{
  options = {
    programs.binary-ninja = {
      enable = lib.mkEnableOption "Binary Ninja";
      package = lib.mkOption {
        type = lib.types.package;
        description = ''
          Package to install. Defaults to the free (as in beer) edition of Binary Ninja
          using system Qt (for compatibility with previous versions of this flake.)

          This overlay provides three different variants of each package:
          - `binary-ninja.system-qt`
          - `binary-ninja.bundled-qt`
          - `binary-ninja.bundled-qt-fhs`

          Which each provide the following attributes:
          - `free`
          - `personal`
          - `commercial`
          - `ultimate`
          - `free-wayland`
          - `personal-wayland`
          - `commercial-wayland`
          - `ultimate-wayland`

          e.g. `pkgs.binary-ninja.bundled-qt.personal-wayland`.
        '';
        default = pkgs.binary-ninja-free;
        defaultText = lib.literalExpression "pkgs.binary-ninja-free";
        example = lib.literalExpression ''
          pkgs.binary-ninja.bundled-qt.personal-wayland.override {
            # Use a local copy of Binary Ninja, stored in your Nix configuration.
            # (Please be mindful to not leak your licensed copy of binary ninja.)
            overrideSource = ./binaryninja_personal_linux.zip;
          };
        '';
      };
    };
  };
}
