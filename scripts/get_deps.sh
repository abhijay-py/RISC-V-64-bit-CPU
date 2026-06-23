#!/usr/bin/env bash
# Print the extra src/*.sv files a testbench instantiates, based on a
# "// DEPS: dep1 dep2 ..." comment in the first 10 lines of tb/<module>_tb.sv.
#
# Usage: get_deps.sh <module> [src_dir]
#   <module>   module name (e.g. alu)
#   [src_dir]  directory prepended to each dep (default: <repo_root>/rtl)
#
# rtl/<module>.sv and all .svh files are always included by the caller --
# this script only handles *extra* instantiated modules.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

MODULE="$1"
SRC_DIR="${2:-$ROOT_DIR/rtl}"

TB_FILE="$ROOT_DIR/tb/${MODULE}_tb.sv"

[ -f "$TB_FILE" ] || exit 0

head -n 10 "$TB_FILE" | awk -v src_dir="$SRC_DIR" '
    /^[ \t]*\/\/[ \t]*DEPS:/ {
        line = $0
        sub(/^[ \t]*\/\/[ \t]*DEPS:[ \t]*/, "", line)
        n = split(line, deps, /[ \t]+/)
        out = ""
        for (i = 1; i <= n; i++) {
            if (deps[i] != "") {
                out = out " " src_dir "/" deps[i] ".sv"
            }
        }
        print out
        exit
    }
'
