# NixOS configuration

> heavily inspired by https://github.com/kaleocheng/nix-dots

## Installation NixOS

```bash
cd ~/.config
git clone git@github.com:Tenshock/nixos-conf.git nixos
sudo ln -sfn $(pwd)/*  /etc/nixos
```

Then, you can build the configuration as follows:
```bash
cd ~/.config/nixos
sudo nix flake update
nh os switch

```

## Installation MacOS

First, install Nix package manager: https://nixos.org/download/

Then, clone this repository as following:
```bash
cd ~/.config
git clone git@github.com:Tenshock/nixos-conf.git nixos
sudo ln -sfn $(pwd)/*  ~/.config/home-manager
```

Finally, you can build the configuration as follows:
```bash
cd ~/.config/nixos
sudo nix flake update
sudo nix run nix-darwin -- switch --flake ~/.config/nixos
# or
nh darwin switch
```



