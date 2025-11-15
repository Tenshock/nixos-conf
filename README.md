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
mkdir  ~/.config/home-manager
cd nixos
sudo ln -sfn $(pwd)/*  ~/.config/home-manager
```

Then, for the first time, run
```bash
cd ~/.config/nixos
nix flake update --extra-experimental-features nix-command --extra-experimental-features flakes
sudo nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake ~/.config/home-manager
```

Finally, you can build the configuration as follows:
```bash
cd ~/.config/nixos
nix flake update
nh darwin switch
```

