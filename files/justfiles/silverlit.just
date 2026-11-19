# Install DaVinci Resolve (free or Studio) with GPU acceleration in a davincibox container
[group('SilverLIT')]
install-davinci-resolve installer="":
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -n {{ quote(installer) }} ]]; then
        exec /usr/bin/silverlit-setup-davinci {{ quote(installer) }}
    else
        exec /usr/bin/silverlit-setup-davinci
    fi

# Install Claude Desktop into ~/.local with automatic updates
[group('SilverLIT')]
install-claude-desktop:
    #!/usr/bin/env bash
    set -euo pipefail
    dir="${XDG_DATA_HOME:-$HOME/.local/share}/silverlit"
    mkdir -p "$dir"
    echo "==> Downloading the Claude Desktop installer from github.com/ajithakdev/claude-desktop-rpm"
    curl -fsSL -o "$dir/claude-desktop-rpm.sh" \
        https://github.com/ajithakdev/claude-desktop-rpm/releases/latest/download/claude-desktop-rpm.sh
    chmod +x "$dir/claude-desktop-rpm.sh"
    "$dir/claude-desktop-rpm.sh" install

# Show the SilverLIT welcome screen again
[group('SilverLIT')]
silverlit-welcome:
    /usr/libexec/silverlit-welcome --force
