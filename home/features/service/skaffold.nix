{ pkgs, ... }: { home = { packages = with pkgs; [ skaffold ]; }; }
