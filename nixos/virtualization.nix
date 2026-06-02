user:
{ pkgs, ... }: {
  virtualisation = {
    podman = {
      enable = false;
      dockerSocket.enable = true;
      dockerCompat = true;

      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    docker = {
      enable = true;
      enableOnBoot = false;

      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };

  users.users.${user} = {
    extraGroups = [ "podman" "docker" ]; # Necessary for dockerSocket option.
    packages = with pkgs; [ docker-compose ];
  };

  services.k3s = {
    enable = false;
    extraFlags =
      [ "--write-kubeconfig-mode 640" "--write-kubeconfig-group wheel" ];
  };

  # environment.variables = { KUBECONFIG = "/etc/rancher/k3s/k3s.yaml"; };
  environment.variables = { KUBECONFIG = "/home/${user}/.kube/config"; };

  programs.zsh.shellAliases = { k = "k3s kubectl"; };
}
