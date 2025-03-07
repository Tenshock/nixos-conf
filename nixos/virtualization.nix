user:
{ pkgs, ...}: {
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
    packages = with pkgs; [
      docker-compose
    ];
  };

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
