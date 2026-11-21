# يضبط مقاس صفحات PDF بدقة بالمليمتر (المتصفح يقرّب لأقرب بكسل)
import sys, os, pymupdf as fitz
f, w, h = sys.argv[1], float(sys.argv[2]) * 72 / 25.4, float(sys.argv[3]) * 72 / 25.4
d = fitz.open(f)
for p in d: p.set_mediabox(fitz.Rect(0, 0, w, h))
d.save(f + '.tmp', garbage=3, deflate=True); d.close(); os.replace(f + '.tmp', f)
