#!/bin/sh
# Simple helper to decompress a file and compare with original
if [ $# -lt 2 ]; then
    echo "Usage: $0 <original.csv> <compressed>" >&2
    exit 1
fi
orig=$1
comp=$2
out=${comp}.restored.csv
if [ "$(uname -m)" = "aarch64" ]; then
    ./decompress "$comp" "$out"
else
    QEMU_PATH=${QEMU_PATH:-/usr/aarch64-linux-gnu}
    qemu-aarch64 -L "$QEMU_PATH" ./decompress "$comp" "$out"
fi
diff -q "$orig" "$out" && echo "Files match" || echo "Files differ"
