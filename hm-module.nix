{ self, ... }:
{ config, lib, ... }:
let
  cfg = config.programs.binary-ninja;
in
{
  imports = [
    ./options.nix
  ];

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ self.overlays.default ];
    home.packages = [ cfg.package ];
  };
}
