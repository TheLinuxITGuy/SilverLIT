#!/usr/bin/env bash
# Brand the image as SilverLIT in /usr/lib/os-release (shown in KDE's About This System,
# the boot menu and hostnamectl). ID and VERSION_ID are left untouched so Fedora and
# Universal Blue tooling keep working.
set -euo pipefail

OS_RELEASE=/usr/lib/os-release
# shellcheck source=/dev/null
. "$OS_RELEASE"

sed -i \
    -e 's|^NAME=.*|NAME="SilverLIT"|' \
    -e "s|^PRETTY_NAME=.*|PRETTY_NAME=\"SilverLIT ${VERSION_ID} (based on ${NAME})\"|" \
    -e 's|^HOME_URL=.*|HOME_URL="https://github.com/TheLinuxITGuy/SilverLIT"|' \
    -e 's|^SUPPORT_URL=.*|SUPPORT_URL="https://github.com/TheLinuxITGuy/SilverLIT/issues"|' \
    -e 's|^BUG_REPORT_URL=.*|BUG_REPORT_URL="https://github.com/TheLinuxITGuy/SilverLIT/issues"|' \
    "$OS_RELEASE"

if grep -q '^DEFAULT_HOSTNAME=' "$OS_RELEASE"; then
    sed -i 's|^DEFAULT_HOSTNAME=.*|DEFAULT_HOSTNAME="silverlit"|' "$OS_RELEASE"
else
    echo 'DEFAULT_HOSTNAME="silverlit"' >> "$OS_RELEASE"
fi

echo "os-release now reads:"
cat "$OS_RELEASE"
