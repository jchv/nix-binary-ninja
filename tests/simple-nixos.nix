{ self, pkgs }:
pkgs.callPackage ./simple-common.nix {
  nodes.machine = {
    imports = [
      self.nixosModules.binaryninja
      (self.inputs.nixpkgs + "/nixos/tests/common/x11.nix")
      (self.inputs.nixpkgs + "/nixos/tests/common/user-account.nix")
    ];

    test-support.displayManager.auto.user = "alice";
    services.xserver.enable = true;
    programs.binary-ninja.enable = true;

    system.stateVersion = "24.11";
  };
}
