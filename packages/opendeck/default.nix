{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  rustPlatform,
  cargo-tauri,
  deno,
  nodejs,
  cacert,
  runCommand,
  pkg-config,
  wrapGAppsHook4,
  dbus,
  glib-networking,
  libayatana-appindicator,
  libei,
  libglvnd,
  libxkbcommon,
  openssl,
  udev,
  wayland,
  webkitgtk_4_1,
  libX11,
  libXcursor,
  libXi,
  libXrandr,
  libXtst,
}:

let
  pname = "opendeck";
  version = "2.13.1";
  pluginLibraryPath = lib.makeLibraryPath [
    libglvnd
    libX11
    libXcursor
    libXi
    libxkbcommon
    libXrandr
    wayland
  ];

  src = fetchFromGitHub {
    owner = "nekename";
    repo = "OpenDeck";
    tag = "v${version}";
    hash = "sha256-eFkdLSm6jgXLQjNgCxEwgNpYVH+lDzefd14FY3/2EAg=";
  };

  denoDeps = stdenvNoCC.mkDerivation {
    pname = "${pname}-deno-deps";
    inherit version src;

    nativeBuildInputs = [
      cacert
      deno
    ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      export DENO_DIR="$PWD/deno-dir"
      deno install --frozen
      deno cache --lock=deno.lock plugins/com.amansprojects.starterpack.sdPlugin/build.ts

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      cp -R node_modules "$out/"
      cp -R "$DENO_DIR" "$out/deno-dir"

      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-1oLPNBX8JRx2ASl2cXZ74sz3k4vvwUXPkLRfzNU5V1k=";
  };

  mainCargoDeps = rustPlatform.fetchCargoVendor {
    name = "${pname}-${version}-main-cargo-deps";
    inherit src;
    cargoRoot = "src-tauri";
    hash = "sha256-LRCZetPg4222zS/5M4ojiCcxECsDrTbXlsQaFo66qSQ=";
  };

  starterpackCargoDeps = rustPlatform.fetchCargoVendor {
    name = "${pname}-${version}-starterpack-cargo-deps";
    inherit src;
    cargoRoot = "plugins/com.amansprojects.starterpack.sdPlugin";
    hash = "sha256-s8GPWbPMJY9XTTC4QajY2sYUXcJ0g2OSl/YYhK/UZLQ=";
  };

  cargoDeps = runCommand "${pname}-${version}-cargo-deps" { } ''
    mkdir -p "$out"
    cp -R --no-preserve=mode,ownership ${mainCargoDeps}/. "$out/"
    chmod -R u+w "$out"
    cp -R --no-preserve=mode,ownership \
      ${starterpackCargoDeps}/source-registry-0/. \
      "$out/source-registry-0/"
    cp -R --no-preserve=mode,ownership \
      ${starterpackCargoDeps}/source-git-0 \
      "$out/source-git-3"

    printf '%s\n' \
      "" \
      "[source.vendored-source-git-3]" \
      'directory = "@vendor@/source-git-3"' \
      "" \
      "[source.original-source-git-3]" \
      'git = "https://github.com/enigo-rs/enigo.git"' \
      'rev = "4cb8833144e6e5e679b91ae7fd53507f9abf751d"' \
      'replace-with = "vendored-source-git-3"' \
      >>"$out/.cargo/config.toml"
  '';
in
rustPlatform.buildRustPackage {
  inherit
    pname
    version
    src
    cargoDeps
    ;

  cargoRoot = "src-tauri";
  buildAndTestSubdir = "src-tauri";

  nativeBuildInputs = [
    cargo-tauri.hook
    deno
    nodejs
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    dbus
    glib-networking
    libayatana-appindicator
    libei
    libxkbcommon
    openssl
    udev
    wayland
    webkitgtk_4_1
    libX11
    libXtst
  ];

  postPatch = ''
    substituteInPlace src-tauri/tauri.conf.json \
      --replace-fail '"beforeBuildCommand": "deno task build",' '"beforeBuildCommand": "",'

    substituteInPlace src-tauri/build.rs \
      --replace-fail \
        '"run",' \
        '"run", "--cached-only", "--frozen",' \
      --replace-fail \
        '"--lock=target/deno.lock",' \
        '"--lock=../../deno.lock",'

    substituteInPlace plugins/com.amansprojects.starterpack.sdPlugin/build.ts \
      --replace-fail \
        'args: ["install", "--path",' \
        'args: ["install", "--locked", "--offline", "--path",' \
      --replace-fail \
        'new Deno.Command("cargo", {' \
        'new Deno.Command("cargo", { env: { CARGO_TARGET_DIR: join(Deno.env.get("TMPDIR")!, "opendeck-starterpack-target") },'

    substituteInPlace "$cargoDepsCopy"/*/libappindicator-sys-*/src/lib.rs \
      --replace-fail \
        "libayatana-appindicator3.so.1" \
        "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
  '';

  preBuild = ''
    cp -R ${denoDeps}/node_modules .
    chmod -R u+w node_modules

    export DENO_DIR="$TMPDIR/deno-dir"
    cp -R ${denoDeps}/deno-dir "$DENO_DIR"
    chmod -R u+w "$DENO_DIR"

    node node_modules/vite/bin/vite.js build
  '';

  postInstall = ''
    install -Dm644 \
      src-tauri/bundle/40-streamdeck.rules \
      "$out/lib/udev/rules.d/40-streamdeck.rules"
  '';

  postFixup = ''
    wrapProgram "$out/bin/opendeck" \
      --prefix LD_LIBRARY_PATH : "${pluginLibraryPath}"
  '';

  doCheck = false;

  meta = {
    description = "Desktop application for Stream Deck devices";
    homepage = "https://github.com/nekename/OpenDeck";
    changelog = "https://github.com/nekename/OpenDeck/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    mainProgram = "opendeck";
    platforms = [ "x86_64-linux" ];
  };
}
