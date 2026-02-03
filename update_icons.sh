#!/bin/bash
cd "$(dirname "$0")"
OUT="SimplyLFO/Assets.xcassets/AppIcon.appiconset"

for size in 16 32 64 128 256 512 1024; do
    rsvg-convert -w $size -h $size AppIcon.svg -o "$OUT/icon_$size.png"
done

echo "Icons updated"
