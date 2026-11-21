#!/bin/sh
# بناء كامل: node + ضبط مقاس الغلاف
set -e
cd "$(dirname "$0")/.."
OUT=$(node src/build.js)
echo "$OUT"
W=$(echo "$OUT" | python3 -c "import sys,json;print(json.load(sys.stdin)['coverWidthIn'])")
python3 src/fixbox.py output/cover.pdf "$W" 11.25 2>/dev/null
