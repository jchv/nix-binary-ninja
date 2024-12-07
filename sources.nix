{
  lib,
  requireFile,
  fetchurl,
  ...
}:
let
  data = builtins.fromJSON (builtins.readFile ./hashes.js);
  version = lib.head (lib.splitString " " data.version);
  editions = [
    "free"
    "personal"
    "commercial"
    "ultimate"
  ];
  mkFreeSource =
    name:
    fetchurl {
      url = "https://cdn.binary.ninja/installers/${name}";
      sha256 = data.hashes.${name};
    };
  mkSource =
    name:
    requireFile {
      inherit name;
      url = "https://binary.ninja/recover/";
      sha256 = data.hashes.${name};
    };
  mkEditionNames = edition: {
    aarch64-darwin = "binaryninja_${edition}_macosx.dmg";
    aarch64-linux = "binaryninja_${edition}_linux_arm.zip";
    x86_64-darwin = "binaryninja_${edition}_macosx.dmg";
    x86_64-linux = "binaryninja_${edition}_linux.zip";
    x86_64-windows = "binaryninja_${edition}_win64.exe";
  };
in
{
  inherit version;
  editions = builtins.listToAttrs (
    map (edition: {
      name = edition;
      value = lib.mapAttrs (name: file: if edition == "free" then mkFreeSource file else mkSource file) (
        mkEditionNames edition
      );
    }) editions
  );
}
