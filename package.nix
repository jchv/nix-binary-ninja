{
  stdenv,
  callPackage,
  autoPatchelfHook,
  makeWrapper,
  unzip,
  libGL,
  glib,
  fontconfig,
  xorg,
  dbus,
  xkeyboard_config,
  libxkbcommon,
  wayland-scanner,
  kdePackages,

  binaryNinjaEdition ? "personal",
}:
let
  sources = callPackage ./sources.nix { };
  platformSources = sources.editions.${binaryNinjaEdition};
  source =
    if builtins.hasAttr stdenv.hostPlatform.system platformSources then
      platformSources.${stdenv.hostPlatform.system}
    else
      throw "No source for system ${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation {
  pname = "binary-ninja";
  inherit (sources) version;
  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
    kdePackages.wrapQtAppsHook
  ];
  buildInputs = [
    unzip
    libGL
    glib
    fontconfig
    xorg.libXi
    xorg.libXrender
    xorg.xcbutilimage
    xorg.xcbutilrenderutil
    kdePackages.qtbase
    kdePackages.qtdeclarative
    libxkbcommon
    dbus
    wayland-scanner.out
  ];
  src = source;
  buildPhase = ":";
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/opt
    cp -r * $out/opt
    chmod +x $out/opt/binaryninja
    makeWrapper $out/opt/binaryninja \
          $out/bin/binaryninja \
          --prefix "QT_XKB_CONFIG_ROOT" ":" "${xkeyboard_config}/share/X11/xkb"

    runHook postInstall
  '';
}
