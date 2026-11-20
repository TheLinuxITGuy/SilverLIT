#!/usr/bin/env bash
# Brand the image as SilverLIT:
#  - /usr/lib/os-release: name, version, logo and links (KDE About This System, fastfetch,
#    boot menu, hostnamectl). ID/VARIANT_ID stay untouched so Fedora and Universal Blue
#    tooling keep working.
#  - /usr/share/ublue-os/image-info.json: the image the MOTD banner, fastfetch and the
#    ujust rebase/rollback helpers report and use.
set -euo pipefail

REPO_URL="https://github.com/TheLinuxITGuy/SilverLIT"
OS_RELEASE=/usr/lib/os-release
IMAGE_INFO=/usr/share/ublue-os/image-info.json

set_key() {
    local key="$1" value="$2"
    if grep -q "^${key}=" "$OS_RELEASE"; then
        sed -i "s|^${key}=.*|${key}=\"${value}\"|" "$OS_RELEASE"
    else
        echo "${key}=\"${value}\"" >> "$OS_RELEASE"
    fi
}

# shellcheck source=/dev/null
. "$OS_RELEASE"

set_key NAME "SilverLIT"
set_key PRETTY_NAME "SilverLIT ${VERSION_ID}"
set_key VERSION "${IMAGE_VERSION:-${OSTREE_VERSION:-$VERSION_ID}}"
set_key LOGO "silverlit-logo"
set_key DEFAULT_HOSTNAME "silverlit"
set_key HOME_URL "${REPO_URL}"
set_key DOCUMENTATION_URL "${REPO_URL}#readme"
set_key SUPPORT_URL "${REPO_URL}/issues"
set_key BUG_REPORT_URL "${REPO_URL}/issues"

if [[ -f "$IMAGE_INFO" ]]; then
    image_name="silverlit"
    if jq -e '."image-flavor" | test("nvidia")' "$IMAGE_INFO" >/dev/null; then
        image_name="silverlit-nvidia"
    fi
    tmp="$(mktemp)"
    jq --arg name "$image_name" '
        ."image-name" = $name
        | ."image-vendor" = "thelinuxitguy"
        | ."image-ref" = ("ostree-image-signed:docker://ghcr.io/thelinuxitguy/" + $name)
        | ."image-tag" = "latest"
    ' "$IMAGE_INFO" > "$tmp"
    cat "$tmp" > "$IMAGE_INFO"
    rm -f "$tmp"
fi

# Make sure the new icon is picked up by the icon theme cache.
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor || true
fi

echo "os-release now reads:"
cat "$OS_RELEASE"
echo "image-info.json now reads:"
cat "$IMAGE_INFO" 2>/dev/null || true
