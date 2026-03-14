#!/usr/bin/env sh
# Lights PI Show — GTK3 GUI launcher (Linux)
# Usage:
#   ./Lights_GUI.sh
#   ./Lights_GUI.sh --test

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
cd "$SCRIPT_DIR"

VENV_DIR="$SCRIPT_DIR/.venv"
PYTHON="$VENV_DIR/bin/python3"
AUTO_YES=0

show_help() {
        cat <<'EOF'
Lights PI Show GTK launcher (Linux)

Usage:
    ./Lights_GUI.sh [launcher-options] [gui.py-options]

Launcher options:
    --yes, -y     Auto-confirm all dependency and pip install prompts
    --help, -h    Show this help and exit

Examples:
    ./Lights_GUI.sh
    ./Lights_GUI.sh --yes
    ./Lights_GUI.sh --test
EOF
}

prompt_yes_no() {
    prompt="$1"
    default="${2:-Y}"
    if [ "$AUTO_YES" -eq 1 ]; then
        return 0
    fi
    while :; do
        printf "%s " "$prompt"
        read -r answer || return 1
        [ -z "$answer" ] && answer="$default"
        case "$answer" in
            y|Y|yes|YES) return 0 ;;
            n|N|no|NO) return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}

run_as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        echo "Root privileges are required to install system packages." >&2
        return 1
    fi
}

ensure_apt_packages() {
    if [ "$#" -eq 0 ]; then
        return 0
    fi
    if ! command -v apt-get >/dev/null 2>&1; then
        echo "apt-get not found. Please install these packages manually: $*" >&2
        return 1
    fi
    if prompt_yes_no "Missing system packages: $*. Install now? [Y/n]" "Y"; then
        run_as_root apt-get update
        run_as_root apt-get install -y "$@"
        return 0
    fi
    echo "Dependency installation canceled." >&2
    return 1
}

FILTERED_ARGS=""
while [ "$#" -gt 0 ]; do
    case "$1" in
        --yes|-y)
            AUTO_YES=1
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            FILTERED_ARGS="$FILTERED_ARGS
$1"
            ;;
    esac
    shift
done

if [ -n "$FILTERED_ARGS" ]; then
    OLD_IFS="$IFS"
    IFS='
'
    # shellcheck disable=SC2086
    set -- $FILTERED_ARGS
    IFS="$OLD_IFS"
else
    set --
fi

if ! command -v python3 >/dev/null 2>&1; then
    ensure_apt_packages python3 || exit 1
fi

if ! python3 -m venv -h >/dev/null 2>&1; then
    ensure_apt_packages python3-venv || exit 1
fi

if [ ! -f "$PYTHON" ]; then
    echo "Creating virtual environment at $VENV_DIR ..."
    python3 -m venv --system-site-packages "$VENV_DIR"
fi

if ! "$PYTHON" -m pip --version >/dev/null 2>&1; then
    echo "pip is missing in $VENV_DIR, bootstrapping with ensurepip ..."
    "$PYTHON" -m ensurepip --upgrade
fi

if [ -f "$SCRIPT_DIR/requirements.txt" ]; then
    if prompt_yes_no "Install/upgrade Python dependencies from requirements.txt? [Y/n]" "Y"; then
        "$PYTHON" -m pip install -r "$SCRIPT_DIR/requirements.txt"
    fi
fi

# GTK3/PyGObject are system packages on Linux (not installed via pip)
if ! "$PYTHON" -c 'import gi; gi.require_version("Gtk", "3.0"); from gi.repository import Gtk' >/dev/null 2>&1; then
    ensure_apt_packages python3-gi python3-gi-cairo gir1.2-gtk-3.0 || exit 1

    if ! "$PYTHON" -c 'import gi; gi.require_version("Gtk", "3.0"); from gi.repository import Gtk' >/dev/null 2>&1; then
        echo "GTK3 / PyGObject still unavailable after install." >&2
        echo "Try recreating .venv or run with system python: python3 gui.py" >&2
        exit 1
    fi
fi

exec "$PYTHON" gui.py "$@"
