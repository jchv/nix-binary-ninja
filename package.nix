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
  libxkbcommon,
  wayland-scanner,
  kdePackages,
  python3,

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
    wayland-scanner.out
  ];
  pythonDeps = [ python3.pkgs.pip ];
  buildPhase = ":";
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/opt
    cp -r * $out/opt
    chmod +x $out/opt/binaryninja
    buildPythonPath "$pythonDeps"
    makeWrapper $out/opt/binaryninja $out/bin/binaryninja \
      --prefix LD_LIBRARY_PATH : "${python3}/lib" \
      --prefix PYTHONPATH : "$program_PYTHONPATH" \
      "''${qtWrapperArgs[@]}"

    runHook postInstall
  '';
  dontWrapQtApps = true;
  meta = {
    mainProgram = "binaryninja";
  };
}
