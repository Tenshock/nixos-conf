{ pkgs, ... }: {
  virtualisation.podman.enable = true;

  services.k3s = {
    enable = true;
    extraFlags = [
      "--write-kubeconfig-mode 640"
      "--write-kubeconfig-group wheel"
    ];
  };

  environment.systemPackages = with pkgs; [
    k9s
  ];

  programs.zsh.shellAliases = {
    k = "k3s kubectl";
  };
}
