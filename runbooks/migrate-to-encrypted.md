# Migrate Framework 13 NixOS To Encrypted SSD In Place

This runbook migrates this laptop from the current unencrypted install to an
encrypted root filesystem without external backup storage.

This is possible because the current root filesystem has enough free space to
hold a second temporary copy on the same SSD.

This is not as safe as a real backup. If the SSD fails, a partition command hits
the wrong device, the filesystem shrink corrupts data, or the temporary copy is
incomplete, data can be lost. The copy preserves data; it does not protect data
against same-disk failure.

- Host directory: `hosts/framework-13`
- Flake output: `nixosConfigurations.nixos`
- Current bootloader: `systemd-boot`
- Target filesystem: `ext4`
- Target layout: LUKS + LVM
- Default unlock method: passphrase typed at boot
- Rescue path: bootable NixOS USB installer

Expected result: after the migration, the laptop boots after the LUKS
passphrase and the current root filesystem contents are preserved, including
`/home/cedric`, dotfiles, `/home/cedric/.local`, Wi-Fi profiles,
fingerprints, Docker state, Bluetooth state, NixOS config, `/nix`, and other
state currently stored on `/`.

## 0. Target Layout

Final layout:

```text
SSD
+- GPT
   +- ESP                       /boot        vfat, unencrypted
   +- LUKS partition
      +- cryptroot
         +- LVM VG vg
            +- vg-root          /            ext4, encrypted
            +- vg-swap          swap         encrypted, hibernation-capable
```

Temporary in-place migration layout:

```text
SSD
+- ESP                           /boot       existing vfat
+- old plain root                /oldroot    shrunk ext4
+- temporary encrypted staging   /staging    LUKS + ext4 or LUKS + LVM + ext4
```

Do not try to make the temporary tail partition the final root partition. A
partition created after the old root can grow forward, but it cannot simply
grow backward into the old root's previous disk space. The safe in-place dance
is:

1. Shrink old root.
2. Create encrypted staging in freed tail space.
3. Copy old root to staging.
4. Recreate old root slot as final encrypted root.
5. Copy staging back to final root.
6. Delete staging.
7. Grow final encrypted root forward to the end of the SSD.

## 1. Current Storage Context

Current live layout observed before this runbook was updated:

```text
/dev/nvme0n1      931.5G disk
/dev/nvme0n1p1      1.0G vfat  /boot
/dev/nvme0n1p2    896.8G ext4  /
/dev/nvme0n1p3     33.7G swap  [SWAP]
```

Current root usage observed:

```text
/dev/nvme0n1p2 ext4  882G  401G  437G  48% /
```

Dry-run sizing check from the current booted system passed on 2026-07-07:

```text
root device: /dev/nvme0n1p2
swap device: /dev/nvme0n1p3
shrink target: 460 GiB
staging margin: 50 GiB
partition overhead reserve: 2 GiB
minimum ext4 size: 439616139264 bytes (409.42 GiB)
target old root size: 493921239040 bytes (460.00 GiB)
used root filesystem: 428293079040 bytes (398.88 GiB)
old root partition: 962940210176 bytes (896.81 GiB)
old swap partition: 36186190336 bytes (33.70 GiB)
estimated staging capacity: 503057677824 bytes (468.51 GiB)
required staging capacity: 481980170240 bytes (448.88 GiB)
```

This leaves about 50.58GiB between the `resize2fs -P` minimum and the 460GiB
old-root target, and about 19.63GiB above the required staging capacity. Rerun
the section 5 sizing check from the installer before doing any destructive
operation, because data usage can change.

Current generated hardware config declares plain root and plain swap:

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

After migration, root and swap UUIDs will change. The new encrypted swap device
must be used for both `swapDevices` and `boot.resumeDevice`.

Your current config uses hibernation:

```text
nixos/hibernation.nix
home/features/service/hypridle.nix
home/features/service/power-menu.nix
home/features/service/hyprland/bindings.nix
```

Do not skip hibernation verification.

## 2. Hard Safety Rules

This process intentionally destroys and recreates partitions on the internal
SSD.

Stop unless all of these are true:

- Every rescue USB test in section 3 passes.
- Section 5 sizing check passes from the installer immediately before
  destructive steps.
- You accept that there is no independent backup.

Stop immediately if any command references the wrong disk.

Never format:

- installer USB
- any external disk
- `/dev/nvme0n1p1` ESP, unless intentionally rebuilding boot from scratch

This runbook keeps the existing ESP.

## 3. Create And Test The Rescue USB

Download a current NixOS ISO and write it to the USB key.

Example, replacing `sdX` with the USB key, not the internal SSD:

```sh
lsblk -d -o NAME,MODEL,SIZE,TYPE
sudo dd if=nixos-graphical.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Boot the Framework 13 from this USB once before touching the SSD.

In the installer, verify:

```sh
sudo -i
whoami
ip a
command -v cryptsetup
command -v lvm
command -v e2fsck
command -v resize2fs
command -v rsync
command -v sfdisk
command -v nixos-enter
lsblk -o NAME,PATH,TYPE,SIZE,FSTYPE,FSVER,LABEL,UUID,PARTUUID,MOUNTPOINTS,PKNAME
lsblk -d -o NAME,MODEL,SIZE,SERIAL,TYPE
```

Expected:

- `whoami` prints `root`.
- `ip a` shows network is available, or all needed tools are already present
  in the installer.
- `command -v cryptsetup` succeeds.
- `command -v lvm` succeeds.
- `command -v e2fsck` succeeds.
- `command -v resize2fs` succeeds.
- `command -v rsync` succeeds.
- `command -v sfdisk` succeeds, or another GPT partition tool is available.
- `command -v nixos-enter` succeeds.
- `lsblk` shows the internal SSD.
- `lsblk` shows the expected current partitions:
  `/dev/nvme0n1p1` vfat ESP, `/dev/nvme0n1p2` ext4 root, and
  `/dev/nvme0n1p3` swap.

If this does not work, stop. Fix the rescue path first.

## 4. Boot Installer For The Real Migration

Boot the tested NixOS installer USB and become root:

```sh
sudo -i
```

Connect network if needed:

```sh
nmtui
```

Identify the internal SSD:

```sh
lsblk -o NAME,PATH,TYPE,SIZE,FSTYPE,FSVER,LABEL,UUID,PARTUUID,MOUNTPOINTS,PKNAME
lsblk -d -o NAME,MODEL,SIZE,SERIAL,TYPE
ls -l /dev/disk/by-id/
```

Set variables only after verifying the disk:

```sh
DISK=/dev/nvme0n1
ESP=/dev/nvme0n1p1
OLDROOT=/dev/nvme0n1p2
OLDSWAP=/dev/nvme0n1p3

lsblk "$DISK"
```

Expected:

- `ESP` is the 1G vfat partition.
- `OLDROOT` is the large ext4 root partition.
- `OLDSWAP` is the 33.7G swap partition.

## 5. Measure Old Root Before Shrinking

Run filesystem check:

```sh
e2fsck -f "$OLDROOT"
```

Get minimum ext4 block count:

```sh
resize2fs -P "$OLDROOT"
```

Check used data:

```sh
mkdir -p /oldroot
mount -o ro "$OLDROOT" /oldroot
du -sxh /oldroot
du -sxh /oldroot/home/cedric
du -sxh /oldroot/nix
du -sxh /oldroot/var/lib
```

Verify the shrink target and staging capacity with byte counts:

```sh
SHRINK_TARGET_GIB=460
STAGING_MARGIN_GIB=50
PARTITION_OVERHEAD_GIB=2

MIN_BLOCKS=$(resize2fs -P "$OLDROOT" 2>&1 | awk '/Estimated minimum size/ { print $NF }')
BLOCK_SIZE=$(dumpe2fs -h "$OLDROOT" 2>/dev/null | awk -F: '/Block size/ { gsub(/[ \t]/, "", $2); print $2 }')
MIN_BYTES=$((MIN_BLOCKS * BLOCK_SIZE))

TARGET_BYTES=$((SHRINK_TARGET_GIB * 1024 * 1024 * 1024))
STAGING_MARGIN_BYTES=$((STAGING_MARGIN_GIB * 1024 * 1024 * 1024))
PARTITION_OVERHEAD_BYTES=$((PARTITION_OVERHEAD_GIB * 1024 * 1024 * 1024))

OLDROOT_BYTES=$(blockdev --getsize64 "$OLDROOT")
OLDSWAP_BYTES=$(blockdev --getsize64 "$OLDSWAP")
USED_BYTES=$(du -sxB1 /oldroot | awk '{ print $1 }')

STAGING_BYTES=$((OLDROOT_BYTES + OLDSWAP_BYTES - TARGET_BYTES - PARTITION_OVERHEAD_BYTES))

printf 'minimum ext4 bytes: %s\n' "$MIN_BYTES"
printf 'target old root bytes: %s\n' "$TARGET_BYTES"
printf 'used old root bytes: %s\n' "$USED_BYTES"
printf 'estimated staging bytes: %s\n' "$STAGING_BYTES"

test "$TARGET_BYTES" -gt "$MIN_BYTES"
test "$STAGING_BYTES" -gt "$((USED_BYTES + STAGING_MARGIN_BYTES))"
```

The first `test` proves the shrunken old root remains larger than the ext4
minimum reported by `resize2fs -P`. The second `test` proves the freed tail
space can hold the full root copy plus a 50GiB margin.

Unmount old root after the checks:

```sh
umount /oldroot
```

Use a 460GiB partition target only if both `test` commands succeed. The
filesystem shrink command below uses `459G` on purpose, leaving about 1GiB of
slack inside the resized 460GiB partition. If the checks fail, choose a larger
old root partition target and recalculate. If a larger old root size makes
staging too small, stop and free space or get external storage.

Stop if the numbers do not fit.

## 6. Shrink Old Root And Free Tail Space

Disable old swap:

```sh
swapoff "$OLDSWAP" || true
```

Shrink old root filesystem:

```sh
e2fsck -f "$OLDROOT"
resize2fs "$OLDROOT" 459G
e2fsck -f "$OLDROOT"
```

Shrink old root partition to 460GiB and delete old swap with the exact `sfdisk`
commands below. Do not use an interactive partition editor for this step unless
these commands fail and you have rechecked the sector math.

Save the current partition table first:

```sh
sfdisk -d "$DISK" | tee /tmp/nvme0n1.before.sfdisk
```

Verify the expected current geometry and calculate the new partition 2 size:

```sh
SECTOR_SIZE=$(blockdev --getss "$DISK")
P2_START=$(lsblk -bn -o START "$OLDROOT")
P3_START=$(lsblk -bn -o START "$OLDSWAP")
P2_TYPE=$(
  sfdisk -d "$DISK" |
    awk -v part="$OLDROOT" '$1 == part {
      for (i = 1; i <= NF; i++) {
        if ($i ~ /^type=/) {
          sub(/^type=/, "", $i)
          sub(/,$/, "", $i)
          print $i
        }
      }
    }'
)

test "$SECTOR_SIZE" = 512
test "$P2_START" = 2101248
test -n "$P2_TYPE"

P2_TARGET_GIB=460
P2_TARGET_SECTORS=$((P2_TARGET_GIB * 1024 * 1024 * 1024 / SECTOR_SIZE))
P2_TARGET_END=$((P2_START + P2_TARGET_SECTORS - 1))

printf 'sector size: %s\n' "$SECTOR_SIZE"
printf 'partition 2 start: %s\n' "$P2_START"
printf 'partition 2 target sectors: %s\n' "$P2_TARGET_SECTORS"
printf 'partition 2 target end: %s\n' "$P2_TARGET_END"
printf 'partition 3 old start: %s\n' "$P3_START"
printf 'partition 2 type: %s\n' "$P2_TYPE"

test "$P2_TARGET_END" -lt "$P3_START"
```

Expected for this laptop:

```text
sector size: 512
partition 2 start: 2101248
partition 2 target sectors: 964689920
partition 2 target end: 966791167
```

Stop if any `test` fails. The most important invariant is that partition 2
keeps start sector `2101248`.

Delete old swap partition 3:

```sh
sfdisk --wipe never --wipe-partitions never --delete "$DISK" 3
```

Rewrite partition 2 with the same start sector and a 460GiB size:

```sh
printf 'start=%s, size=%s, type=%s\n' \
  "$P2_START" "$P2_TARGET_SECTORS" "$P2_TYPE" |
  sfdisk --wipe never --wipe-partitions never -N 2 "$DISK"
```

Re-read the table:

```sh
partprobe "$DISK" || true
udevadm settle
lsblk "$DISK"
e2fsck -f "$OLDROOT"
```

Verify the result:

```sh
test "$(lsblk -bn -o START "$OLDROOT")" = "$P2_START"
test "$(lsblk -bn -o SIZE "$OLDROOT")" = "$((P2_TARGET_SECTORS * SECTOR_SIZE))"
if lsblk "$OLDSWAP" >/dev/null 2>&1; then
  echo "old swap partition still exists; stop"
  exit 1
fi
```

Stop if partition 2 no longer starts at the same sector as before, if its size
does not match the target size, or if old swap partition 3 still exists.

## 7. Create Temporary Encrypted Staging

Create a new partition in the freed tail space. This runbook assumes it becomes
`/dev/nvme0n1p3`.

```sh
STAGING_PART=/dev/nvme0n1p3
```

Create partition 3 from the free space after the shrunken partition 2:

```sh
P2_START=$(lsblk -bn -o START "$OLDROOT")
P2_SIZE=$(lsblk -bn -o SIZE "$OLDROOT")
SECTOR_SIZE=$(blockdev --getss "$DISK")
STAGING_START=$((P2_START + P2_SIZE / SECTOR_SIZE))
LAST_LBA=$(sfdisk -d "$DISK" | awk '/^last-lba:/ { print $2 }')
STAGING_SECTORS=$((LAST_LBA - STAGING_START + 1))
P2_TYPE=$(
  sfdisk -d "$DISK" |
    awk -v part="$OLDROOT" '$1 == part {
      for (i = 1; i <= NF; i++) {
        if ($i ~ /^type=/) {
          sub(/^type=/, "", $i)
          sub(/,$/, "", $i)
          print $i
        }
      }
    }'
)

test -n "$P2_TYPE"
test "$STAGING_SECTORS" -gt 0

printf 'start=%s, size=%s, type=%s\n' \
  "$STAGING_START" "$STAGING_SECTORS" "$P2_TYPE" |
  sfdisk --wipe never --wipe-partitions never --append "$DISK"

partprobe "$DISK" || true
udevadm settle
lsblk "$DISK"
test "$(lsblk -bn -o START "$STAGING_PART")" = "$STAGING_START"
```

Format and open temporary LUKS:

Choose a temporary staging passphrase here. You only need it until staging is
deleted in section 9.

```sh
cryptsetup luksFormat "$STAGING_PART"
cryptsetup open "$STAGING_PART" cryptstaging
mkfs.ext4 -L staging /dev/mapper/cryptstaging
```

Mount source and staging:

```sh
mkdir -p /oldroot /staging
mount -o ro "$OLDROOT" /oldroot
mount /dev/mapper/cryptstaging /staging
```

Copy the complete old root:

```sh
rsync -aHAX --numeric-ids --info=progress2 \
  /oldroot/ \
  /staging/
```

The trailing slash matters. This copies dotfiles and hidden directories,
including `/home/cedric/.local`, `/home/cedric/.config`, `/home/cedric/.ssh`,
`/home/cedric/.gnupg`, browser profiles, and keyrings.

Verify the staging copy:

```sh
du -sxh /oldroot /staging
ls -la /staging/home/cedric
ls -la /staging/home/cedric/.local
ls -la /staging/home/cedric/.config/nixos
ls -la /staging/etc/NetworkManager/system-connections || true
ls -la /staging/var/lib/docker || true
ls -la /staging/var/lib/fprint || true
ls -la /staging/var/lib/bluetooth || true
```

Stop if important data is missing.

## 8. Recreate Old Root Slot As Final Encrypted Root

Unmount old root:

```sh
umount /oldroot
```

Create final LUKS on the old root partition. Do not create swap yet: the
temporary 460GiB root slot is large enough for the data copy, but not for the
data copy plus an 80GiB swap LV. Swap is created after the final partition is
grown.

Choose the real boot passphrase here. This is the passphrase typed at every
boot after migration.

```sh
cryptsetup luksFormat "$OLDROOT"
cryptsetup open "$OLDROOT" cryptroot
pvcreate /dev/mapper/cryptroot
vgcreate vg /dev/mapper/cryptroot
lvcreate -l 100%FREE -n root vg
mkfs.ext4 -L nixos /dev/vg/root
```

Mount final root:

```sh
mkdir -p /mnt
mount /dev/vg/root /mnt
```

Verify the temporary final root can hold the staging copy before copying back:

```sh
STAGING_USED_BYTES=$(du -sxB1 /staging | awk '{ print $1 }')
FINAL_AVAIL_BYTES=$(df -B1 --output=avail /mnt | tail -n1 | tr -d ' ')

printf 'staging used bytes: %s\n' "$STAGING_USED_BYTES"
printf 'final root available bytes: %s\n' "$FINAL_AVAIL_BYTES"

test "$FINAL_AVAIL_BYTES" -gt "$STAGING_USED_BYTES"
```

Stop if the final root does not have more available bytes than staging uses.

Copy staging back into final root:

```sh
rsync -aHAX --numeric-ids --info=progress2 \
  /staging/ \
  /mnt/
```

Verify final root:

```sh
du -sxh /staging /mnt
ls -la /mnt/home/cedric
ls -la /mnt/home/cedric/.local
ls -la /mnt/home/cedric/.config/nixos
ls -la /mnt/etc/NetworkManager/system-connections || true
ls -la /mnt/var/lib/docker || true
ls -la /mnt/var/lib/fprint || true
ls -la /mnt/var/lib/bluetooth || true
```

Stop if important data is missing.

## 9. Delete Staging, Grow Final Root, And Create Swap

Only do this after final root copy is verified.

Leave the final root cleanly unmounted before editing GPT. This avoids resizing
a busy partition:

```sh
sync
umount /mnt
vgchange -an vg
cryptsetup close cryptroot
```

Unmount staging and close temporary LUKS:

```sh
umount /staging
cryptsetup close cryptstaging
```

Delete staging partition 3, then grow partition 2 forward to the end of the
disk. Partition 2 must keep the same start sector.

```sh
P2_START=$(lsblk -bn -o START "$OLDROOT")
P2_TYPE=$(
  sfdisk -d "$DISK" |
    awk -v part="$OLDROOT" '$1 == part {
      for (i = 1; i <= NF; i++) {
        if ($i ~ /^type=/) {
          sub(/^type=/, "", $i)
          sub(/,$/, "", $i)
          print $i
        }
      }
    }'
)

test "$P2_START" = 2101248
test -n "$P2_TYPE"

sfdisk --wipe never --wipe-partitions never --delete "$DISK" 3

LAST_LBA=$(sfdisk -d "$DISK" | awk '/^last-lba:/ { print $2 }')
P2_GROWN_SECTORS=$((LAST_LBA - P2_START + 1))

printf 'start=%s, size=%s, type=%s\n' \
  "$P2_START" "$P2_GROWN_SECTORS" "$P2_TYPE" |
  sfdisk --wipe never --wipe-partitions never -N 2 "$DISK"

partprobe "$DISK" || true
udevadm settle
lsblk "$DISK"

test "$(lsblk -bn -o START "$OLDROOT")" = "$P2_START"
```

Reopen and resize the final encrypted stack. Create swap now, after the PV has
grown:

```sh
cryptsetup open "$OLDROOT" cryptroot
vgchange -ay
cryptsetup resize cryptroot
pvresize /dev/mapper/cryptroot
lvcreate -L 80G -n swap vg
mkswap -L swap /dev/vg/swap
lvextend -l +100%FREE /dev/vg/root
resize2fs /dev/vg/root
```

Mount final root and ESP:

```sh
mount /dev/vg/root /mnt
mkdir -p /mnt/boot
mount "$ESP" /mnt/boot
df -h /mnt
lvs
vgs
lsblk "$DISK"
```

## 10. Update NixOS Storage Config On Final Root

Edit `/mnt/home/cedric/.config/nixos/hosts/framework-13/hardware-configuration.nix`.

Keep generated kernel modules, platform, DHCP default, and CPU microcode. Replace
old plain root and swap declarations with encrypted root, ESP, encrypted swap,
and resume device.

Use stable IDs from the installer:

```sh
blkid "$OLDROOT"
blkid "$ESP"
blkid /dev/vg/swap
```

Target shape:

```nix
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
      luks.devices.cryptroot.device = "/dev/disk/by-uuid/<OLDROOT-LUKS-UUID>";
    };
    kernelModules = [ "kvm-amd" ];
    resumeDevice = "/dev/disk/by-uuid/<SWAP-UUID>";
  };

  fileSystems."/" = {
    device = "/dev/vg/root";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/<ESP-UUID>";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/<SWAP-UUID>"; } ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
```

Do not use the old plain root UUID
`13f2c8e5-c67d-4ef2-8a64-3dca476711b0`.

Do not use the old plain swap UUID
`c3e47598-fe43-43c0-8f9f-f5116a28f86f`.

## 11. Rebuild Boot From The Installer

Bind system mounts and enter the final root:

```sh
mkdir -p /mnt/dev /mnt/proc /mnt/sys /mnt/run
mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
mount --bind /run /mnt/run
nixos-enter --root /mnt
```

Inside `nixos-enter`, rebuild boot:

```sh
nixos-rebuild boot --flake /home/cedric/.config/nixos#nixos
bootctl install
exit
```

If evaluation fails, fix it before rebooting.

## 12. Back Up The LUKS Header If Any Storage Exists Later

No independent backup device exists during this plan. That means the LUKS
header is not protected.

When any external storage becomes available, back up the final LUKS header:

```sh
cryptsetup luksHeaderBackup "$OLDROOT" \
  --header-backup-file /path/on/external/storage/luks-header-cryptroot.img
```

Never store the only LUKS header backup only on the encrypted SSD it protects.

## 13. First Reboot

Unmount and reboot:

```sh
umount -R /mnt
reboot
```

Expected boot flow:

- Firmware loads `systemd-boot`.
- NixOS initrd starts.
- LUKS passphrase prompt appears.
- Root unlocks after the correct passphrase.
- Login manager starts.
- User session opens with restored data.

If it does not boot, use the rescue section below.

## 14. Verify The Booted System

After logging in:

```sh
lsblk -f
findmnt /
findmnt /boot
swapon --show
cat /proc/cmdline
```

Expected:

- `/` is mounted from `/dev/mapper/vg-root`, `/dev/vg/root`, or equivalent.
- `/boot` is `vfat` on the ESP.
- swap is active from `/dev/mapper/vg-swap`, `/dev/vg/swap`, or equivalent.
- kernel command line contains a resume target for encrypted swap.

Verify NixOS rebuild:

```sh
sudo nixos-rebuild dry-build --flake ~/.config/nixos#nixos
```

If dry build succeeds, test a real switch:

```sh
sudo nixos-rebuild switch --flake ~/.config/nixos#nixos
```

Or with your normal helper:

```sh
nh os switch
```

## 15. Verify Preserved State

Home data and hidden files:

```sh
ls -la /home/cedric
ls -la /home/cedric/.local
ls -la /home/cedric/.config
ls -la /home/cedric/.ssh
ls -la /home/cedric/.gnupg
ls -la /home/cedric/.local/share/keyrings
```

NixOS config:

```sh
cd /home/cedric/.config/nixos
git status --short
nix flake metadata
```

Wi-Fi:

```sh
nmcli connection show
```

Expected:

- Known Wi-Fi/VPN profiles are present.
- Reconnection works without recreating profiles.

Fingerprints:

```sh
fprintd-list cedric
```

If enrollments are rejected, reenroll:

```sh
fprintd-enroll cedric
```

Docker:

```sh
systemctl status docker --no-pager
docker ps -a
docker volume ls
```

Bluetooth:

```sh
bluetoothctl devices
```

Also open browser, password manager, terminal, editor, and main projects.

## 16. Verify Hibernation

Because this machine uses `suspend-then-hibernate`, test hibernation explicitly.

Confirm resume config:

```sh
grep -n "resumeDevice\|swapDevices" ~/.config/nixos/hosts/framework-13/hardware-configuration.nix
cat /proc/cmdline
swapon --show
```

Test:

```sh
systemctl hibernate
```

Expected:

- Machine powers off after writing memory to encrypted swap.
- On power-on, LUKS passphrase is requested.
- Previous session resumes.

If hibernation fails:

```sh
journalctl -b -1 -u systemd-hibernate.service
journalctl -b -1 | grep -i 'hibernate\|resume\|swap'
```

Common causes:

- swap LV smaller than RAM usage at hibernation time
- `boot.resumeDevice` missing or wrong
- swap UUID changed after formatting
- initrd did not activate LUKS/LVM early enough

## 17. Rescue: Boot Failure

Boot the NixOS installer USB, become root, and identify partitions:

```sh
sudo -i
lsblk -f
```

Unlock LUKS:

```sh
cryptsetup open /dev/nvme0n1p2 cryptroot
```

Activate LVM:

```sh
vgchange -ay
```

Mount root and boot:

```sh
mount /dev/vg/root /mnt
mount /dev/nvme0n1p1 /mnt/boot
```

Enter the installed system:

```sh
mkdir -p /mnt/dev /mnt/proc /mnt/sys /mnt/run
mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
mount --bind /run /mnt/run
nixos-enter --root /mnt
```

Inside `nixos-enter`, repair boot config:

```sh
nixos-rebuild boot --flake /home/cedric/.config/nixos#nixos
bootctl install
```

Exit and reboot:

```sh
exit
umount -R /mnt
reboot
```

## 18. Rescue: LUKS Opens But Root Does Not Mount

From the installer:

```sh
cryptsetup open /dev/nvme0n1p2 cryptroot
vgchange -ay
lsblk -f
lvs
vgs
```

Verify:

- `cryptroot` exists.
- `vg-root` exists.
- `vg-swap` exists.
- `vg-root` has `ext4`.

If `/dev/vg/root` exists, mount it:

```sh
mount /dev/vg/root /mnt
```

Inspect config:

```sh
sed -n '1,220p' /mnt/home/cedric/.config/nixos/hosts/framework-13/hardware-configuration.nix
```

Look for:

- missing LUKS unlock config
- missing LVM activation in initrd
- wrong root filesystem device
- wrong swap resume device

## 19. Rescue: Wi-Fi Missing After Boot

Check restored files:

```sh
sudo ls -la /etc/NetworkManager/system-connections
sudo find /etc/NetworkManager/system-connections -maxdepth 1 -type f -printf '%m %u %g %p\n'
```

Fix ownership and permissions:

```sh
sudo chown root:root /etc/NetworkManager/system-connections/*
sudo chmod 600 /etc/NetworkManager/system-connections/*
sudo systemctl restart NetworkManager
```

Then check:

```sh
nmcli connection show
```

## 20. Final Acceptance Checklist

Migration is complete when all are true:

- NixOS installer USB booted and was proven usable before partition edits.
- Old root was copied to encrypted staging with `rsync -aHAX --numeric-ids`.
- Staging was inspected before old root was reformatted.
- Staging was copied back to final encrypted root.
- `/home/cedric` exists.
- `/home/cedric/.local` exists.
- `/home/cedric/.config/nixos` exists.
- NetworkManager profiles exist and Wi-Fi works.
- Fingerprints work, or old enrollment was rejected and reenrolled.
- Docker state exists if you chose to keep it.
- Bluetooth state exists if needed.
- LUKS passphrase prompt appears at boot.
- `/` is mounted from encrypted `vg-root`.
- `/boot` is mounted from the ESP.
- swap is active from encrypted `vg-swap`.
- `systemctl hibernate` powers off and resumes.
- `sudo nixos-rebuild switch --flake ~/.config/nixos#nixos` succeeds.
- Only `migrate-to-encrypted.md` changed in the repo.
