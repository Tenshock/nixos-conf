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
