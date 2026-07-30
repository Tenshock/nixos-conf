# Migrate Framework 13 Storage Ownership To Disko

This runbook moves this Framework 13 NixOS config to `nix-community/disko`
as the single declarative owner for partitions, LUKS, LVM, filesystems, swap,
and hibernation resume.

This is an in-place declarative ownership migration, not a repartitioning
migration. The disk already has the target layout:

- ESP: `/dev/nvme0n1p1`, 1G, vfat, mounted at `/boot`
- LUKS: `/dev/nvme0n1p2`, opened as `cryptroot`
- LVM VG: `vg`
- Root LV: `/dev/vg/root`, ext4, mounted at `/`
- Swap LV: `/dev/vg/swap`, 40G, used for swap and hibernation

This runbook keeps the existing GPT partition labels:

- ESP: `EFI`
- LUKS: `root`

They are declared explicitly in Disko so no partition-table mutation is needed.
No command in the required migration path formats, resizes, recreates, relabels,
or copies live data. The optional backup section only copies data to external
storage.

## Hard Safety Rules

If "do not lose any data" is literal, make and verify an external backup first.
No disk operation is risk-free without a backup.

Do not run these commands or modes on the installed system during this
migration:

```sh
disko --mode format
disko --mode format,mount
disko --mode destroy,format,mount
disko --mode disko # legacy name for the destructive workflow
disko-install
mkfs
mkswap
cryptsetup luksFormat
sgdisk --zap-all
sgdisk --clear
```

Do not execute `config.system.build.diskoScript`, its `bin/disko` program, or
the `/tmp/framework-13-disko-script` result built later. Building and reading
that script is safe; running it is outside this migration.

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

Assert that the existing labels resolve to the expected partitions and that
the unused Disko default labels do not exist:

```sh
test "$(readlink -e /dev/disk/by-partlabel/EFI)" = /dev/nvme0n1p1
test "$(readlink -e /dev/disk/by-partlabel/root)" = /dev/nvme0n1p2
test ! -e /dev/disk/by-partlabel/disk-main-ESP
test ! -e /dev/disk/by-partlabel/disk-main-luks
```

Stop on any failed assertion.

## 2. Backup Decision

This config migration does not rewrite data, but an external backup is the only
way to make the data-safety story robust against operator error, disk failure,
or unexpected hardware behavior.

With no external drive or installer USB, this runbook can preserve an old NixOS
boot generation as a configuration fallback. That is not a data backup and
cannot recover from SSD failure, GPT corruption, a damaged ESP, or a damaged
LUKS header.

Before proceeding without external media:

- confirm the existing LUKS header backup is accessible from another device;
- accept that this is not a zero-data-loss guarantee;
- do not run garbage collection until the new generation has booted and
  hibernation has been tested.

If external storage becomes available, mount it at `/mnt/backup`, then copy root
and boot:

```sh
mountpoint -q /mnt/backup
findmnt -no TARGET,SOURCE,FSTYPE,OPTIONS /mnt/backup
df -h /mnt/backup

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
    monique,
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
  monique.nixosModules.default
  # Keep the existing Home Manager configuration module here too.
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
  inherit (inputs) monique;
};
```

Add only the new Disko lock input. Current Lix uses `nix flake update`; the old
`nix flake lock --update-input` form is deprecated:

```sh
mkdir -p /tmp/codex-nix-cache
XDG_CACHE_HOME=/tmp/codex-nix-cache nix flake update disko
```

`flake.lock` is already dirty before this migration. Inspect its full diff and
do not stage unrelated existing lock changes blindly:

```sh
git diff -- flake.lock
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
            label = "EFI";
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
            label = "root";
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

The labels intentionally match current GPT metadata, so generated paths are:

```text
/dev/disk/by-partlabel/EFI
/dev/disk/by-partlabel/root
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

## 6. Evaluate The Dirty Tree Without Staging Unrelated Files

This repository already has unrelated dirty files. Use a path flake for
validation so the new untracked `disko.nix` is visible without staging unrelated
changes:

```sh
git status --short
```

Do not stage or commit anything merely to make evaluation work. When eventually
committing, select migration changes deliberately; `git add flake.lock` would
also stage its pre-existing unrelated updates.

## 7. Verify Generated NixOS Storage Config

Assert the generated storage config targets the existing labels and LVM paths:

```sh
XDG_CACHE_HOME=/tmp/codex-nix-cache nix eval --impure --raw \
  path:.#nixosConfigurations.nixos.config \
  --apply '
config:
let
  fs = config.fileSystems;
  swaps = builtins.map (s: s.device) config.swapDevices;
in
assert fs."/boot".device == "/dev/disk/by-partlabel/EFI";
assert config.boot.initrd.luks.devices.cryptroot.device == "/dev/disk/by-partlabel/root";
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
  path:.#nixosConfigurations.nixos.config \
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
fileSystems."/boot".device = "/dev/disk/by-partlabel/EFI"
boot.initrd.luks.devices.cryptroot.device = "/dev/disk/by-partlabel/root"
fileSystems."/".device = "/dev/vg/root"
swapDevices[0].device = "/dev/vg/swap"
boot.resumeDevice = "/dev/vg/swap"
```

Note: Disko may emit `defaults` for root mount options. This is normal mount
behavior, not a data migration.

Build the generated Disko script without running it:

```sh
XDG_CACHE_HOME=/tmp/codex-nix-cache nix build --impure \
  path:.#nixosConfigurations.nixos.config.system.build.diskoScript \
  --out-link /tmp/framework-13-disko-script
```

Inspect the script targets:

```sh
rg -n '/dev/disk/by-partlabel/(EFI|root)|/dev/vg/root|/dev/vg/swap' \
  /tmp/framework-13-disko-script
! rg -n '7ae1e520|FFB8-3258|96c110f0' /tmp/framework-13-disko-script
```

The first `rg` command must show the existing partlabels and LVM paths. The second
command must return no matches for the old LUKS, ESP, and swap UUIDs.

This is a dry-run-level assertion only: building and inspecting the script does
not mount devices, format devices, or prove that a reboot succeeds. It proves
that the generated Disko script and NixOS config refer to the expected devices.
Never execute the built script.

## 8. Build Only

Build the system closure without switching:

```sh
XDG_CACHE_HOME=/tmp/codex-nix-cache nix build --impure \
  path:.#nixosConfigurations.nixos.config.system.build.toplevel \
  --out-link /tmp/framework-13-disko-system
```

If this fails, do not install a boot generation.

## 9. Install A Boot Generation Without Switching

Do not use `switch` for this migration. `boot` installs the new generation for
the next reboot without activating it in the running system.

Stop here. The user must run the following block. It records the current
generation, installs the exact closure already built in step 8, then verifies
that both generations remain bootable:

```sh
old_generation="$(readlink /nix/var/nix/profiles/system)"
old_number="${old_generation#system-}"
old_number="${old_number%-link}"
old_system="$(readlink -e /nix/var/nix/profiles/system)"
new_system="$(readlink -e /tmp/framework-13-disko-system)"

test -n "$old_number"
test -e "$old_system"
test -e "$new_system"
test "$old_system" != "$new_system"
printf 'old generation: %s\nold system: %s\nnew system: %s\n' \
  "$old_generation" "$old_system" "$new_system"

sudo nixos-rebuild boot --store-path "$new_system"

new_generation="$(readlink /nix/var/nix/profiles/system)"
new_number="${new_generation#system-}"
new_number="${new_number%-link}"

test "$new_generation" != "$old_generation"
test -e "/nix/var/nix/profiles/$old_generation"
test -e "/nix/var/nix/profiles/$new_generation"
test "$(readlink -e /nix/var/nix/profiles/system)" = "$new_system"
sudo grep -RIl "^version Generation $old_number " /boot/loader/entries
sudo grep -RIl "^version Generation $new_number " /boot/loader/entries
```

Do not reboot if any assertion fails. Do not run `nh clean`,
`nix-collect-garbage`, or any other generation cleanup.

## 10. Reboot And Verify

Reboot into the new default generation. If it fails, select the recorded old
generation from the systemd-boot menu.

After the new generation boots:

```sh
lsblk -o NAME,PATH,TYPE,SIZE,FSTYPE,FSVER,LABEL,PARTLABEL,UUID,MOUNTPOINTS,PKNAME
test "$(readlink -e /dev/disk/by-partlabel/EFI)" = /dev/nvme0n1p1
test "$(readlink -e /dev/disk/by-partlabel/root)" = /dev/nvme0n1p2
findmnt -no TARGET,SOURCE,FSTYPE,OPTIONS /
findmnt -no TARGET,SOURCE,FSTYPE,OPTIONS /boot
swapon --show
cat /proc/cmdline
```

Verify:

- LUKS passphrase prompt appears.
- Root mounts at `/`.
- ESP mounts at `/boot`.
- Swap is active.
- `/proc/cmdline` contains `resume=/dev/vg/swap`.
- Hibernation resume still works.

Only after these checks may old generations be cleaned.

## 11. No-Media Rollback

If the new generation does not boot, select the recorded old generation in the
systemd-boot menu. It still uses filesystem and LUKS UUIDs, which this migration
does not change.

Once the old generation is running, make it the default again:

```sh
sudo nixos-rebuild boot --rollback
```

Then verify the system profile and boot entry before rebooting:

```sh
readlink /nix/var/nix/profiles/system
sudo ls -1 /boot/loader/entries
```

Without external recovery media, failure before the systemd-boot menu or damage
to the SSD, GPT, ESP, or LUKS header has no local recovery path. Stop rather than
proceed if that remaining risk is unacceptable.

## Success Criteria

- `hosts/framework-13/hardware-configuration.nix` has no root, boot, swap,
  resume, or LUKS device ownership.
- Disko explicitly owns the existing `EFI` and `root` GPT labels.
- No UUID or PARTUUID storage ownership remains in the NixOS configuration.
- Disko uses `/dev/disk/by-id/nvme-WD_BLACK_SN7100_1TB_24461K801503` for the
  physical disk.
- No partition table, filesystem, LUKS container, VG, or LV is mutated.
- Generated partition paths use the existing partlabels.
- Eval and build succeed before installing a boot generation.
- Old and new systemd-boot entries both exist before reboot.
- System boots into the new generation.
- `/`, `/boot`, swap, and hibernation still work.
