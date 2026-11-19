# SilverLIT

A custom atomic desktop Linux image built with [BlueBuild](https://blue-build.org/) on top of [Universal Blue Aurora](https://getaurora.dev/) (Fedora Atomic + KDE Plasma), with The Linux IT Guy's personal taste.

Everything is set up out of the box: there are no manual post-install steps.

## What's included

- **Base:** Universal Blue Aurora (`stable`), with automatic background updates
- **Apps:** Brave Browser (RPM); OBS Studio, Steam, Discord and Audacity (Flatpaks, installed automatically on first boot)
- **Terminal:** Starship prompt with the **Gruvbox Rainbow** preset, a Gruvbox Dark Konsole profile and JetBrainsMono Nerd Font, applied to every user, including existing ones
- **One-command extras** via `ujust`:
  - `ujust install-davinci-resolve`: DaVinci Resolve (free or Studio) in a `davincibox` container, with AMD (ROCm OpenCL) or NVIDIA GPU acceleration detected automatically
  - `ujust install-claude-desktop`: Claude Desktop in `~/.local` with automatic updates
  - `ujust silverlit-welcome`: show the first-login welcome again

## Images

| Image | For |
|---|---|
| `ghcr.io/thelinuxitguy/silverlit:latest` | AMD and Intel graphics |
| `ghcr.io/thelinuxitguy/silverlit-nvidia:latest` | NVIDIA graphics (open kernel modules) |

Both are rebuilt daily and signed with cosign.

## Installation / Rebasing

From an existing Aurora or Fedora Atomic (Kinoite/Silverblue) installation, switch to SilverLIT (use `silverlit-nvidia` on NVIDIA systems):

```bash
sudo bootc switch ghcr.io/thelinuxitguy/silverlit:latest
systemctl reboot
```

After the first boot into SilverLIT, switch once more to turn on signature verification for every future update:

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/thelinuxitguy/silverlit:latest
systemctl reboot
```

Check the active deployment:

```bash
sudo bootc status
```

## Optional extras

### DaVinci Resolve

Blackmagic requires a free registration to download Resolve, so that one step stays manual:

1. Download DaVinci Resolve or DaVinci Resolve Studio for Linux from [Blackmagic Design](https://www.blackmagicdesign.com/support/family/davinci-resolve-and-fusion) and extract the `.zip` into `~/Downloads`.
2. Run `ujust install-davinci-resolve`. It finds the newest installer in `~/Downloads` automatically, or you can pass the path: `ujust install-davinci-resolve /path/to/DaVinci_Resolve_*_Linux.run`.
3. On AMD, enable OpenCL in **DaVinci Resolve → Preferences → Memory and GPU** (the script prints the exact steps).

### Claude Desktop

```bash
ujust install-claude-desktop
```

This uses the installer from [ajithakdev/claude-desktop-rpm](https://github.com/ajithakdev/claude-desktop-rpm).

## Customizing your prompt

SilverLIT uses `/usr/share/silverlit/starship.toml` unless you have your own `~/.config/starship.toml`. To customize it:

```bash
cp /usr/share/silverlit/starship.toml ~/.config/starship.toml
```

## Updating

Updates happen automatically in the background. To update right away:

```bash
ujust update
```

## Repository layout

| Path | Purpose |
|---|---|
| `recipes/common-modules.yml` | Modules shared by every variant |
| `recipes/recipe.yml`, `recipes/recipe-nvidia.yml` | Per-variant base image |
| `files/system/` | Files copied into the image root (use `/usr` or `/etc`, never `/usr/local` or `/var`) |
| `files/justfiles/` | `ujust` recipes |
| `files/scripts/` | Build-time scripts |
