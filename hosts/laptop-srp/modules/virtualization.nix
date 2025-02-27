{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    k9s
  ];

  programs.zsh.shellAliases = {
    k = "k3s kubectl";
  };

  # virtualisation
  virtualisation.podman.enable = true;
  services.k3s.enable = true;

  services.k3s.extraFlags = [
    "--write-kubeconfig-mode 640"
    "--write-kubeconfig-group wheel"
  ];
}
