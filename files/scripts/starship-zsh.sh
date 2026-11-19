#!/usr/bin/env bash
# Enable Starship for zsh users too (bash is handled by /etc/profile.d/silverlit-starship.sh).
set -euo pipefail

if [[ -f /etc/zshrc ]] && ! grep -q 'starship init zsh' /etc/zshrc; then
    cat >> /etc/zshrc <<'ZSH'

# SilverLIT: Starship prompt
if [[ -o interactive ]] && (( $+commands[starship] )); then
    if [[ -z "${STARSHIP_CONFIG:-}" && ! -f "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml" ]]; then
        export STARSHIP_CONFIG=/usr/share/silverlit/starship.toml
    fi
    eval "$(starship init zsh)"
fi
ZSH
fi
