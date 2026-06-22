{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      gcc
      rustup
    ];

    # activation.updateRust = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #   ${pkgs.rustup}/bin/rustup -q install stable
    #   ${pkgs.rustup}/bin/rustup -q update
    #   ${pkgs.rustup}/bin/rustup -q default stable
    # '';
  };
}
