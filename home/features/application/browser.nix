{
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
