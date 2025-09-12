user:
{ pkgs, ... }: {
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    dockerCompat = true;

    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  users.users.${user} = {
    extraGroups = [ "podman" ]; # Necessary for dockerSocket option.
    packages = with pkgs; [ docker-compose ];
  };

  services.k3s = {
    # enable = true;
    enable = false;
    extraFlags =
      [ "--write-kubeconfig-mode 640" "--write-kubeconfig-group wheel" ];
  };

  environment.variables = { KUBECONFIG = "/etc/rancher/k3s/k3s.yaml"; };

  programs.zsh.shellAliases = { k = "k3s kubectl"; };
}
