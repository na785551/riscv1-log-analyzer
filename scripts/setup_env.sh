#!/bin/bash

# Stop on errors, unset variables, and failed pipelines.
set -euo pipefail

echo "=== RISC-V Log Analyzer Environment Check ==="

TOOLS=("bash" "grep" "awk" "sed" "date" "git" "make")

missing=0

for tool in "${TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "[OK] $tool"
    else
        echo "[MISSING] $tool"
        missing=1
    fi
done

if [[ "$missing" -eq 0 ]]; then
    echo
    echo "All required tools are installed."
    exit 0
else
    echo
    echo "Some required tools are missing."
    exit 1
fi