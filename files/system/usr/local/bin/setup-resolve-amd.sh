#!/usr/bin/env bash
set -euo pipefail

# Setup DaVinci Resolve Studio inside a davincibox Distrobox container on AMD GPUs.
# Usage: setup-resolve-amd.sh [/path/to/DaVinci_Resolve_*_Linux.run_or_AppRun]

CONTAINER_NAME="davincibox"
CONTAINER_IMAGE="ghcr.io/zelikos/davincibox:latest"
DEFAULT_INSTALLER="/var/home/${USER}/Downloads/DaVinci_Resolve_Studio_21.2_Linux/DaVinci_Resolve_Studio_21.2_Linux.run"
INPUT_PATH="${1:-}"
WORK_DIR=""

cleanup() {
    if [[ -n "$WORK_DIR" && -d "$WORK_DIR" ]]; then
        rm -rf "$WORK_DIR"
    fi
}
trap cleanup EXIT

find_installer() {
    if [[ -n "$INPUT_PATH" ]]; then
        echo "$INPUT_PATH"
        return 0
    fi

    if [[ -f "$DEFAULT_INSTALLER" ]]; then
        echo "$DEFAULT_INSTALLER"
        return 0
    fi

    local found
    found=$(find "/var/home/${USER}/Downloads" -maxdepth 3 \( -name "DaVinci_Resolve_*_Linux.run" -o -path "*/squashfs-root/AppRun" \) 2>/dev/null | sort -V | tail -n 1)
    if [[ -n "$found" ]]; then
        echo "$found"
        return 0
    fi

    return 1
}

INSTALLER=$(find_installer) || {
    echo "Error: Could not find DaVinci Resolve installer at $DEFAULT_INSTALLER or in /var/home/${USER}/Downloads."
    echo "Download and extract Blackmagic's Linux archive first, or pass the path explicitly:"
    echo "  $0 /var/home/${USER}/Downloads/DaVinci_Resolve_Studio_21.2_Linux/DaVinci_Resolve_Studio_21.2_Linux.run"
    exit 1
}

if [[ "$INSTALLER" == *.run ]]; then
    echo "==> Extracting AppImage from: $INSTALLER"
    WORK_DIR=$(mktemp -d /tmp/resolve-extract.XXXXXX)
    chmod +x "$INSTALLER"
    (cd "$WORK_DIR" && "$INSTALLER" --appimage-extract >/dev/null)
    APPRUN_PATH="$WORK_DIR/squashfs-root/AppRun"
elif [[ "$(basename "$INSTALLER")" == "AppRun" ]]; then
    APPRUN_PATH="$(realpath "$INSTALLER")"
else
    echo "Error: Unsupported file '$INSTALLER'. Expected a .run installer or squashfs-root/AppRun."
    exit 1
fi

if [[ ! -f "$APPRUN_PATH" ]]; then
    echo "Error: AppRun not found at $APPRUN_PATH"
    exit 1
fi

if ! distrobox list --no-color | awk '{print $3}' | grep -qx "$CONTAINER_NAME"; then
    echo "==> Creating $CONTAINER_NAME Distrobox container..."
    distrobox create -i "$CONTAINER_IMAGE" -n "$CONTAINER_NAME" --yes
else
    echo "==> Distrobox container '$CONTAINER_NAME' already exists."
fi

echo "==> Installing AMD ROCm OpenCL support (rocm-opencl, clinfo) inside $CONTAINER_NAME..."
distrobox enter "$CONTAINER_NAME" -- sudo dnf install -y rocm-opencl clinfo

echo "==> Verifying OpenCL GPU detection inside $CONTAINER_NAME..."
distrobox enter "$CONTAINER_NAME" -- clinfo | grep -E "Platform Name|Device Name|Number of devices" || true

echo "==> Running setup-davinci inside $CONTAINER_NAME..."
distrobox enter "$CONTAINER_NAME" -- setup-davinci "$APPRUN_PATH" distrobox

echo ""
echo "Done! Next steps in DaVinci Resolve:"
echo "  1. Open DaVinci Resolve -> Preferences -> Memory and GPU"
echo "  2. Uncheck 'Auto' next to GPU processing mode and select 'OpenCL'"
echo "  3. Check your AMD Radeon GPU, click Save, and restart DaVinci Resolve"
