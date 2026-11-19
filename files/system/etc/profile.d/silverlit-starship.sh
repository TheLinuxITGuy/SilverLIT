# shellcheck shell=bash
# SilverLIT: Starship prompt for interactive bash shells.
# Uses the SilverLIT Gruvbox Rainbow config unless the user has their own
# ~/.config/starship.toml (copy /usr/share/silverlit/starship.toml there to customize).
if [ -n "${BASH_VERSION:-}" ] && [ -z "${__SILVERLIT_STARSHIP_LOADED:-}" ] && command -v starship >/dev/null 2>&1; then
    case $- in
        *i*)
            __SILVERLIT_STARSHIP_LOADED=1
            if [ -z "${STARSHIP_CONFIG:-}" ] && [ ! -f "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml" ]; then
                export STARSHIP_CONFIG=/usr/share/silverlit/starship.toml
            fi
            eval "$(starship init bash)"
            ;;
    esac
fi
