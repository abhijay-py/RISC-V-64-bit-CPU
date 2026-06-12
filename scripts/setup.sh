#!/usr/bin/env bash
# Fresh-install bootstrap for this repo's Verilator-based build.
#
# Installs everything needed for:
#   make [verilator] sim|coverage|wave <module>
#
# Usage: ./scripts/setup.sh

set -euo pipefail

REQUIRED_PKGS=(verilator gtkwave lcov build-essential)

if ! command -v apt-get >/dev/null 2>&1; then
    echo "error: this script only supports apt-based distros (Debian/Ubuntu)." >&2
    echo "Install manually and ensure these are on PATH: ${REQUIRED_PKGS[*]}" >&2
    exit 1
fi

echo "Installing: ${REQUIRED_PKGS[*]}"
sudo apt-get update
sudo apt-get install -y "${REQUIRED_PKGS[@]}"

echo
echo "Versions:"
verilator --version
gtkwave --version 2>&1 | head -1
genhtml --version 2>&1 | head -1

VLT_MAJOR="$(verilator --version | grep -oP '(?<=Verilator )\d+')"
if [ "$VLT_MAJOR" -lt 5 ]; then
    echo
    echo "warning: apt installed Verilator ${VLT_MAJOR}.x, but this project requires 5.0+."
    echo "         Build a newer Verilator from source: https://verilator.org/guide/latest/install.html"
fi

echo
echo "Note: SIMULATOR=XSIM (Vivado) is not installed by this script -- it"
echo "requires a manual Vivado install (multi-GB, license-gated). Source"
echo "Vivado's settings64.sh so xvlog/xelab/xsim are on PATH if you need it."
echo
echo "Setup complete. Try: make help"
