# SilverLIT

A custom atomic desktop Linux image built with [BlueBuild](https://blue-build.org/) on top of [Universal Blue Aurora](https://getaurora.dev/) (`ghcr.io/ublue-os/aurora`).

## Features

- **Base Image:** Universal Blue Aurora (Fedora Atomic / KDE Plasma)
- **Pre-installed System Packages:** Brave Browser, Starship prompt
- **Pre-configured Skeleton (`/etc/skel`):**
  - Starship prompt configured with the **Gruvbox Rainbow** preset
  - Custom Konsole profile and defaults
- **Included Helper Scripts (`/usr/local/bin`):**
  - `setup-resolve-amd.sh` — Automates installing DaVinci Resolve Studio inside a `davincibox` Distrobox container with AMD ROCm OpenCL GPU acceleration.

---

## Installation / Rebasing

From an existing Aurora or Fedora Atomic (Kinoite/Silverblue) installation, rebase to the signed `silverlit` image:

```bash
sudo bootc switch ghcr.io/thelinuxitguy/silverlit:latest
systemctl reboot
```

Verify the active deployment after rebooting:

```bash
sudo bootc status
```

---

## Post-Install Procedures

### 1. Apply Starship & Konsole Configs (Existing Home Directories)

`/etc/skel` automatically seeds `~/.config/starship.toml` and Konsole profiles for newly created user accounts. If you rebased an existing user account whose home directory already existed, copy the skeleton files over:

```bash
mkdir -p ~/.config ~/.local/share/konsole
cp -n /etc/skel/.config/starship.toml ~/.config/starship.toml
cp -n /etc/skel/.config/konsolerc ~/.config/konsolerc 2>/dev/null || true
cp -n /etc/skel/.local/share/konsole/* ~/.local/share/konsole/ 2>/dev/null || true
```

Open a new Konsole tab or reload your shell (`exec "$SHELL"`) to activate the Gruvbox Rainbow prompt.

---

### 2. Install DaVinci Resolve Studio (AMD GPU)

`SilverLIT` includes `setup-resolve-amd.sh` in `/usr/local/bin/` to automate creating the `davincibox` container, installing `rocm-opencl` and `clinfo`, extracting the Blackmagic installer, and running `setup-davinci`.

1. **Download and extract the Linux installer:**
   Download DaVinci Resolve Studio for Linux from [Blackmagic Design](https://www.blackmagicdesign.com/support/family/davinci-resolve-and-fusion) and extract the `.zip` archive into `~/Downloads` so the `.run` installer is located at:
   ```text
   /var/home/$USER/Downloads/DaVinci_Resolve_Studio_21.2_Linux/DaVinci_Resolve_Studio_21.2_Linux.run
   ```

2. **Run the automated setup script:**
   ```bash
   setup-resolve-amd.sh
   ```
   *(If your `.run` installer is in a different directory or uses a different version number, pass the path directly: `setup-resolve-amd.sh /path/to/DaVinci_Resolve_*_Linux.run`.)*

3. **Enable OpenCL GPU Acceleration in DaVinci Resolve:**
   - Launch **DaVinci Resolve** from the KDE Application Launcher.
   - Open **DaVinci Resolve → Preferences → Memory and GPU**.
   - Uncheck **Auto** next to **GPU processing mode** and select **OpenCL**.
   - Under **GPU selection**, uncheck **Auto** if needed, ensure your **AMD Radeon Graphics** device is checked, click **Save**, and restart DaVinci Resolve.

---

### 3. Install Claude Desktop (Optional)

To install Claude Desktop in `~/.local` with automatic update support:

```bash
curl -fLO https://github.com/ajithakdev/claude-desktop-rpm/releases/latest/download/claude-desktop-rpm.sh
chmod +x claude-desktop-rpm.sh && ./claude-desktop-rpm.sh install
```

---

### 4. Verify Pre-Installed Flatpaks

Confirm that background Flatpak installations (such as OBS Studio, Steam, Discord, and Audacity) have completed:

```bash
flatpak list
```

---

## Updating the System

To pull the latest `SilverLIT` image build and Flatpak updates:

```bash
sudo bootc upgrade
flatpak update -y
systemctl reboot
```