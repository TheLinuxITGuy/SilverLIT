# SilverLIT &nbsp; [![bluebuild build badge](https://github.com/TheLinuxITGuy/SilverLIT/actions/workflows/build.yml/badge.svg)](https://github.com/TheLinuxITGuy/SilverLIT/actions/workflows/build.yml)

A custom [Aurora](https://getaurora.dev/) OCI desktop image built with [BlueBuild](https://blue-build.org/), tailored for content creation, Linux workflows, and gaming.

## What's Included

### System Packages (RPM)
- **Brave Origin** (`brave-origin`) — Installed natively via Brave's official RPM repository.
- **Starship** (`starship`) — Pre-configured system-wide with the **Gruvbox Rainbow** preset (`/etc/skel/.config/starship.toml`).

### Pre-Installed System Flatpaks
Automatically installed from Flathub on first boot via `default-flatpaks`:
- **OBS Studio** (`com.obsproject.Studio`)
- **Steam** (`com.valvesoftware.Steam`)
- **Discord** (`com.discordapp.Discord`)
- **Audacity** (`org.audacityteam.Audacity`)

---

## Installation

> [!WARNING]  
> Switching to a custom atomic image replaces your base OS deployment. Make sure you have backups and know how to roll back (`rpm-ostree rollback` or selecting the previous boot entry in GRUB) before rebasing.

### Using `bootc` (Recommended on Aurora)

1. Switch to the signed image:
   ```bash
   sudo bootc switch ghcr.io/thelinuxitguy/silverlit:latest
   ```
2. Reboot to complete the switch:
   ```bash
   systemctl reboot
   ```

### Using `rpm-ostree` (Two-Step Signed Rebase)

If you are rebasing from a stock Fedora Atomic image that does not yet have this repository's signing keys/policies:

1. Rebase to the unsigned image first to install the signing policy and public key:
   ```bash
   rpm-ostree rebase ostree-unverified-registry:ghcr.io/thelinuxitguy/silverlit:latest
   ```
2. Reboot:
   ```bash
   systemctl reboot
   ```
3. Rebase to the signed image:
   ```bash
   rpm-ostree rebase ostree-image-signed:docker://ghcr.io/thelinuxitguy/silverlit:latest
   ```
4. Reboot again:
   ```bash
   systemctl reboot
   ```

---

## Post-Install Apps

For proprietary or Debian-only tools that are best kept outside the base OS image:

- **DaVinci Resolve Studio:** Download and extract the Linux `.zip` from Blackmagic Design, then run Aurora's built-in `davincibox` helper:
  ```bash
  ujust install-resolve
  ```
- **Claude Desktop:** Install in user space via [`claude-desktop-rpm`](https://github.com/ajithakdev/claude-desktop-rpm):
  ```bash
  curl -fLO https://github.com/ajithakdev/claude-desktop-rpm/releases/latest/download/claude-desktop-rpm.sh
  chmod +x claude-desktop-rpm.sh && ./claude-desktop-rpm.sh install
  ```

---

## ISO Generation

You can generate an offline installer ISO from any Fedora Atomic host using the [BlueBuild ISO instructions](https://blue-build.org/how-to/generate-iso/#_top):

```bash
bluebuild generate-iso --iso-name silverlit.iso image ghcr.io/thelinuxitguy/silverlit:latest
```

---

## Verification

All images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the image signature using the `cosign.pub` file in this repository:

```bash
cosign verify --key cosign.pub ghcr.io/thelinuxitguy/silverlit:latest
```
