{ pkgs, ... }: {
  home.packages = with pkgs; [
  ]
  ++ lib.optionals (!pkgs.stdenv.isDarwin) [
      google-chrome
    ];

  programs = {
    librewolf = {
      enable = true;
      settings = {
        "browser.safebrowsing.malware.enabled" = false;
        "browser.safebrowsing.phishing.enabled" = false;
        "browser.safebrowsing.blockedURIs.enabled" = false;
      };
    };

    firefox.enable = true;
  };
}
