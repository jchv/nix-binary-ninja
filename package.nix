{
  lib,
  stdenv,
  callPackage,
  autoPatchelfHook,
  buildFHSEnv,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  unzip,
  libGL,
  zlib,
  freetype,
  libx11,
  libxcb,
  glib,
  fontconfig,
  libxi,
  libxrender,
  libxcb-image,
  libxcb-render-util,
  libxcb-wm,
  libxcb-keysyms,
  libxcb-cursor,
  dbus,
  libxkbcommon,
  wayland,
  kdePackages,
  python313,
  libxml2_13,
  curl,
  openssl,
  libdrm,

  binaryNinjaEdition ? "personal",
  forceWayland ? false,
  overrideSource ? null,
  useSystemQt ? true,
  useFHS ? false,
}:
assert lib.assertMsg (!useFHS || !useSystemQt) "Can not use system Qt with FHS wrapper";
let
  sources = callPackage ./sources.nix { };
  platformSources = sources.editions.${binaryNinjaEdition};
  source =
    if overrideSource != null then
      overrideSource
    else if builtins.hasAttr stdenv.hostPlatform.system platformSources then
      platformSources.${stdenv.hostPlatform.system}
    else
      throw "No source for system ${stdenv.hostPlatform.system}";
  desktopIcon = builtins.path {
    path = ./logo.png;
  };
  python3 = python313;
  runtimeLibraries = [
    stdenv.cc.cc.lib
    libGL
    zlib
    freetype
    libx11
    libxcb
    glib
    fontconfig
    libxi
    libxrender
    libxcb-image
    libxcb-render-util
    libxcb-wm
    libxcb-keysyms
    libxcb-cursor
    libxkbcommon
    dbus
    wayland
    # LLDB needs the libxml2.so.2 ABI.
    libxml2_13
    curl
    openssl
    libdrm
    python3
  ];
  package = stdenv.mkDerivation {
    pname = "binary-ninja-${binaryNinjaEdition}-${
      if useSystemQt then "system-qt" else "bundled-qt"
    }${lib.optionalString useFHS "-unwrapped"}";
    inherit (sources) version;
    src = source;
    nativeBuildInputs = [
      makeWrapper
      python3.pkgs.wrapPython
      copyDesktopItems
      unzip
    ]
    ++ lib.optional (!useFHS) autoPatchelfHook
    ++ lib.optional useSystemQt kdePackages.wrapQtAppsHook;
    buildInputs =
      lib.optionals (!useFHS) runtimeLibraries
      ++ lib.optionals useSystemQt [
        kdePackages.qtbase
        kdePackages.qtdeclarative
        kdePackages.qtwayland
        kdePackages.qtsvg
      ];
    pythonDeps = [ python3.pkgs.pip ];
    appendRunpaths = [ "${lib.getLib python3}/lib" ];
    dontBuild = true;
    dontStrip = true;
    dontPatchELF = useFHS;

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
      mkdir -p $out/opt/binaryninja
      mkdir -p $out/share/pixmaps
      cp -a . $out/opt/binaryninja/
      ${lib.optionalString useSystemQt ''
        find "$out/opt/binaryninja" \( -type f -o -type l \) -name 'libQt6*.so*' -delete
        rm -rf "$out/opt/binaryninja/qt"
        rm -f "$out/opt/binaryninja/python3/PySide6/Qt/plugins"
        rm -f "$out/opt/binaryninja/qt.conf"
      ''}
      ${lib.optionalString (!useFHS) ''
        addAutoPatchelfSearchPath "$out/opt/binaryninja"
      ''}
      cp ${desktopIcon} $out/share/pixmaps/binaryninja.png
      chmod +x $out/opt/binaryninja/binaryninja
      buildPythonPath "$pythonDeps"
      makeWrapper $out/opt/binaryninja/binaryninja $out/bin/binaryninja \
        --prefix PYTHONPATH : "$program_PYTHONPATH" \
        ${lib.optionalString forceWayland "--set QT_QPA_PLATFORM wayland"} \
        ${
          if useSystemQt then
            ''"''${qtWrapperArgs[@]}"''
          else
            ''
              --unset QML2_IMPORT_PATH \
              --unset QML_IMPORT_PATH \
              --unset QT_QPA_PLATFORM_PLUGIN_PATH \
              --set QT_PLUGIN_PATH "$out/opt/binaryninja/qt"
            ''
        }

      runHook postInstall
    '';

    runtimeDependencies = [ (lib.getLib openssl) ];

    dontWrapQtApps = true;
    meta = {
      mainProgram = "binaryninja";
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
  };
in
if useFHS then
  buildFHSEnv {
    pname = "binary-ninja-${binaryNinjaEdition}-bundled-qt-fhs";
    inherit (package) version meta;
    executableName = "binaryninja";
    targetPkgs = _: runtimeLibraries;
    multiPkgs = _: [ ];
    runScript = "${package}/bin/binaryninja";
    extraInstallCommands = ''
      ln -s ${package}/share "$out/share"
    '';
    passthru.unwrapped = package;
  }
else
  package
