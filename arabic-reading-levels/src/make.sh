#!/bin/sh
# بناء السلسلة كاملة: الكتب الثلاثة + الأغلفة + ضبط المقاسات
set -e
cd "$(dirname "$0")/.."
node src/level1.js && node src/level2.js && node src/level3.js && node src/cover.js
for i in 1 2 3; do
  python3 src/fixbox.py output/level$i-interior.pdf 210 297
  python3 src/fixbox.py output/level$i-cover.pdf 216 303
done
rm -f output/*.html
