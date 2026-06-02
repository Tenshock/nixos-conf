# Migrate Framework 13 NixOS To An Encrypted Disk

This runbook is for this repository's NixOS host:

- Host: `framework-13`
- Flake output: `nixosConfigurations.nixos`
- Current bootloader: `systemd-boot`
- Current root filesystem: plain `ext4`
- Current `/boot`: plain EFI/VFAT partition
- Current swap: plain swap partition, also used as the hibernation resume device

The target layout is:

```text
disk
+- EFI System Partition       /boot        vfat, unencrypted
+- LUKS encrypted partition
   +- cryptroot
      +- vg/root              /            ext4, encrypted
      +- vg/swap              swap         encrypted, hibernation-capable
```

Keeping `/boot` unencrypted is normal with `systemd-boot`. The kernel and initrd
remain visible, but the root filesystem, home directory, Nix store, logs, secrets,
browser data, and swap are encrypted.

This guide uses `ext4` for `/`. That is the conservative choice for this machine:
it is simple, stable, well-supported in initrd, and works cleanly with a dedicated
encrypted swap volume for hibernation. `btrfs` is also a valid choice if you want
filesystem snapshots, transparent compression, and subvolumes, but it adds more
layout decisions and maintenance. If you do not specifically want those features,
use `ext4`.

This process destroys the current Linux disk contents. Do not continue until the
backup verification step is complete.

## 0. Current Context

Your current generated hardware config declares:

```nix
fileSystems."/" = {
  device = "/dev/disk/by-uuid/13f2c8e5-c67d-4ef2-8a64-3dca476711b0";
  fsType = "ext4";
};

fileSystems."/boot" = {
  device = "/dev/disk/by-uuid/FFB8-3258";
  fsType = "vfat";
};

swapDevices = [ { device = "/dev/disk/by-uuid/c3e47598-fe43-43c0-8f9f-f5116a28f86f"; } ];

boot.resumeDevice = "/dev/disk/by-uuid/c3e47598-fe43-43c0-8f9f-f5116a28f86f";
```

That means:

- `/` is not encrypted.
- `/boot` is not encrypted.
- swap is not encrypted.
- hibernation resumes from the current swap UUID.

After migration, the root and swap UUIDs will change. The new swap UUID must be
used both in `swapDevices` and `boot.resumeDevice`.

## 1. Prepare A Known-Good Backup

Do this from the existing NixOS installation before booting the installer.

### 1.1 Identify Important Data

At minimum, back up:

```text
/home/cedric
~/.config/nixos
/etc/nixos, if it contains anything not symlinked to ~/.config/nixos
SSH keys
GPG keys
password manager recovery material
browser profiles, if needed
project directories
any local databases or VM/container volumes
```

Why: repartitioning and `cryptsetup luksFormat` will erase the target disk. NixOS
can recreate system packages from the flake, but it cannot recreate personal data
or secrets.

### 1.2 Create The Backup

Example using `rsync` to an external disk mounted at `/run/media/cedric/backup`:

```sh
rsync -aHAX --numeric-ids --info=progress2 \
  /home/cedric/ \
  /run/media/cedric/backup/framework-13-home/
```

What this does:

- `-a` preserves normal file metadata.
- `-HAX` preserves hardlinks, ACLs, and extended attributes.
- `--numeric-ids` avoids remapping ownership by user names.
- The trailing slash on `/home/cedric/` copies the contents of the directory.

Back up the Nix config too:

```sh
rsync -aHAX --numeric-ids --info=progress2 \
  /home/cedric/.config/nixos/ \
  /run/media/cedric/backup/nixos-config/
```

If this repository is also pushed to Git, verify that status is clean or that all
important work is pushed:

```sh
cd ~/.config/nixos
git status --short
git remote -v
```

### 1.3 Verify The Backup

List files from the backup:

```sh
ls -la /run/media/cedric/backup/framework-13-home
ls -la /run/media/cedric/backup/nixos-config
```

Check that important files exist:

```sh
test -d /run/media/cedric/backup/framework-13-home/.ssh
test -d /run/media/cedric/backup/nixos-config/hosts/framework-13
```

Optional but useful: compare sizes.

```sh
du -sh /home/cedric
du -sh /run/media/cedric/backup/framework-13-home
```

Verification target:

- You can browse the backup.
- Your Nix config exists in the backup.
- Important secrets and project directories are present.
- The external backup device is not the disk you are about to wipe.

## 2. Create And Boot A NixOS Installer USB

Download a NixOS ISO, write it to a USB drive, and boot the Framework 13 from it.

After booting the installer, become root if needed:

```sh
sudo -i
```

Verification:

```sh
whoami
```

Expected output:

```text
root
```

## 3. Identify The Target Disk

List disks and filesystems:

```sh
lsblk -o NAME,SIZE,TYPE,FSTYPE,FSVER,LABEL,UUID,MOUNTPOINTS
```

What this does:

- Shows physical disks, partitions, filesystems, UUIDs, and mountpoints.
- Helps distinguish the internal NVMe disk from the USB installer and backup disk.

On a Framework laptop, the internal disk is commonly named something like:

```text
/dev/nvme0n1
```

Do not assume that name. Verify by size and model:

```sh
lsblk -d -o NAME,MODEL,SIZE,TYPE
```

Set a shell variable for readability after you have verified the correct disk:

```sh
DISK=/dev/nvme0n1
```

Verify the variable:

```sh
echo "$DISK"
lsblk "$DISK"
```

Stop if this points to your backup disk or USB installer.

## 4. Wipe And Partition The Disk

This is the destructive step.

### 4.1 Clear Existing Signatures

```sh
wipefs -a "$DISK"
```

What this does:

- Removes filesystem, RAID, LVM, and partition signatures from the disk.
- Prevents the installer from accidentally detecting stale filesystems later.

Verification:

```sh
wipefs "$DISK"
```

Expected result: no important old signatures remain.

### 4.2 Create A GPT Partition Table

```sh
parted "$DISK" -- mklabel gpt
```

What this does:

- Creates a new GPT partition table.
- Required for a clean UEFI/systemd-boot setup.

### 4.3 Create The EFI Partition

```sh
parted "$DISK" -- mkpart ESP fat32 1MiB 1025MiB
parted "$DISK" -- set 1 esp on
```

What this does:

- Creates a 1 GiB EFI System Partition.
- Marks it as an ESP so firmware and `systemd-boot` can use it.

### 4.4 Create The LUKS Partition

```sh
parted "$DISK" -- mkpart primary 1025MiB 100%
```

What this does:

- Uses the rest of the disk for the encrypted Linux system.

Ask the kernel to re-read the partition table:

```sh
partprobe "$DISK"
```

Verification:

```sh
lsblk -o NAME,SIZE,TYPE,FSTYPE,PARTTYPENAME "$DISK"
```

Expected shape:

```text
nvme0n1       disk
+-nvme0n1p1   part        EFI System
+-nvme0n1p2   part        Linux filesystem
```

Define partition variables:

```sh
EFI="${DISK}p1"
CRYPT_PART="${DISK}p2"
```

If your disk is not NVMe, partition names may be `/dev/sda1` and `/dev/sda2`
instead of `/dev/nvme0n1p1` and `/dev/nvme0n1p2`. In that case set:

```sh
EFI=/dev/sda1
CRYPT_PART=/dev/sda2
```

Verify:

```sh
echo "$EFI"
echo "$CRYPT_PART"
lsblk "$DISK"
```

## 5. Create The Encrypted Container

Format the second partition as LUKS:

```sh
cryptsetup luksFormat -y --label nixos-crypt "$CRYPT_PART"
```

What this does:

- Creates an encrypted container on the Linux partition.
- Prompts for a passphrase twice because of `-y`.
- Labels the LUKS container `nixos-crypt`.
- Destroys existing content on that partition.

Use a strong passphrase you can type at boot.

Open the encrypted container:

```sh
cryptsetup open "$CRYPT_PART" cryptroot
```

What this does:

- Unlocks the LUKS container.
- Exposes decrypted storage at `/dev/mapper/cryptroot`.

Verification:

```sh
lsblk -f
cryptsetup status cryptroot
```

Expected:

- `cryptroot` exists under the LUKS partition.
- `cryptsetup status` says the device is active.

Back up the LUKS header:

```sh
cryptsetup luksHeaderBackup "$CRYPT_PART" --header-backup-file /tmp/luks-header-nixos-crypt.img
```

What this does:

- Saves the LUKS metadata needed to unlock the encrypted partition.
- Gives you a recovery path if the on-disk LUKS header is damaged.

This backup is sensitive. Anyone with the header backup and your passphrase can
attempt to unlock the disk. Move it to your external backup storage, not to the
encrypted disk you are creating:

```sh
cp /tmp/luks-header-nixos-crypt.img /run/media/cedric/backup/
rm /tmp/luks-header-nixos-crypt.img
```

Verification:

```sh
test -f /run/media/cedric/backup/luks-header-nixos-crypt.img
```

## 6. Create LVM Volumes Inside LUKS

Using LVM inside LUKS makes hibernation-friendly swap straightforward and keeps
root/swap management flexible.

Create the LVM physical volume:

```sh
pvcreate /dev/mapper/cryptroot
```

Create a volume group:

```sh
vgcreate vg /dev/mapper/cryptroot
```

Create encrypted swap:

```sh
lvcreate -L 80G -n swap vg
```

What this does:

- Creates `/dev/vg/swap`.
- `80G` is an example. For reliable hibernation, choose at least your RAM size.

Check RAM size:

```sh
free -h
```

Create encrypted root using the remaining space:

```sh
lvcreate -l 100%FREE -n root vg
```

What this does:

- Creates `/dev/vg/root`.
- Allocates all remaining space to root.

Verification:

```sh
lvs
lsblk -f
```

Expected:

```text
vg-root
vg-swap
```

Both should appear under `cryptroot`, which appears under the LUKS partition.

## 7. Create Filesystems

Create the root filesystem:

```sh
mkfs.ext4 -L nixos-root /dev/vg/root
```

What this does:

- Formats the encrypted root logical volume as `ext4`.
- Adds a readable label, `nixos-root`.

Create swap:

```sh
mkswap -L nixos-swap /dev/vg/swap
```

What this does:

- Formats the encrypted swap logical volume.
- Adds a readable label, `nixos-swap`.

Create the EFI filesystem:

```sh
mkfs.fat -F 32 -n NIXBOOT "$EFI"
```

What this does:

- Formats the unencrypted EFI partition as FAT32.
- Labels it `NIXBOOT`.

Verification:

```sh
lsblk -f
```

Expected:

- `vg-root` has `FSTYPE ext4` and label `nixos-root`.
- `vg-swap` has `FSTYPE swap` and label `nixos-swap`.
- EFI partition has `FSTYPE vfat` and label `NIXBOOT`.

## 8. Mount The New System

Mount root:

```sh
mount /dev/vg/root /mnt
```

Create and mount `/boot`:

```sh
mkdir -p /mnt/boot
mount "$EFI" /mnt/boot
```

Enable swap:

```sh
swapon /dev/vg/swap
```

If `swapon` is not in your shell path, try:

```sh
/run/current-system/sw/bin/swapon /dev/vg/swap
```

Verification:

```sh
findmnt /mnt
findmnt /mnt/boot
cat /proc/swaps
```

Expected:

- `/mnt` is mounted from `/dev/mapper/vg-root` or `/dev/vg/root`.
- `/mnt/boot` is mounted from the EFI partition.
- `/proc/swaps` lists `/dev/dm-*`, `/dev/mapper/vg-swap`, or `/dev/vg/swap`.

## 9. Bring This Flake Into The Installer

You need this repository available inside the installer environment.

If you pushed it to Git, clone it:

```sh
mkdir -p /mnt/home/cedric/.config
git clone <your-repo-url> /mnt/home/cedric/.config/nixos
```

If it is on your backup disk, copy it:

```sh
mkdir -p /mnt/home/cedric/.config
rsync -aHAX --numeric-ids \
  /run/media/cedric/backup/nixos-config/ \
  /mnt/home/cedric/.config/nixos/
```

Verification:

```sh
ls -la /mnt/home/cedric/.config/nixos
test -f /mnt/home/cedric/.config/nixos/flake.nix
test -f /mnt/home/cedric/.config/nixos/hosts/framework-13/configuration.nix
```

## 10. Generate Fresh Hardware Config For Reference

Generate a new hardware configuration:

```sh
nixos-generate-config --root /mnt
```

What this does:

- Inspects the mounted target system.
- Writes generated config under `/mnt/etc/nixos`.
- Gives you correct UUIDs for the new encrypted layout.

Read the generated file:

```sh
sed -n '1,220p' /mnt/etc/nixos/hardware-configuration.nix
```

You will use this as reference to update:

```text
/mnt/home/cedric/.config/nixos/hosts/framework-13/hardware-configuration.nix
```

## 11. Update This Repo's Hardware Configuration

Edit:

```text
/mnt/home/cedric/.config/nixos/hosts/framework-13/hardware-configuration.nix
```

The final result should keep your existing kernel modules, CPU microcode, and
DHCP defaults, but replace the storage section.

Use UUIDs from:

```sh
lsblk -f
blkid
```

You need three important UUIDs:

```text
LUKS partition UUID:   UUID of "$CRYPT_PART", FSTYPE crypto_LUKS
Root filesystem UUID: UUID of /dev/vg/root, FSTYPE ext4
Swap UUID:            UUID of /dev/vg/swap, FSTYPE swap
EFI UUID:             UUID of "$EFI", FSTYPE vfat
```

The storage part should look like this:

```nix
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

    luks.devices."cryptroot" = {
      device = "/dev/disk/by-uuid/<LUKS-PARTITION-UUID>";
      allowDiscards = true;
    };

    services.lvm.enable = true;
  };

  kernelModules = [ "kvm-amd" ];
  resumeDevice = "/dev/disk/by-uuid/<SWAP-UUID>";
};

fileSystems."/" = {
  device = "/dev/disk/by-uuid/<ROOT-FILESYSTEM-UUID>";
  fsType = "ext4";
};

fileSystems."/boot" = {
  device = "/dev/disk/by-uuid/<EFI-UUID>";
  fsType = "vfat";
  options = [
    "fmask=0077"
    "dmask=0077"
  ];
};

swapDevices = [
  { device = "/dev/disk/by-uuid/<SWAP-UUID>"; }
];
```

Why these settings matter:

- `boot.initrd.luks.devices."cryptroot"` tells initrd to ask for the passphrase
  early in boot and unlock root before mounting `/`.
- `allowDiscards = true` allows TRIM through LUKS for SSD/NVMe health and
  performance. This can reveal discard patterns on the encrypted device. If you
  prefer the stricter privacy posture, set it to `false` or omit it.
- `boot.initrd.services.lvm.enable = true` tells initrd to activate LVM volumes
  before mounting root. `nixos-generate-config` may add this automatically; keep
  it explicit if root is on LVM.
- `fileSystems."/"` must point to the decrypted root filesystem UUID, not the
  raw LUKS partition UUID.
- `swapDevices` must point to the decrypted swap logical volume UUID.
- `boot.resumeDevice` must point to the same encrypted swap UUID for hibernation.

Verification:

```sh
nix --extra-experimental-features 'nix-command flakes' \
  flake check /mnt/home/cedric/.config/nixos
```

If `flake check` is too broad or slow, at least evaluate the NixOS config:

```sh
nix --extra-experimental-features 'nix-command flakes' \
  eval /mnt/home/cedric/.config/nixos#nixosConfigurations.nixos.config.system.build.toplevel.drvPath
```

## 12. Install NixOS

Install from your flake:

```sh
nixos-install --flake /mnt/home/cedric/.config/nixos#nixos
```

What this does:

- Builds the `nixosConfigurations.nixos` system.
- Installs it to `/mnt`.
- Installs the bootloader into the mounted EFI partition.
- Prompts for the root password unless configured otherwise.

Verification before reboot:

```sh
test -d /mnt/boot/EFI
test -d /mnt/nix/store
ls -la /mnt/boot
```

Also inspect generated boot entries:

```sh
bootctl --esp-path=/mnt/boot status
```

If `bootctl` cannot inspect the mounted ESP from the installer, this is not
necessarily fatal. The stronger verification is that `nixos-install` completed
without error and `/mnt/boot` contains loader files.

## 13. Reboot Into The Encrypted System

Unmount and reboot:

```sh
swapoff /dev/vg/swap
umount -R /mnt
cryptsetup close cryptroot
reboot
```

If unmounting fails, inspect what is still mounted:

```sh
findmnt -R /mnt
```

At boot, expected behavior:

- Firmware loads `systemd-boot`.
- NixOS initrd starts.
- You are prompted for the LUKS passphrase.
- Root mounts after successful unlock.

## 14. Verify The Booted System

After logging in, verify the block layout:

```sh
lsblk -f
```

Expected shape:

```text
nvme0n1
+-nvme0n1p1      vfat        NIXBOOT      mounted at /boot
+-nvme0n1p2      crypto_LUKS
  +-cryptroot
    +-vg-root    ext4        nixos-root   mounted at /
    +-vg-swap    swap        nixos-swap   active swap
```

Verify `/`:

```sh
findmnt /
```

Expected:

- Source is `/dev/mapper/vg-root`, `/dev/vg/root`, or equivalent.
- It is not the raw NVMe partition.

Verify `/boot`:

```sh
findmnt /boot
```

Expected:

- Source is the EFI partition.
- Filesystem is `vfat`.

Verify swap:

```sh
cat /proc/swaps
```

Expected:

- Swap is active.
- Swap source is the encrypted logical volume, not a raw disk partition.

If available:

```sh
swapon --show
```

Verify LUKS:

```sh
cryptsetup status cryptroot
```

Expected:

- `cryptroot` is active.

Verify NixOS sees the intended config:

```sh
sudo nixos-rebuild dry-build --flake ~/.config/nixos#nixos
```

## 15. Verify Hibernation

Because your config uses suspend-then-hibernate, do not skip this.

Confirm resume device:

```sh
cat /proc/cmdline
```

Look for a `resume=` parameter pointing to the encrypted swap UUID or mapped swap
device.

Check configured swap UUID:

```sh
grep -n "resumeDevice\|swapDevices" ~/.config/nixos/hosts/framework-13/hardware-configuration.nix
lsblk -f
```

Test hibernation:

```sh
systemctl hibernate
```

Expected:

- Machine powers off after writing memory to swap.
- On power-on, you enter the LUKS passphrase.
- The previous session resumes.

If hibernation fails:

```sh
journalctl -b -1 -u systemd-hibernate.service
journalctl -b -1 | grep -i 'hibernate\|resume\|swap'
```

Common causes:

- Swap is smaller than RAM.
- `boot.resumeDevice` points to the old plain swap UUID.
- `swapDevices` points to the wrong UUID.
- Initrd does not unlock the LUKS container early enough.

## 16. Restore Personal Data

If you did not restore `/home/cedric` before installation, restore it now.

Example:

```sh
rsync -aHAX --numeric-ids --info=progress2 \
  /run/media/cedric/backup/framework-13-home/ \
  /home/cedric/
```

Fix ownership if needed:

```sh
sudo chown -R cedric:users /home/cedric
```

Be careful with this command. Only run it for your home directory, not for `/`,
`/nix`, or the backup disk.

Verification:

```sh
ls -la /home/cedric
ls -la /home/cedric/.ssh
```

## 17. Post-Migration Cleanup

Check system health:

```sh
systemctl --failed
journalctl -p warning -b
```

Check boot entries:

```sh
bootctl status
```

Check rebuild:

```sh
nh os switch
```

Or, without `nh`:

```sh
sudo nixos-rebuild switch --flake ~/.config/nixos#nixos
```

Check Git status:

```sh
cd ~/.config/nixos
git status --short
```

Commit the hardware config change once the encrypted system boots and hibernates:

```sh
git add hosts/framework-13/hardware-configuration.nix migrate-to-encrypted.md
git commit -m "Document encrypted NixOS disk migration"
```

## 18. Quick Failure Recovery

### Boot Asks For Passphrase But Cannot Mount Root

Likely causes:

- `fileSystems."/"` points to the LUKS partition UUID instead of the ext4 root
  filesystem UUID.
- LVM modules are missing from initrd.
- The generated config was not copied into the flake config used by install.

Boot the installer, unlock manually, mount, and inspect:

```sh
cryptsetup open "$CRYPT_PART" cryptroot
vgchange -ay
mount /dev/vg/root /mnt
mount "$EFI" /mnt/boot
sed -n '1,220p' /mnt/home/cedric/.config/nixos/hosts/framework-13/hardware-configuration.nix
```

### System Boots But Hibernation Does Not Resume

Likely causes:

- `boot.resumeDevice` is wrong.
- Swap UUID changed after `mkswap`.
- Swap is too small.

Inspect:

```sh
lsblk -f
cat /proc/swaps
cat /proc/cmdline
```

Then update `boot.resumeDevice` to the UUID of `/dev/vg/swap`.

### `swapon` Is Not Found

Use:

```sh
cat /proc/swaps
```

Or try the full path:

```sh
/run/current-system/sw/bin/swapon --show
```

### Need To Reinstall The Bootloader

Boot installer, unlock and mount the system:

```sh
cryptsetup open "$CRYPT_PART" cryptroot
vgchange -ay
mount /dev/vg/root /mnt
mount "$EFI" /mnt/boot
nixos-enter --root /mnt
```

Inside `nixos-enter`:

```sh
bootctl install
nixos-rebuild boot --flake /home/cedric/.config/nixos#nixos
```

Then exit and reboot:

```sh
exit
reboot
```

## 19. Final Acceptance Checklist

The migration is complete when all of these are true:

- Boot prompts for the LUKS passphrase.
- `/` is mounted from the decrypted LVM root volume.
- `/boot` is mounted from the EFI partition.
- Swap is active from the decrypted LVM swap volume.
- `boot.resumeDevice` points to the encrypted swap UUID.
- `systemctl hibernate` powers down and resumes successfully.
- `sudo nixos-rebuild switch --flake ~/.config/nixos#nixos` succeeds.
- Backup data has been restored and checked.
- The hardware config change is committed.
