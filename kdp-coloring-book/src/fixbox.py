# يضبط مقاس صفحة الغلاف بدقة (المتصفح يقرّب المقاس لأقرب بكسل)
import sys, pymupdf as fitz
f, w, h = sys.argv[1], float(sys.argv[2]) * 72, float(sys.argv[3]) * 72
d = fitz.open(f)
for p in d:
    p.set_mediabox(fitz.Rect(0, 0, w, h))
d.save(f + '.tmp', garbage=3, deflate=True); d.close()
import os; os.replace(f + '.tmp', f)
