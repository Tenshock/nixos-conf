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
nix-shell --run update-rolling-pins
nh os build -f ./system.nix
```

Inspect the build result before activating it. Activation is an explicit,
separate step:

```bash
nh os switch -f ./system.nix
```
