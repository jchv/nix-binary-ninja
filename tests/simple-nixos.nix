{
  self,
  pkgs,
  package ? pkgs.binary-ninja-free,
}:
pkgs.callPackage ./simple-common.nix {
  nodes.machine = {
    imports = [
      self.nixosModules.binaryninja
      (self.inputs.nixpkgs + "/nixos/tests/common/x11.nix")
      (self.inputs.nixpkgs + "/nixos/tests/common/user-account.nix")
    ];

    virtualisation.memorySize = 768;
    test-support.displayManager.auto.user = "alice";
    services.xserver.enable = true;
    programs.binary-ninja.enable = true;
    programs.binary-ninja.package = package;

    system.stateVersion = "24.11";
  };
}
