user: { pkgs, lib, ... }: {
  environment = {
    systemPackages = with pkgs; [
      pkg-config
      openssl
      openssl.dev
    ];
    sessionVariables.PKG_CONFIG_PATH = lib.makeSearchPath "lib/pkgconfig" [ pkgs.openssl.dev ];
  };
}
