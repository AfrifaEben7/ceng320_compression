#!/bin/sh
# Simple helper to decompress a file and compare with original
if [ $# -lt 2 ]; then
    echo "Usage: $0 <original.csv> <compressed>" >&2
    exit 1
fi
orig=$1
comp=$2
out=${comp}.restored.csv
qemu-aarch64 -L /usr/aarch64-linux-gnu ./decompress "$comp" "$out"
diff -q "$orig" "$out" && echo "Files match" || echo "Files differ"
