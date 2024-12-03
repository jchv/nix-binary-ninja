{
  lib,
  stdenv,
  callPackage,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  unzip,
  libGL,
  glib,
  fontconfig,
  xorg,
  dbus,
  libxkbcommon,
  wayland,
  kdePackages,
  python3,

  binaryNinjaEdition ? "personal",
  forceWayland ? false,
}:
let
  sources = callPackage ./sources.nix { };
  platformSources = sources.editions.${binaryNinjaEdition};
  source =
    if builtins.hasAttr stdenv.hostPlatform.system platformSources then
      platformSources.${stdenv.hostPlatform.system}
    else
      throw "No source for system ${stdenv.hostPlatform.system}";
  desktopItem = fetchurl {
    url = "https://docs.binary.ninja/img/logo.png";
    hash = "sha256-TzGAAefTknnOBj70IHe64D6VwRKqIDpL4+o9kTw0Mn4=";
  };
in
stdenv.mkDerivation {
  pname = "binary-ninja";
  inherit (sources) version;
  src = source;
  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
    python3.pkgs.wrapPython
    kdePackages.wrapQtAppsHook
    copyDesktopItems
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
    wayland
  ];
  pythonDeps = [ python3.pkgs.pip ];
  appendRunpaths = [ "${lib.getLib python3}/lib" ];
  qtWrapperArgs = lib.optionals forceWayland [
    "--set"
    "QT_QPA_PLATFORM"
    "wayland"
  ];
  buildPhase = ":";

  desktopItems = [
    (makeDesktopItem {
      name = "Binary Ninja";
      exec = "binaryninja";
      icon = "binaryninja";
      desktopName = "Binary Ninja";
      comment = "Binary Ninja is an interactive decompiler, disassembler, debugger, and binary analysis platform built by reverse engineers, for reverse engineers";
      categories = [ "Development" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/opt
    mkdir -p $out/share/pixmaps
    cp -r * $out/opt
    cp ${desktopItem} $out/share/pixmaps/binaryninja.png
    chmod +x $out/opt/binaryninja
    buildPythonPath "$pythonDeps"
    makeWrapper $out/opt/binaryninja $out/bin/binaryninja \
      --prefix PYTHONPATH : "$program_PYTHONPATH" \
      "''${qtWrapperArgs[@]}"

    runHook postInstall
  '';
  dontWrapQtApps = true;
  meta = {
    mainProgram = "binaryninja";
  };
}
