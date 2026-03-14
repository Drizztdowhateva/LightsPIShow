#!/usr/bin/env sh
# Lights PI Show — CLI launcher
# Usage:
#   sudo ./Lights.sh                     # interactive setup, then start
#   sudo ./Lights.sh --pattern 1 ...    # pass args directly to into.py
#   sudo ./Lights.sh --headless         # skip prompt, use default headless config
#   sudo ./Lights.sh --SOS              # emergency SOS shortcut
#   sudo ./Lights.sh --test             # ASCII simulation (no hardware needed)

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
cd "$SCRIPT_DIR"

VENV_DIR="$SCRIPT_DIR/.venv"
AUTO_YES=0

show_help() {
        cat <<'EOF'
Lights PI Show CLI launcher

Usage:
    ./Lights.sh [launcher-options] [into.py-options]

Launcher options:
    --yes, -y     Auto-confirm all dependency and pip install prompts
    --help, -h    Show this help and exit

Examples:
    ./Lights.sh
    ./Lights.sh --yes --headless --headless-config headless/headless_settings.json
    ./Lights.sh --test --pattern 5 --speed 6
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

ensure_venv_pip() {
    if "$PYTHON" -m pip --version >/dev/null 2>&1; then
        return 0
    fi

    echo "pip is missing in $VENV_DIR."

    # Preferred path: bootstrap pip inside the venv via ensurepip.
    if "$PYTHON" -m ensurepip --version >/dev/null 2>&1; then
        echo "Bootstrapping pip with ensurepip ..."
        "$PYTHON" -m ensurepip --upgrade
    else
        echo "ensurepip is unavailable; installing system pip packages ..."
        ensure_apt_packages python3-pip python3-setuptools python3-wheel || return 1
    fi

    if ! "$PYTHON" -m pip --version >/dev/null 2>&1; then
        echo "pip is still unavailable in $VENV_DIR." >&2
        echo "Try recreating the venv: rm -rf .venv && ./Lights.sh --yes" >&2
        return 1
    fi
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

echo "=== Lights PI Show ==="
echo "Tip: Press O while running to print the background (nohup) launch command."
echo "     Press q or Ctrl+C to quit."
echo ""

if [ "$(id -u)" -ne 0 ]; then
    echo "Note: hardware LED access requires elevated privileges." >&2
    echo "  • Run with sudo:                sudo ./Lights.sh" >&2
    echo "  • Or grant capabilities once:   sudo bash setup_permissions.sh" >&2
    echo ""
fi

if ! command -v python3 >/dev/null 2>&1; then
    ensure_apt_packages python3 || exit 1
fi

if ! python3 -m venv -h >/dev/null 2>&1; then
    ensure_apt_packages python3-venv || exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -f "$VENV_DIR/bin/python3" ]; then
    echo "Creating virtual environment at $VENV_DIR ..."
    python3 -m venv --system-site-packages "$VENV_DIR"
fi

PYTHON="$VENV_DIR/bin/python3"

# Some distros create venvs without pip. Try ensurepip first, then apt fallback.
ensure_venv_pip

# Install / sync dependencies
if [ -f "$SCRIPT_DIR/requirements.txt" ]; then
    if prompt_yes_no "Install/upgrade Python dependencies from requirements.txt? [Y/n]" "Y"; then
        "$PYTHON" -m pip install -r "$SCRIPT_DIR/requirements.txt"
    fi
fi

# If arguments are provided, pass them directly to into.py.
# Otherwise, run interactively so the user is prompted for the headless option
# before the runtime shortcuts are displayed.
if [ "$#" -gt 0 ]; then
    exec "$PYTHON" into.py "$@"
else
    exec "$PYTHON" into.py
fi
