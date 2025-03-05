{
  virtualisation.podman.enable = true;

  services.k3s = {
    enable = true;
    extraFlags = [
      "--write-kubeconfig-mode 640"
      "--write-kubeconfig-group wheel"
    ];
  };

  # TODO: make k9s target k3s
  programs.zsh.shellAliases = {
    k = "k3s kubectl";
  };
}
