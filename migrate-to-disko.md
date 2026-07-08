# Migrate Framework 13 Storage Ownership To Disko

This runbook moves this Framework 13 NixOS config to `nix-community/disko`
as the single declarative owner for partitions, LUKS, LVM, filesystems, swap,
and hibernation resume.

This is not a repartitioning migration. The disk already has the target layout:

- ESP: `/dev/nvme0n1p1`, 1G, vfat, mounted at `/boot`
- LUKS: `/dev/nvme0n1p2`, opened as `cryptroot`
- LVM VG: `vg`
- Root LV: `/dev/vg/root`, ext4, mounted at `/`
- Swap LV: `/dev/vg/swap`, 40G, used for swap and hibernation

The only disk metadata change in this runbook is renaming GPT partition labels
from the current names to Disko default names:

- `EFI` to `disk-main-ESP`
- `root` to `disk-main-luks`

No command in this runbook formats, resizes, recreates, or copies live data.

## Hard Safety Rules

If "do not lose any data" is literal, make and verify an external backup first.
No disk operation is risk-free without a backup.

Do not run these commands on the installed system during this migration:

```sh
disko --mode disko
disko-install
mkfs
mkswap
cryptsetup luksFormat
sgdisk --zap-all
sgdisk --clear
```

Stop if any command targets the wrong disk.

Target disk must be:

```text
/dev/nvme0n1
/dev/disk/by-id/nvme-WD_BLACK_SN7100_1TB_24461K801503
```

## 1. Preflight Checks

Work from this repo:

```sh
cd /home/cedric/.config/nixos
```

Check dirty state before editing. Do not touch unrelated dirty files:

```sh
git status --short
```

Check the current disk and mounted storage stack:

```sh
lsblk -o NAME,PATH,TYPE,SIZE,FSTYPE,FSVER,LABEL,PARTLABEL,UUID,MOUNTPOINTS,PKNAME
findmnt -no TARGET,SOURCE,FSTYPE,OPTIONS /
findmnt -no TARGET,SOURCE,FSTYPE,OPTIONS /boot
swapon --show
readlink -e /dev/disk/by-id/nvme-WD_BLACK_SN7100_1TB_24461K801503
```

Expected current labels before this migration:

```text
/dev/nvme0n1p1 PARTLABEL=EFI
/dev/nvme0n1p2 PARTLABEL=root
```

Expected live storage stack:

```text
/boot -> /dev/nvme0n1p1
/     -> /dev/mapper/vg-root
swap  -> /dev/mapper/vg-swap
```

Check that the future Disko labels are not already present:

```sh
test ! -e /dev/disk/by-partlabel/disk-main-ESP
test ! -e /dev/disk/by-partlabel/disk-main-luks
```

If either path already exists but points to the wrong device, stop.

## 2. Optional External Backup

This config migration does not rewrite data, but an external backup is the only
way to make the data-safety story robust against operator error, disk failure,
or unexpected hardware behavior.

Mount external backup storage at `/mnt/backup`, then copy root and boot:

```sh
sudo mkdir -p /mnt/backup/framework-13-root /mnt/backup/framework-13-boot

sudo rsync -aHAXS --numeric-ids --info=progress2 --delete \
  --exclude='/dev/*' \
  --exclude='/proc/*' \
  --exclude='/sys/*' \
  --exclude='/run/*' \
  --exclude='/tmp/*' \
  --exclude='/mnt/*' \
  --exclude='/media/*' \
  --exclude='/lost+found' \
  / /mnt/backup/framework-13-root/

sudo rsync -aHAX --numeric-ids --info=progress2 --delete \
  /boot/ /mnt/backup/framework-13-boot/
```

Verify critical state exists in the backup:

```sh
sudo test -d /mnt/backup/framework-13-root/home/cedric
sudo test -d /mnt/backup/framework-13-root/home/cedric/.config/nixos
sudo test -d /mnt/backup/framework-13-root/etc/NetworkManager
sudo test -d /mnt/backup/framework-13-root/var/lib/docker
sudo test -d /mnt/backup/framework-13-root/var/lib/bluetooth
sudo test -d /mnt/backup/framework-13-root/var/lib/fprint
sudo test -d /mnt/backup/framework-13-boot/EFI
```

## 3. Add Disko To The Flake

Add the Disko input in `flake.nix`:

```nix
disko.url = "github:nix-community/disko/latest";
disko.inputs.nixpkgs.follows = "nixos";
```

Pass `disko` into `mkNixOSConfiguration`:

```nix
mkNixOSConfiguration =
  {
    host,
    nixos,
    nixos-hardware,
    disko,
    home-manager,
    catppuccin,
  }:
```

Add Disko modules for the Framework 13 NixOS host:

```nix
modules = [
  (import ./hosts/${host.dir}/configuration.nix host.user)
  ./hosts/${host.dir}/hardware-configuration.nix
  (import ./hosts/${host.dir}/networking.nix {
    hostName = host.hostname;
    inherit (host) user;
  })
  disko.nixosModules.disko
  ./hosts/${host.dir}/disko.nix
  nixos-hardware.nixosModules.framework-amd-ai-300-series
  home-manager.nixosModules.home-manager
  catppuccin.nixosModules.catppuccin
  # ...
];
```

Pass `disko` when creating the Framework 13 configuration:

```nix
nixosConfigurations."${hosts.framework-13.hostname}" = mkNixOSConfiguration {
  host = hosts.framework-13;
  inherit (inputs) nixos;
  inherit (inputs) nixos-hardware;
  inherit (inputs) disko;
  inherit (inputs) home-manager;
  inherit (inputs) catppuccin;
};
```

Update only the Disko lock input:

```sh
XDG_CACHE_HOME=/tmp/codex-nix-cache nix flake lock --update-input disko
```

If Nix reports a cache problem under `/tmp/nix`, retry with a fresh cache:

```sh
mkdir -p /tmp/codex-nix-cache
XDG_CACHE_HOME=/tmp/codex-nix-cache nix flake lock --update-input disko
```

## 4. Add Minimal Disko Config

Create `hosts/framework-13/disko.nix`:

```nix
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-WD_BLACK_SN7100_1TB_24461K801503";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            priority = 1;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "fmask=0077"
                "dmask=0077"
              ];
            };
          };

          luks = {
            size = "100%";
            priority = 2;
            content = {
              type = "luks";
              name = "cryptroot";
              content = {
                type = "lvm_pv";
                vg = "vg";
              };
            };
          };
        };
      };
    };

    lvm_vg.vg = {
      type = "lvm_vg";
      lvs = {
        swap = {
          size = "40G";
          content = {
            type = "swap";
            resumeDevice = true;
          };
        };

        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
```

This intentionally omits partition labels. Disko defaults generate:

```text
/dev/disk/by-partlabel/disk-main-ESP
/dev/disk/by-partlabel/disk-main-luks
```

The disk selector stays explicit and stable:

```text
/dev/disk/by-id/nvme-WD_BLACK_SN7100_1TB_24461K801503
```

## 5. Clean Hardware Configuration

Remove storage ownership from `hosts/framework-13/hardware-configuration.nix`:

```nix
boot.initrd.luks.devices.cryptroot.device
boot.resumeDevice
fileSystems."/"
fileSystems."/boot"
swapDevices
```

Keep only hardware-detection and system facts:

```nix
# Do not modify this file!  It was generated by 'nixos-generate-config'
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ "amdgpu" ];
    };
    kernelModules = [ "kvm-amd" ];
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
```

After this step, `hosts/framework-13/hardware-configuration.nix` must not
reference root, boot, swap, resume, LUKS UUIDs, filesystem UUIDs, PARTUUIDs, or
`/dev/vg/*` paths.

## 6. Stage New Nix File Before Eval

This repository is a Git flake. New files can be invisible to flake eval until
they are tracked.

Stage only the files for this migration:

```sh
git add flake.nix flake.lock hosts/framework-13/disko.nix hosts/framework-13/hardware-configuration.nix
```

Do not stage unrelated dirty files.

## 7. Rename GPT Labels

This is the only disk metadata mutation:

```sh
sudo sgdisk --change-name=1:disk-main-ESP --change-name=2:disk-main-luks /dev/nvme0n1
sudo partprobe /dev/nvme0n1 || true
sudo udevadm trigger --subsystem-match=block
sudo udevadm settle
```

Verify labels and generated paths:

```sh
lsblk -o NAME,PATH,TYPE,SIZE,FSTYPE,FSVER,LABEL,PARTLABEL,UUID,MOUNTPOINTS,PKNAME
test "$(readlink -e /dev/disk/by-partlabel/disk-main-ESP)" = /dev/nvme0n1p1
test "$(readlink -e /dev/disk/by-partlabel/disk-main-luks)" = /dev/nvme0n1p2
```

Expected:

```text
/dev/disk/by-partlabel/disk-main-ESP  -> /dev/nvme0n1p1
/dev/disk/by-partlabel/disk-main-luks -> /dev/nvme0n1p2
```

Rollback labels if needed:

```sh
sudo sgdisk --change-name=1:EFI --change-name=2:root /dev/nvme0n1
sudo partprobe /dev/nvme0n1 || true
sudo udevadm trigger --subsystem-match=block
sudo udevadm settle
```

## 8. Verify Generated NixOS Storage Config

Assert the generated storage config targets the renamed labels and the existing
LVM paths:

```sh
XDG_CACHE_HOME=/tmp/codex-nix-cache nix eval --impure --raw \
  .#nixosConfigurations.nixos.config \
  --apply '
config:
let
  fs = config.fileSystems;
  swaps = builtins.map (s: s.device) config.swapDevices;
in
assert fs."/boot".device == "/dev/disk/by-partlabel/disk-main-ESP";
assert config.boot.initrd.luks.devices.cryptroot.device == "/dev/disk/by-partlabel/disk-main-luks";
assert fs."/".device == "/dev/vg/root";
assert swaps == [ "/dev/vg/swap" ];
assert config.boot.resumeDevice == "/dev/vg/swap";
"ok"
'
```

The command must print:

```text
ok
```

For human inspection, evaluate the relevant generated storage paths:

```sh
XDG_CACHE_HOME=/tmp/codex-nix-cache nix eval --impure --json \
  .#nixosConfigurations.nixos.config \
  --apply 'config: {
    fileSystems = builtins.mapAttrs (_: fs: {
      device = fs.device;
      fsType = fs.fsType;
      options = fs.options;
      neededForBoot = fs.neededForBoot;
    }) config.fileSystems;
    swapDevices = builtins.map (s: s.device) config.swapDevices;
    luksDevices = builtins.mapAttrs (_: d: {
      device = d.device;
      name = d.name;
      allowDiscards = d.allowDiscards;
    }) config.boot.initrd.luks.devices;
    resumeDevice = config.boot.resumeDevice;
  }'
```

Expected storage paths:

```text
fileSystems."/boot".device = "/dev/disk/by-partlabel/disk-main-ESP"
boot.initrd.luks.devices.cryptroot.device = "/dev/disk/by-partlabel/disk-main-luks"
fileSystems."/".device = "/dev/vg/root"
swapDevices[0].device = "/dev/vg/swap"
boot.resumeDevice = "/dev/vg/swap"
```

Note: Disko may emit `defaults` for root mount options. This is normal mount
behavior, not a data migration.

Build the generated Disko script without running it:

```sh
XDG_CACHE_HOME=/tmp/codex-nix-cache nix build --impure \
  .#nixosConfigurations.nixos.config.system.build.diskoScript \
  --out-link /tmp/framework-13-disko-script
```

Inspect the script targets:

```sh
rg -n 'disk-main-ESP|disk-main-luks|/dev/vg/root|/dev/vg/swap' /tmp/framework-13-disko-script
! rg -n '7ae1e520|FFB8-3258|96c110f0' /tmp/framework-13-disko-script
```

The first `rg` command must show the new partlabels and LVM paths. The second
command must return no matches for the old LUKS, ESP, and swap UUIDs.

This is a dry-run-level assertion only: building and inspecting the script does
not mount devices, format devices, or prove that a reboot succeeds. It proves
that the generated Disko script and NixOS config refer to the expected devices.

## 9. Build Only

Build the system closure without switching:

```sh
XDG_CACHE_HOME=/tmp/codex-nix-cache nix build --impure \
  .#nixosConfigurations.nixos.config.system.build.toplevel
```

If this fails, do not switch. Fix config or roll back GPT labels.

## 10. Switch

Stop here if someone else must apply the switch.

When ready:

```sh
sudo nixos-rebuild switch --flake /home/cedric/.config/nixos#nixos
```

After switch:

```sh
lsblk -o NAME,PATH,TYPE,SIZE,FSTYPE,FSVER,LABEL,PARTLABEL,UUID,MOUNTPOINTS,PKNAME
findmnt -no TARGET,SOURCE,FSTYPE,OPTIONS /
findmnt -no TARGET,SOURCE,FSTYPE,OPTIONS /boot
swapon --show
cat /proc/cmdline
```

Reboot once and verify:

- LUKS passphrase prompt appears.
- Root mounts at `/`.
- ESP mounts at `/boot`.
- Swap is active.
- Hibernation resume still works.

## 11. Rescue Path

Boot a NixOS installer USB, then:

```sh
sudo -i
cryptsetup open /dev/disk/by-partlabel/disk-main-luks cryptroot
vgchange -ay
mount /dev/vg/root /mnt
mount /dev/disk/by-partlabel/disk-main-ESP /mnt/boot
nixos-enter --root /mnt
```

Inside `nixos-enter`, inspect or roll back the NixOS generation:

```sh
nixos-rebuild boot --flake /home/cedric/.config/nixos#nixos
```

To roll labels back from rescue:

```sh
sgdisk --change-name=1:EFI --change-name=2:root /dev/nvme0n1
partprobe /dev/nvme0n1 || true
udevadm trigger --subsystem-match=block
udevadm settle
```

## Success Criteria

- `hosts/framework-13/hardware-configuration.nix` has no root, boot, swap,
  resume, or LUKS device ownership.
- Disko config has no explicit partition labels and no PARTUUID references.
- Disko uses `/dev/disk/by-id/nvme-WD_BLACK_SN7100_1TB_24461K801503` for the
  physical disk.
- Generated partition paths use Disko default partlabels.
- Build succeeds before switch.
- System boots after switch.
- `/`, `/boot`, swap, and hibernation still work.
