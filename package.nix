{
  lib,
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
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/opt
    cp -r * $out/opt
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
