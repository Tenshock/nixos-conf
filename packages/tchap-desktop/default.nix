{
  lib,
  stdenv,
  fetchzip,
  element-desktop,
  makeDesktopItem,
}:

let
  tchapVersion = "4.21.1";
  webArchive = "tchap-4.21.1-prod-20260722.tar.gz";

  tchap-web = fetchzip {
    name = "tchap-web-${tchapVersion}";
    url = "https://github.com/tchapgouv/tchap-web-v4/releases/download/tchap-${tchapVersion}/${webArchive}";
    hash = "sha256-6WDxTk+As+wbNy3hTLvxT+hnkCJpkF6PJoC3tcL5WpU=";
  };

  element-desktop-tchap = element-desktop.override {
    element-web = tchap-web;
    commandLineArgs = "--no-update --password-store=gnome-libsecret";
  };
in
element-desktop-tchap.overrideAttrs (oldAttrs: {
  pname = "tchap-desktop";
  name = "tchap-desktop-${tchapVersion}";

  env = (oldAttrs.env or { }) // {
    VARIANT_PATH = "${./variant.json}";
  };

  postPatch = (oldAttrs.postPatch or "") + ''
    cp ${tchap-web}/vector-icons/512.png apps/desktop/build/icon.png
  '';

  postInstall =
    (oldAttrs.postInstall or "")
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      mv "$out/bin/element-desktop" "$out/bin/tchap-desktop"

      rm "$out/share/icons/hicolor/512x512/apps/element.png"
      install -Dm644 ${tchap-web}/vector-icons/512.png \
        "$out/share/element/build/icon.png"
      ln -s "$out/share/element/build/icon.png" \
        "$out/share/icons/hicolor/512x512/apps/tchap.png"
    '';

  desktopItems = [
    (makeDesktopItem {
      name = "tchap-desktop";
      exec = "tchap-desktop %u";
      icon = "tchap";
      desktopName = "Tchap";
      genericName = "Messagerie instantanée";
      comment = "Messagerie instantanée du secteur public français";
      categories = [
        "Network"
        "InstantMessaging"
        "Chat"
      ];
      startupWMClass = "Tchap";
      mimeTypes = [ "x-scheme-handler/tchap" ];
    })
  ];

  passthru = (oldAttrs.passthru or { }) // {
    inherit tchap-web tchapVersion;
    elementDesktopVersion = element-desktop.version;
  };

  meta = oldAttrs.meta // {
    description = "Tchap web client packaged with the Element Desktop Electron shell";
    homepage = "https://github.com/tchapgouv/tchap-desktop";
    license = [
      lib.licenses.agpl3Plus
      lib.licenses.gpl3Plus
    ];
    platforms = lib.platforms.linux;
    mainProgram = "tchap-desktop";
  };
})
