{ pkgs, ... }: {
  home = {
    packages = with pkgs; [ nssTools ];
  };
}
