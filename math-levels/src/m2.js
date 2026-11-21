// «أحسب بثقة» — المستوى الثاني: أجمع وأطرح حتى ١٠٠
// المرجع: دليل IES 2021 (تعليم صريح، تمثيلات، خطّ الأعداد، طلاقة موقوتة، مسائل لفظية بالأشرطة)،
// التدرّج المحسوس ← المصوّر ← المجرّد بقطع العشرات والآحاد، وخطّ الأعداد المفتوح، واستراتيجيات الحساب الذهنيّ
const path = require('path');
const { makeKit, M, MT, hd, shuffle, sec, pic } = require('./mcore');
const { eq, svg, tenFrame, dots, bond, numberLine, baseTen, hundredChart, openLine, pvChart, objects, scatter } = M;
const ROOT = path.resolve(__dirname, '..');
const LV = 2;
const GOALS = ['أفهم العدد عشراتٍ وآحاداً', 'أتنقّل في لوحة المئة وأكتشف أنماطها', 'أقارن الأعداد حتى ١٠٠ وأرتّبها', 'أعدّ بالقفز وأستعمل خطّ الأعداد حتى ١٠٠',
  'أجمع المضاعفات وما يقاربها بسرعة', 'أُكمل العشرة لأجمع حتى ٢٠', 'أطرح حتى ٢٠ بالتفكير في الجمع', 'أجمع العشرات وأطرحها، وأضيف ١٠ وأطرحها',
  'أجمع عددين من رقمين دون حمل', 'أجمع مع الحمل', 'أطرح عدداً من رقمين مع الاستلاف', 'أحلّ المسائل بالأشرطة وأفهم إشارة يساوي'];
const K = makeKit(LV, GOALS);
const { P, H, tagU, box, big, E, parent, grid, rows } = K;
const rnd = (() => { let s = 29; return (a, b) => { s = (s * 16807) % 2147483647; return a + (s % (b - a + 1)); }; })();

const bt = (t, o, w = 40, h = 30) => `<div style="width:${w}mm;height:${h}mm">${baseTen(t, o)}</div>`;
const TO = v => [Math.floor(v / 10), v % 10];
// عمليّة عموديّة: العشرات يساراً والآحاد يميناً، مع خانة للحمل أو الاستلاف
function colOp(a, b, op, { carry = false } = {}) {
  const d = v => [Math.floor(v / 10), v % 10];
  const [a1, a0] = d(a), [b1, b0] = d(b);
  const cell = (t, cls = '') => `<td style="width:13mm;height:12mm;font-size:24pt;font-weight:800;border:none;${cls}">${t}</td>`;
  const bx = '<span style="display:inline-block;width:10mm;height:10mm;border:.5mm solid #111;border-radius:2mm;background:#fff"></span>';
  return `<table dir="ltr" style="width:auto;margin:auto;border-collapse:collapse">
    <tr style="font-size:9pt;color:#475569">${cell('', '')}${cell('<span style="font-size:10pt;color:#1E40AF">عشرات</span>')}${cell('<span style="font-size:10pt;color:#C2410C">آحاد</span>')}</tr>
    ${carry ? `<tr>${cell('')}${cell('<span style="display:inline-block;width:7mm;height:7mm;border:.4mm dashed #94a3b8;border-radius:1.5mm"></span>')}${cell('')}</tr>` : ''}
    <tr>${cell('')}${cell(hd(a1), 'background:#DBEAFE')}${cell(hd(a0), 'background:#FFEDD5')}</tr>
    <tr style="border-bottom:.8mm solid #111">${cell(op)}${cell(hd(b1), 'background:#DBEAFE')}${cell(hd(b0), 'background:#FFEDD5')}</tr>
    <tr>${cell('')}${cell(bx)}${cell(bx)}</tr></table>`;
}
// ميزان إشارة يساوي
const balance = (left, right) => svg('0 0 300 150', `<path d="M150 40 L130 140 H170Z" fill="#94A3B8" stroke="#111" stroke-width="3"/><line x1="30" y1="40" x2="270" y2="40" stroke="#111" stroke-width="6"/>
  <path d="M30 40 L10 80 H90 L70 40" fill="none" stroke="#111" stroke-width="3"/><path d="M270 40 L290 80 H210 L230 40" fill="none" stroke="#111" stroke-width="3"/>
  <rect x="5" y="80" width="110" height="34" rx="8" fill="#FFE08A" stroke="#111" stroke-width="3"/><rect x="185" y="80" width="110" height="34" rx="8" fill="#CDEBFF" stroke="#111" stroke-width="3"/>
  <text x="240" y="105" text-anchor="middle" font-family="Cairo" font-weight="800" font-size="22" direction="rtl">${left}</text><text x="60" y="105" text-anchor="middle" font-family="Cairo" font-weight="800" font-size="22" direction="rtl">${right}</text>`);
const ex = (...p) => p.map(v => (typeof v === 'number' ? hd(v) : v)).join(' ');
const piece = c => {
  const v = [[c - 11, c - 10, c - 9], [c - 1, c, c + 1], [c + 9, c + 10, c + 11]];
  const s = 46;
  return svg(`0 0 ${3 * s + 4} ${3 * s + 4}`, v.flatMap((r, y) => r.map((n, x) => `<rect x="${2 + (2 - x) * s}" y="${2 + y * s}" width="${s}" height="${s}" fill="${n === c ? '#FDE68A' : '#fff'}" stroke="#475569" stroke-width="2"/>${n === c ? `<text x="${2 + (2 - x) * s + s / 2}" y="${2 + y * s + 31}" text-anchor="middle" font-family="Cairo" font-weight="800" font-size="22">${hd(n)}</text>` : ''}`)).join(''));
};

const UNITS = [
  { t: 'العشرات والآحاد', pages: u => [
    P(`${H('أحزمُ العشرات', tagU(u, 0))}
      <div class="sec" style="font-size:12.5pt;line-height:1.85"><b>هيّا نلعب:</b> نعدّ عيداناً، وكلّما جمعنا عشرة نربطها بمطّاطة فتصير «عشرة». ثمّ نعدّ: كم حزمة؟ وكم عوداً مفرداً؟</div>
      ${grid(2, [[3, 4], [5, 2], [2, 7], [6, 0], [4, 9], [7, 5]].map(([t, o]) => `${bt(t, o, 42, 30)}<span style="font-size:13pt;font-weight:700;line-height:2">${box(10, 9)} عشرات<br>${box(10, 9)} آحاد<br>العدد ${box(13, 9)}</span>`), 'fill')}`),
    P(`${H('أنظرُ إلى القطع وأكتبُ العدد', tagU(u, 1))}${grid(3, shuffle([[2, 3], [4, 0], [1, 8], [5, 5], [3, 9], [6, 1], [8, 4], [7, 7], [9, 2]], 3).map(([t, o]) => `${bt(t, o, 34, 26)}${box(15, 12)}`), 'fill')}`),
    P(`${H('أفكّكُ العدد', tagU(u, 2))}${sec(1, 'أكتبُ العشرات والآحاد', grid(2, [47, 63, 28, 90, 55, 31].map(v => `${big(hd(v), 26)}<span style="font-size:13pt;font-weight:700;display:flex;align-items:center;gap:1.5mm;white-space:nowrap">= ${box(10, 9)} عشرات و ${box(10, 9)} آحاد</span>`), 20))}
      ${sec(2, 'أكتبُ الصورة الموسّعة', grid(3, [36, 52, 74, 19, 88, 60].map(v => E(20, v, '=', '_', '+', '_')), 20))}
      ${sec(3, 'أكتبُ العدد', grid(3, [[4, 6], [7, 3], [9, 0], [2, 8], [5, 1], [6, 6]].map(([t, o]) => `<span style="font-size:13pt;font-weight:700">${hd(t)} عشرات و${hd(o)} آحاد = ${box(13, 10)}</span>`), 18), 'grow')}`),
    K.fluency('أقرأُ الأعداد بسرعة', tagU(u, 3), Array.from({ length: 36 }, () => big(hd(rnd(10, 99)), 26))),
    P(`${H('أرسمُ العدد بالقطع', tagU(u, 4))}<div style="font-size:12pt">أرسم خطّاً طويلاً لكلّ عشرة، ومربّعاً صغيراً لكلّ واحد.</div>${grid(2, [34, 52, 18, 41, 26, 63].map(v => `${big(hd(v), 30)}<div style="flex:1;height:90%;border:.4mm dashed #111;border-radius:2mm;background:#fff"></div>`), 'fill')}`),
    K.think(u, 'العشرات والآحاد', { w: [bt(3, 4, 30, 24), big(hd(34), 30), E(20, 30, '+', 4), big(hd(43), 30)], e: [24, 'star'], err: [bt(2, 5, 34, 26), 'قال سامي: هذا العدد ٥٢.'] }),
  ] },
  { t: 'لوحة المئة', pages: u => [
    P(`${H('لوحةُ المئة وأنماطها', tagU(u, 0))}<div style="font-size:12pt">ألوّن الأعداد التي آحادها ٥ بالأصفر، وأقرأ العمود: ماذا ألاحظ؟</div><div style="flex:1;min-height:0">${hundredChart()}</div>
      ${parent('العبوا «أنا أفكّر في عدد»: عدد بين ٤٠ و٥٠، آحاده ٧. ما هو؟')}`),
    P(`${H('أكملُ لوحة المئة', tagU(u, 1))}<div style="font-size:12pt">أكتب الأعداد الناقصة. هل لاحظت أنّ العدد تحت كلّ عدد يزيد ١٠؟</div><div style="flex:1;min-height:0">${hundredChart({ hide: shuffle(Array.from({ length: 100 }, (_, i) => i + 1), 7).slice(0, 34) })}</div>`),
    P(`${H('قطعٌ من لوحة المئة', tagU(u, 2))}<div style="font-size:12pt">أكتب الأعداد حول العدد الملوّن: يميني أقلّ بواحد، ويساري أكثر بواحد، وفوقي أقلّ بعشرة، وتحتي أكثر بعشرة.</div>${grid(3, [24, 57, 38, 72, 45, 86].map(c => `<div style="width:46mm;height:46mm">${piece(c)}</div>`), 'fill')}`),
    K.fluency('أعدُّ بالعشرات من أيّ عدد', tagU(u, 3), [3, 7, 12, 25, 1, 8, 16, 34, 5, 21, 9, 40].map(s => `<span style="font-size:18pt">${eq(s, '،', s + 10, '،', '_', '،', '_')}</span>`), 2, 'أقرأ العدد وأكمل بزيادة عشرة كلّ مرّة.'),
    P(`${H('أكثر وأقلّ', tagU(u, 4))}<table style="font-size:14pt"><thead><tr style="height:12mm"><th>العدد</th><th>أقلّ بعشرة</th><th>أقلّ بواحد</th><th>أكثر بواحد</th><th>أكثر بعشرة</th></tr></thead>
      <tbody>${[35, 62, 49, 80, 17, 91, 56, 23].map(v => `<tr style="height:21mm"><td style="font-weight:900;font-size:22pt">${hd(v)}</td><td></td><td></td><td></td><td></td></tr>`).join('')}</tbody></table>`),
    K.think(u, 'لوحة المئة', { w: [big(hd(25), 32), big(hd(35), 32), big(hd(45), 32), big(hd(54), 32)], e: [20, 'apple'], err: [E(28, 39, '،', 310), 'قال سامي: بعد ٣٩ يأتي ٣١٠.'] }),
  ] },
  { t: 'المقارنة والترتيب', pages: u => [
    P(`${H('أيُّهما أكبر؟ بالقطع', tagU(u, 0))}<div style="font-size:12pt">أقارن العشرات أوّلاً، فإن تساوت أقارن الآحاد. أضع دائرة حول الأكبر.</div>
      ${grid(2, [[[3, 6], [4, 1]], [[5, 2], [5, 8]], [[2, 9], [3, 0]], [[6, 4], [4, 6]], [[7, 1], [7, 1]], [[1, 8], [2, 2]]].flatMap(([a, b]) => [bt(...a, 34, 26), bt(...b, 34, 26)]), 'fill')}`),
    P(`${H('أقارنُ بجدول المنازل', tagU(u, 1))}${grid(2, [[46, 64], [72, 78], [39, 41], [55, 55], [80, 18], [63, 36]].map(([a, b]) => `<div style="flex:1">${pvChart(...TO(a))}</div><div style="flex:1">${pvChart(...TO(b))}</div>`), 'fill')}`),
    P(`${H('أكتبُ > أو < أو =', tagU(u, 2))}${grid(3, [[47, 52], [86, 68], [30, 30], [91, 19], [45, 54], [72, 70], [63, 63], [29, 92], [58, 85], [41, 14], [77, 71], [99, 100]].map(([a, b]) => E(22, a, '_', b)), 'fill')}`),
    P(`${H('أرتّبُ الأعداد', tagU(u, 3))}${sec(1, 'من الأصغر إلى الأكبر', rows([[45, 23, 67, 38], [81, 18, 59, 95], [36, 63, 33, 66]].map(s => `${s.map(v => big(hd(v), 22)).join('<span style="width:4mm"></span>')}<span style="flex:1"></span><span style="display:flex;gap:2mm">${s.map(() => box(13, 11)).join('')}</span>`), 24))}
      ${sec(2, 'من الأكبر إلى الأصغر', rows([[72, 27, 55, 90], [14, 41, 44, 11]].map(s => `${s.map(v => big(hd(v), 22)).join('<span style="width:4mm"></span>')}<span style="flex:1"></span><span style="display:flex;gap:2mm">${s.map(() => box(13, 11)).join('')}</span>`), 24), 'grow')}`),
    P(`${H('أكبرُ عدد وأصغرُ عدد', tagU(u, 4))}<div style="font-size:12pt">أكوّن من البطاقتين أكبر عدد وأصغر عدد.</div>${grid(2, [[3, 7], [5, 2], [8, 1], [6, 9], [4, 4], [2, 0]].map(([a, b]) => `<span style="display:flex;gap:2mm">${[a, b].map(d => `<span style="width:12mm;height:15mm;border:.6mm solid #1E3A8A;border-radius:2mm;background:#EAF1FF;display:inline-flex;align-items:center;justify-content:center;font-size:22pt;font-weight:900">${hd(d)}</span>`).join('')}</span><span style="font-size:12pt;font-weight:700;line-height:2.2">الأكبر ${box(13, 10)}<br>الأصغر ${box(13, 10)}</span>`), 'fill')}`),
    K.think(u, 'المقارنة', { w: [big(hd(68), 32), big(hd(86), 32), big(hd(66), 32), big(hd(60), 32)], e: [22, 'ball'], err: [E(30, 52, '>', 61), 'كتب سامي هذه المقارنة.'] }),
  ] },
  { t: 'العدّ بالقفز وخطّ الأعداد', pages: u => [
    P(`${H('أقفزُ بالعشرات', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.85"><b>هيّا نلعب:</b> نرسم على الأرض خطّاً بعلامة كلّ عشرة، ونقفز: عشرة، عشرون، ثلاثون… ثمّ نقفز بالخمسات.</div>
      ${sec(1, 'أعدُّ بالعشرات', numberLine(0, 100, { every: 10, jumps: [[0, 10], [10, 20], [20, 30], [30, 40], [40, 50], [50, 60]], h: 100 }))}
      ${sec(2, 'أعدُّ بالخمسات', numberLine(0, 50, { every: 5, jumps: [[0, 5], [5, 10], [10, 15], [15, 20], [20, 25]], h: 100 }))}
      ${sec(3, 'أعدُّ بالاثنين', numberLine(0, 20, { every: 2, jumps: [[0, 2], [2, 4], [4, 6], [6, 8], [8, 10]], h: 100 }), 'grow')}`),
    P(`${H('أكتبُ الأعداد الناقصة على الخطّ', tagU(u, 1))}<div style="display:flex;flex-direction:column;gap:4mm;flex:1;justify-content:space-between">${[[20, 50, 80], [10, 40, 70, 90], [30, 60, 100]].map(hide => `<div class="sec">${numberLine(0, 100, { every: 10, hide, h: 90 })}</div>`).join('')}${[[15, 30, 45], [10, 25, 40]].map(hide => `<div class="sec">${numberLine(0, 50, { every: 5, hide, h: 90 })}</div>`).join('')}</div>`),
    P(`${H('أكملُ العدّ بالقفز', tagU(u, 2))}${rows([[2, 2], [10, 10], [5, 5], [14, 2], [35, 5], [40, 10], [11, 10], [90, -10], [50, -5], [20, -2]].map(([s, d]) => `<span style="font-size:20pt;margin:auto">${eq(s, '،', s + d, '،', s + 2 * d, '،', '_', '،', '_', '،', '_')}</span>`))}`),
    K.fluency('أعدُّ بسرعة', tagU(u, 3), ['بالعشرات من ١٠ إلى ١٠٠', 'بالخمسات من ٥ إلى ٥٠', 'بالاثنين من ٢ إلى ٢٠', 'بالعشرات من ٧ إلى ٩٧', 'بالعشرات إلى الخلف من ١٠٠', 'بالخمسات إلى الخلف من ٥٠'].map(t => `<span style="font-size:15pt;font-weight:800">${t}</span>`), 2, 'يعدّ التلميذ بصوت مسموع، والمعلّم يسجّل الزمن.'),
    P(`${H('أين يقع العدد؟', tagU(u, 4))}<div style="font-size:12pt">أرسم سهماً في المكان التقريبيّ للعدد على الخطّ.</div><div style="display:flex;flex-direction:column;gap:3mm;flex:1;justify-content:space-between">${[50, 25, 90, 70, 15].map(v => `<div class="sec" style="display:flex;align-items:center;gap:3mm">${big(hd(v), 28)}<div style="flex:1">${numberLine(0, 100, { every: 100, h: 80 })}</div></div>`).join('')}</div>`),
    K.think(u, 'العدّ بالقفز', { w: [E(18, 10, '،', 20, '،', 30), E(18, 5, '،', 10, '،', 15), E(18, 2, '،', 4, '،', 6), E(18, 10, '،', 20, '،', 40)], e: [26, 'star'], err: [E(24, 5, '،', 10, '،', 15, '،', 25), 'عدّ سامي بالخمسات هكذا.'] }),
  ] },
  { t: 'المضاعفات وما يقاربها', pages: u => [
    P(`${H('المضاعفات', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.85"><b>هيّا نلعب:</b> نضع مرآة بجانب مجموعة أغطية: ما نراه في المرآة يساوي ما أمامها. ٣ + ٣ = ٦. المضاعف عددان متساويان.</div>
      ${grid(2, [3, 4, 5, 6, 7, 8].map(v => `<div style="width:24mm;height:24mm">${dots(Math.min(v, 6), 'dice', v)}</div><div style="width:24mm;height:24mm">${dots(Math.min(v, 6), 'dice', v)}</div>${E(18, v, '+', v, '=', '_')}`).slice(0, 4).concat([7, 8].map(v => `<div style="width:30mm;height:13mm">${tenFrame(v)}</div><div style="width:30mm;height:13mm">${tenFrame(v)}</div>${E(18, v, '+', v, '=', '_')}`)), 'fill')}`),
    P(`${H('ما يقارب المضاعف', tagU(u, 1))}<div style="font-size:12pt">٦ + ٧ قريب من ٦ + ٦. فأقول: ٦ + ٦ = ١٢، وواحد زيادة = ١٣.</div>
      ${grid(2, [[6, 7], [4, 5], [8, 9], [5, 6], [7, 8], [3, 4]].map(([a, b]) => `<span style="font-size:17pt;line-height:2.2">${eq(a, '+', b)}<br>${eq(a, '+', a, '+', 1, '=', '_')}</span>`), 'fill')}`),
    P(`${H('أجمعُ بالمضاعفات', tagU(u, 2))}${grid(3, [[4, 4], [9, 9], [6, 6], [5, 6], [8, 7], [7, 7], [9, 8], [3, 3], [6, 5], [10, 10], [4, 3], [8, 8], [7, 6], [2, 3], [9, 10]].map(([a, b]) => E(21, a, '+', b, '=', '_')), 'fill')}`),
    K.drill('تمرينُ دقيقة: المضاعفات وما يقاربها', tagU(u, 3), Array.from({ length: 27 }, () => { const a = rnd(1, 10); return [a, '+', a + rnd(0, 1)]; })),
    K.wordProblems('مسائل المضاعفات', tagU(u, 4), [['في يدي اليمنى ٥ حبّات تمر، وفي اليسرى ٥. كم حبّة معي؟', K.barPartWhole(5, 5, 10)], ['لعليّ ٧ سيّارات، ولأخيه مثلها. كم سيّارة معهما؟', K.barPartWhole(7, 7, 14)], ['قرأت مريم ٦ صفحات أمس، و٧ صفحات اليوم. كم صفحة قرأت؟', K.barPartWhole(6, 7, 13)], ['في صفّ ٨ مقاعد، وفي صفّ آخر ٩ مقاعد. كم مقعداً في الصفّين؟', K.barPartWhole(8, 9, 17)]]),
    K.think(u, 'المضاعفات', { w: [E(24, 6, '+', 6), E(24, 4, '+', 4), E(24, 5, '+', 6), E(24, 7, '+', 7)], e: [18, 'apple'], err: [E(28, 7, '+', 8, '=', 14), 'هذا حلّ سامي.'] }),
  ] },
  { t: 'أُكمل العشرة لأجمع', pages: u => [
    P(`${H('أُكمل العشرة', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.85"><b>هيّا نلعب:</b> عندي ٨ في إطار وأريد أن أجمع ٥. أنقل ٢ لأملأ الإطار، فيصير عندي ١٠ و٣ = ١٣.</div>
      ${grid(2, [[8, 5], [9, 4], [7, 6], [8, 6], [9, 7], [6, 5]].map(([a, b]) => `<div style="display:flex;flex-direction:column;gap:1mm;width:36mm"><div style="height:15mm">${tenFrame(a)}</div><div style="height:15mm">${tenFrame(b)}</div></div><span style="font-size:15pt;line-height:2.1">${eq(a, '+', b)}<br>${eq(10, '+', '_', '=', '_')}</span>`), 'fill')}`),
    P(`${H('أكملُ العشرة على خطّ الأعداد المفتوح', tagU(u, 1))}${sec(1, 'مثال', openLine([8, 10, 13], [[8, 10, '+٢'], [10, 13, '+٣']], { h: 120 }) + `<div style="text-align:center;font-size:18pt">${eq(8, '+', 5, '=', 8, '+', 2, '+', 3, '=', 13)}</div>`)}
      <div style="display:flex;flex-direction:column;gap:3mm;flex:1;justify-content:space-between">${[[9, 6], [7, 5], [8, 7], [6, 8]].map(([a, b]) => `<div class="sec" style="display:flex;align-items:center;gap:3mm">${E(20, a, '+', b, '=', '_')}<div style="flex:1">${openLine([a], [], { h: 80 })}</div></div>`).join('')}</div>`),
    P(`${H('أفكّكُ لأكمل العشرة', tagU(u, 2))}${grid(2, [[9, 4], [8, 5], [7, 6], [9, 8], [8, 4], [6, 7], [7, 9], [5, 8]].map(([a, b]) => E(17, a, '+', b, '=', a, '+', '_', '+', '_', '=', '_')), 'fill')}`),
    K.drill('تمرينُ دقيقة: الجمع حتى ٢٠', tagU(u, 3), Array.from({ length: 27 }, () => { const a = rnd(5, 9); return [a, '+', rnd(11 - a, 9)]; })),
    K.wordProblems('مسائل الجمع حتى ٢٠', tagU(u, 4), [['في الحافلة ٩ تلاميذ، وصعد ٥ آخرون. كم تلميذاً في الحافلة؟', K.barPartWhole(9, 5, 14, 'whole')], ['اشترت أمّي ٨ برتقالات و٧ تفّاحات. كم فاكهة اشترت؟', K.barPartWhole(8, 7, 15, 'whole')], ['في الحديقة ٦ ورود حمراء و٨ صفراء. كم وردة فيها؟', K.barPartWhole(6, 8, 14, 'whole')], ['سجّل فريقنا ٩ أهداف ثمّ ٩ أخرى. كم هدفاً سجّل؟', K.barPartWhole(9, 9, 18, 'whole')]]),
    K.think(u, 'أُكمل العشرة', { w: [E(22, 9, '+', 1), E(22, 8, '+', 2), E(22, 7, '+', 4), E(22, 6, '+', 4)], e: [20, 'ball'], err: [E(24, 8, '+', 5, '=', 10, '+', 5, '=', 15), 'هذا حلّ سامي.'] }),
  ] },
  { t: 'الطرح حتى ٢٠ وعائلات الحقائق', pages: u => [
    P(`${H('عائلةُ الحقائق', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.85"><b>هيّا نلعب:</b> ١٣ غطاءً: ٨ حمراء و٥ زرقاء. نكتب أربع جمل من العائلة نفسها: جمعتان وطرحتان.</div>
      ${grid(2, [[13, 8, 5], [15, 9, 6], [12, 7, 5], [16, 9, 7]].map(([w, a, b]) => `<div style="width:34mm;height:29mm">${bond(w, a, b)}</div><span style="font-size:15pt;line-height:1.9">${eq(a, '+', b, '=', '_')}<br>${eq(b, '+', a, '=', '_')}<br>${eq(w, '−', a, '=', '_')}<br>${eq(w, '−', b, '=', '_')}</span>`), 'fill')}`),
    P(`${H('أطرحُ بالتفكير في الجمع', tagU(u, 1))}<div style="font-size:12pt">١٤ − ٦ = ؟ أسأل نفسي: ٦ + كم = ١٤؟ وأعدّ إلى الأمام على الخطّ.</div>
      ${grid(2, [[14, 6], [13, 9], [15, 7], [12, 8], [17, 9], [11, 5], [16, 8], [18, 9]].map(([a, b]) => `<span style="font-size:17pt;line-height:2.2">${eq(a, '−', b, '=', '_')}<br>${eq(b, '+', '_', '=', a)}</span>`), 'fill')}`),
    P(`${H('أكتبُ عائلة الحقائق', tagU(u, 2))}${grid(2, [[11, 6, 5], [14, 9, 5], [17, 8, 9], [13, 7, 6], [15, 8, 7], [12, 9, 3]].map(([w, a, b]) => `<div style="width:38mm;height:32mm;flex:none">${bond(w, a, b)}</div><div style="flex:1;display:flex;flex-direction:column;gap:1.5mm">${['+', '+', '−', '−'].map(op => `<div style="display:flex;align-items:center;gap:1.5mm">${box(10, 8)}<b>${op}</b>${box(10, 8)}<b>=</b>${box(10, 8)}</div>`).join('')}</div>`), 'fill')}`),
    K.drill('تمرينُ دقيقة: الطرح حتى ٢٠', tagU(u, 3), Array.from({ length: 27 }, () => { const a = rnd(10, 18); return [a, '−', rnd(a - 9, 9)]; })),
    K.wordProblems('مسائل الطرح والمقارنة', tagU(u, 4), [['مع سلمى ١٥ ملصقاً، أعطت أختها ٦. كم بقي معها؟', K.barPartWhole(6, 9, 15, 'b')], ['في الصفّ ١٣ تلميذاً، خرج ٥ إلى الساحة. كم بقي في الصفّ؟', K.barPartWhole(5, 8, 13, 'b')], ['عمر أحمد ١٢ سنة، وعمر أخيه ٧ سنوات. كم سنة يكبره أحمد؟', K.barCompare(12, 7)], ['عند زينب ١٦ قلماً، وعند ليلى ٩. كم قلماً تزيد زينب؟', K.barCompare(16, 9)]]),
    K.think(u, 'عائلة الحقائق', { w: [E(20, 8, '+', 5, '=', 13), E(20, 13, '−', 5, '=', 8), E(20, 5, '+', 8, '=', 13), E(20, 13, '−', 4, '=', 9)], e: [17, 'lemon'], err: [E(26, 14, '−', 6, '=', 9), 'هذا حلّ سامي.'] }),
  ] },
  { t: 'جمع العشرات وطرحها', pages: u => [
    P(`${H('أجمعُ العشرات بالقطع', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.8"><b>هيّا نلعب:</b> ٣ حزم و٢ حزم = ٥ حزم، أي ٣٠ + ٢٠ = ٥٠. العشرات تُجمع مثل الآحاد!</div>
      ${grid(2, [[3, 2], [4, 4], [5, 3], [2, 6], [6, 1], [7, 2]].map(([a, b]) => `${bt(a, 0, 22, 26)}<b style="font-size:20pt">+</b>${bt(b, 0, 22, 26)}${E(15, a * 10, '+', b * 10, '=', '_')}`), 'fill')}`),
    P(`${H('أضيفُ عشرة وأطرحُ عشرة', tagU(u, 1))}<div style="font-size:12pt">أقفز عشرة على الخطّ المفتوح. ماذا يتغيّر في العدد؟ العشرات فقط!</div>
      ${rows([[23, 10], [47, 10], [35, -10], [68, -10], [51, 20], [74, -20]].map(([a, d]) => `${E(20, a, d > 0 ? '+' : '−', Math.abs(d), '=', '_')}<div style="flex:1">${openLine([a, a + d], [[a, a + d, (d > 0 ? '+' : '−') + hd(Math.abs(d))]], { h: 80 })}</div>`))}`),
    P(`${H('أحسبُ بالعشرات', tagU(u, 2))}${grid(3, [[30, '+', 40], [90, '−', 30], [47, '+', 10], [56, '−', 10], [20, '+', 70], [80, '−', 50], [63, '+', 20], [85, '−', 30], [10, '+', 90], [70, '−', 70], [38, '+', 30], [92, '−', 40], [50, '+', 50], [64, '−', 20], [29, '+', 60]].map(p => E(21, ...p, '=', '_')), 'fill')}`),
    K.drill('تمرينُ دقيقة: العشرات', tagU(u, 3), Array.from({ length: 27 }, (_, i) => { const a = rnd(1, 9) * 10 + (i % 3 ? rnd(0, 9) : 0); return i % 2 ? [a, '+', rnd(1, Math.floor((99 - a) / 10) || 1) * 10] : [a, '−', rnd(1, Math.floor(a / 10)) * 10]; })),
    P(`${H('جدولُ العشرات', tagU(u, 4))}<table style="font-size:14pt"><thead><tr style="height:12mm"><th>العدد</th><th>− ٢٠</th><th>− ١٠</th><th>+ ١٠</th><th>+ ٢٠</th></tr></thead>
      <tbody>${[45, 62, 37, 50, 28, 71, 54, 33].map(v => `<tr style="height:21mm"><td style="font-weight:900;font-size:22pt">${hd(v)}</td><td></td><td></td><td></td><td></td></tr>`).join('')}</tbody></table>`),
    K.think(u, 'العشرات', { w: [E(22, 30, '+', 20), E(22, 40, '+', 10), E(22, 25, '+', 25), E(22, 60, '−', 10)], e: [24, 'apple'], err: [E(26, 47, '+', 10, '=', 48), 'هذا حلّ سامي.'] }),
  ] },
  { t: 'الجمع دون حمل', pages: u => [
    P(`${H('أجمعُ بالقطع: العشرات مع العشرات', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.8"><b>هيّا نلعب:</b> ٢٣ + ١٤: نضع الحزم معاً (٣ حزم) والمفردات معاً (٧)، فالناتج ٣٧.</div>
      ${grid(2, [[23, 14], [32, 25], [41, 36], [15, 22], [52, 34], [26, 13]].map(([a, b]) => `${bt(...TO(a), 26, 26)}<b style="font-size:20pt">+</b>${bt(...TO(b), 26, 26)}${E(14, a, '+', b, '=', '_')}`), 'fill')}`),
    P(`${H('أجمعُ على الخطّ المفتوح', tagU(u, 1))}${sec(1, 'مثال: أضيف العشرات ثمّ الآحاد', openLine([23, 33, 37], [[23, 33, '+١٠'], [33, 37, '+٤']], { h: 120 }) + `<div style="text-align:center;font-size:18pt">${eq(23, '+', 14, '=', 37)}</div>`)}
      <div style="display:flex;flex-direction:column;gap:3mm;flex:1;justify-content:space-between">${[[45, 23], [31, 26], [52, 17], [64, 35]].map(([a, b]) => `<div class="sec" style="display:flex;align-items:center;gap:3mm">${E(20, a, '+', b, '=', '_')}<div style="flex:1">${openLine([a], [], { h: 80 })}</div></div>`).join('')}</div>`),
    P(`${H('أجمعُ عموديّاً', tagU(u, 2))}<div style="font-size:12pt">أجمع الآحاد أوّلاً ثمّ العشرات.</div>${grid(3, [[34, 25], [52, 16], [41, 37], [63, 24], [25, 42], [71, 18], [46, 33], [80, 19], [24, 54]].map(([a, b]) => colOp(a, b, '+')), 'fill')}`),
    K.drill('تمرينُ دقيقة: الجمع دون حمل', tagU(u, 3), Array.from({ length: 21 }, () => { const a1 = rnd(1, 6), a0 = rnd(0, 5), b1 = rnd(1, 9 - a1), b0 = rnd(0, 9 - a0); return [a1 * 10 + a0, '+', b1 * 10 + b0]; }), 19),
    K.wordProblems('مسائل الجمع', tagU(u, 4), [['في المكتبة ٣٤ قصّة و٢٥ مجلّة. كم كتاباً فيها؟', K.barPartWhole(34, 25, 59)], ['جمع حسن ٤٢ تمرة وجمع أخوه ٣٦. كم تمرة جمعا؟', K.barPartWhole(42, 36, 78)], ['في المدرسة ٥٣ بنتاً و٤٥ ولداً في الصفّ الثاني. كم تلميذاً؟', K.barPartWhole(53, 45, 98)], ['قطعت السيّارة ٢١ كيلومتراً ثمّ ٤٧. كم كيلومتراً قطعت؟', K.barPartWhole(21, 47, 68)]]),
    K.think(u, 'الجمع دون حمل', { w: [E(22, 23, '+', 14), E(22, 32, '+', 5), E(22, 15, '+', 22), E(22, 40, '+', 7)], e: [27, 'star'], err: [E(26, 34, '+', 25, '=', 95), 'هذا حلّ سامي.'] }),
  ] },
  { t: 'الجمع مع الحمل', pages: u => [
    P(`${H('عشرة آحاد = عشرة واحدة', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.8"><b>هيّا نلعب:</b> ٢٨ + ٧: صار عندي ١٥ عوداً مفرداً، فأربط ١٠ منها حزمة جديدة: ٣ حزم و٥ = ٣٥.</div>
      ${grid(2, [[28, 7], [36, 8], [19, 5], [47, 6], [25, 9], [58, 4]].map(([a, b]) => `${bt(...TO(a), 28, 26)}<b style="font-size:20pt">+</b>${bt(0, b, 12, 26)}${E(15, a, '+', b, '=', '_')}`), 'fill')}`),
    P(`${H('أكملُ العشرة التالية', tagU(u, 1))}${sec(1, 'مثال', openLine([28, 30, 35], [[28, 30, '+٢'], [30, 35, '+٥']], { h: 120 }) + `<div style="text-align:center;font-size:18pt">${eq(28, '+', 7, '=', 28, '+', 2, '+', 5, '=', 35)}</div>`)}
      <div style="display:flex;flex-direction:column;gap:3mm;flex:1;justify-content:space-between">${[[37, 6], [49, 5], [26, 8], [58, 7]].map(([a, b]) => `<div class="sec" style="display:flex;align-items:center;gap:3mm">${E(20, a, '+', b, '=', '_')}<div style="flex:1">${openLine([a], [], { h: 80 })}</div></div>`).join('')}</div>`),
    P(`${H('أجمعُ عموديّاً مع الحمل', tagU(u, 2))}<div style="font-size:12pt">إذا صار مجموع الآحاد ١٠ أو أكثر، أكتب الآحاد وأحمل العشرة في المربّع الصغير فوق العشرات.</div>${grid(3, [[38, 25], [47, 36], [29, 43], [56, 27], [18, 64], [35, 48], [67, 26], [49, 39], [28, 57]].map(([a, b]) => colOp(a, b, '+', { carry: true })), 'fill')}`),
    K.drill('تمرينُ دقيقة: الجمع مع الحمل', tagU(u, 3), Array.from({ length: 21 }, () => { const a0 = rnd(5, 9), b0 = rnd(10 - a0, 9), a1 = rnd(1, 5), b1 = rnd(1, 8 - a1); return [a1 * 10 + a0, '+', b1 * 10 + b0]; }), 19),
    K.wordProblems('مسائل الجمع مع الحمل', tagU(u, 4), [['في البستان ٣٨ نخلة، وزرع الفلّاح ٢٤ أخرى. كم نخلة صارت؟', K.barPartWhole(38, 24, 62)], ['في الصندوق ٤٦ قلماً أحمر و٢٧ أزرق. كم قلماً فيه؟', K.barPartWhole(46, 27, 73)], ['ادّخر عليّ ٥٩ ديناراً ثمّ ٢٥. كم ادّخر؟', K.barPartWhole(59, 25, 84)], ['في الحفل ٢٨ رجلاً و٤٨ امرأة. كم شخصاً حضر؟', K.barPartWhole(28, 48, 76)]]),
    K.think(u, 'الجمع مع الحمل', { w: [E(22, 28, '+', 7), E(22, 36, '+', 4), E(22, 45, '+', 9), E(22, 57, '+', 8)], e: [25, 'ball'], err: [E(26, 38, '+', 25, '=', 53), 'هذا حلّ سامي. ماذا نسي؟'] }),

  ] },
  { t: 'الطرح مع الاستلاف', pages: u => [
    P(`${H('أفكُّ حزمة', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.8"><b>هيّا نلعب:</b> ٤٢ − ١٧: لا أستطيع أن آخذ ٧ من ٢، فأفكّ حزمة فتصير ١٢ مفردة و٣ حزم. ١٢ − ٧ = ٥، و٣ − ١ = ٢، فالناتج ٢٥.</div>
      ${grid(2, [[42, 17], [35, 8], [51, 26], [64, 39], [43, 15], [70, 24]].map(([a, b]) => `${bt(...TO(a), 32, 26)}<span style="font-size:14pt;font-weight:800">أطرح ${hd(b)}</span>${E(14, a, '−', b, '=', '_')}`), 'fill')}`),
    P(`${H('أطرحُ على الخطّ المفتوح', tagU(u, 1))}${sec(1, 'مثال: أعدّ إلى الأمام من الأصغر إلى الأكبر', openLine([17, 20, 40, 42], [[17, 20, '+٣'], [20, 40, '+٢٠'], [40, 42, '+٢']], { h: 120 }) + `<div style="text-align:center;font-size:17pt">${eq(42, '−', 17)} ← ٣ + ٢٠ + ٢ = ${hd(25)}</div>`)}
      <div style="display:flex;flex-direction:column;gap:3mm;flex:1;justify-content:space-between">${[[53, 28], [61, 34], [45, 19], [72, 46]].map(([a, b]) => `<div class="sec" style="display:flex;align-items:center;gap:3mm">${E(20, a, '−', b, '=', '_')}<div style="flex:1">${openLine([b, a], [], { h: 80 })}</div></div>`).join('')}</div>`),
    P(`${H('أطرحُ عموديّاً مع الاستلاف', tagU(u, 2))}<div style="font-size:12pt">إذا كان رقم الآحاد في الأعلى أصغر، أستلف عشرة: أشطب العشرات وأنقصها واحداً، وأضيف ١٠ إلى الآحاد.</div>${grid(3, [[52, 27], [64, 38], [43, 19], [70, 45], [81, 36], [56, 29], [93, 47], [65, 28], [42, 15]].map(([a, b]) => colOp(a, b, '−', { carry: true })), 'fill')}`),
    K.drill('تمرينُ دقيقة: الطرح مع الاستلاف', tagU(u, 3), Array.from({ length: 21 }, () => { const a0 = rnd(0, 6), b0 = rnd(a0 + 1, 9), a1 = rnd(3, 9), b1 = rnd(1, a1 - 1); return [a1 * 10 + a0, '−', b1 * 10 + b0]; }), 19),
    K.wordProblems('مسائل الطرح', tagU(u, 4), [['في الصفّ ٥٢ كتاباً، وزّع المعلّم منها ٢٧. كم كتاباً بقي؟', K.barPartWhole(27, 25, 52, 'b')], ['في الصحن ٤٣ تمرة، أكلت الأسرة ١٨. كم تمرة بقيت؟', K.barPartWhole(18, 25, 43, 'b')], ['طول شجرة ٦٤ سنتيمتراً، وطول أخرى ٣٩. كم الفرق بينهما؟', K.barCompare(64, 39)], ['مع ليلى ٨١ ديناراً، ومع سارة ٤٦. كم تزيد ليلى؟', K.barCompare(81, 46)]]),
    K.think(u, 'الطرح مع الاستلاف', { w: [E(22, 42, '−', 17), E(22, 56, '−', 23), E(22, 70, '−', 25), E(22, 63, '−', 38)], e: [23, 'lemon'], err: [E(26, 52, '−', 27, '=', 35), 'هذا حلّ سامي.'] }),
  ] },
  { t: 'المسائل وإشارة يساوي', pages: u => [
    P(`${H('إشارةُ يساوي تعني: الطرفان متوازنان', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.8"><b>هيّا نلعب:</b> نصنع ميزاناً من مسطرة وقلم: نضع في الكفّتين أغطية حتى يتوازن. إشارة = تعني «يساوي في القيمة»، لا «الجواب يأتي بعدها».</div>
      ${grid(2, [['٥ + ٣', '__ + ٢'], ['٧ + ٢', '٤ + __'], ['١٠', '__ + ٦'], ['٦ + ٦', '__ + ٥'], ['٩ + ١', '٣ + __'], ['٨ + ٤', '__ + ٢']].map(([l, r]) => `<div style="width:62mm;height:30mm">${balance(l, r)}</div>`), 'fill')}`),
    P(`${H('صحيحٌ أم خطأ؟', tagU(u, 1))}<div style="font-size:12pt">أضع ✓ إذا كان الطرفان متساويين، و✗ إذا لم يكونا.</div>${grid(3, [[7, '=', 7], [8, '=', '٥ + ٣'], ['٤ + ٤', '=', '٥ + ٣'], ['٦ + ٢', '=', 9], [10, '=', '١٠ + ٠'], ['٩ − ٤', '=', '٣ + ٢'], ['٥ + ٥', '=', '٦ + ٣'], [12, '=', '٧ + ٥'], ['١٥ − ٥', '=', '٢٠ − ١٠']].map(p => `<span style="font-size:19pt">${eq(...p)}</span>${K.box(11, 11)}`), 'fill')}`),
    K.wordProblems('أين المجهول؟', tagU(u, 2), [['في السلّة ٢٥ برتقالة، وأضافت أمّي بعض البرتقالات فصار فيها ٤٠. كم برتقالة أضافت؟', K.barPartWhole(25, 15, 40, 'b')], ['اشترى أبي بعض الأقلام، ثمّ اشترى ١٢ فصار معه ٣٠. كم قلماً اشترى أوّلاً؟', K.barPartWhole(18, 12, 30, 'a')], ['في الحافلة ٤٥ راكباً، نزل بعضهم فبقي ٢٨. كم راكباً نزل؟', K.barPartWhole(17, 28, 45, 'a')], ['مع عليّ ٣٦ ملصقاً، ومع أخيه ١٤ أكثر منه. كم ملصقاً مع أخيه؟', K.barCompare(50, 36, 'big')]]),
    K.wordProblems('مسائلُ المقارنة', tagU(u, 3), [['طول نبتة ٤٨ سنتيمتراً، وطول نبتة أخرى ٣٢. كم سنتيمتراً تزيد الأولى؟', K.barCompare(48, 32)], ['في صفّ مريم ٢٧ تلميذة، وفي صفّ زينب ٣٤. كم تلميذة تزيد صفّ زينب؟', K.barCompare(34, 27)], ['قفز حسن ٦٥ سنتيمتراً، وقفز أحمد أقلّ منه بـ ١٨. كم قفز أحمد؟', K.barCompare(65, 47, 'small')], ['مع سارة ٥٣ خرزة، وهي أكثر من خرز ليلى بـ ٢٦. كم خرزة مع ليلى؟', K.barCompare(53, 27, 'small')]]),
    K.wordProblems('مسائلُ من خطوتين', tagU(u, 4), [['في الحافلة ٣٠ راكباً، نزل ١٢ ثمّ صعد ٩. كم راكباً صار فيها؟', K.barPartWhole(18, 9, 27)], ['مع ليلى ٤٥ ديناراً، اشترت كتاباً بـ ٢٠ وقلماً بـ ٥. كم بقي معها؟', K.barPartWhole(20, 25, 45, 'a')], ['قطف الفلّاح ٢٤ رمّانة صباحاً و٣٢ مساءً، ثمّ باع ٤٠. كم بقي؟', K.barPartWhole(16, 40, 56, 'a')], ['في المكتبة ٦٠ قصّة، استعار التلاميذ ٢٥ ثمّ أعادوا ١٠. كم قصّة فيها الآن؟', K.barPartWhole(35, 10, 45)]]),
    K.think(u, 'إشارة يساوي', { w: [E(20, '٤ + ٣', '=', 7), E(20, 7, '=', '٤ + ٣'), E(20, '٤ + ٣', '=', '٥ + ٢'), E(20, '٤ + ٣', '=', '٥ + ٣')], e: [21, 'star'], err: [E(24, '٥ + ٣', '=', '٨ + ٢', '=', 10), 'كتب سامي هكذا.'] }),
  ] },
];

function review(k, title) {
  const makers = [
    () => `${bt(rnd(1, 9), rnd(0, 9), 26, 22)}${box()}`,
    () => E(18, rnd(10, 99), '_', rnd(10, 99)),
    () => { const a = rnd(2, 9); return E(18, a, '+', rnd(10 - a, 9), '=', '_'); },
    () => { const a = rnd(11, 18); return E(18, a, '−', rnd(a - 9, 9), '=', '_'); },
    () => { const a = rnd(1, 8) * 10 + rnd(0, 9); return E(18, a, '+', 10, '=', '_'); },
    () => { const a1 = rnd(1, 5), b1 = rnd(1, 3), a0 = rnd(0, 9), b0 = rnd(0, 9); return E(17, a1 * 10 + a0, '+', b1 * 10 + b0, '=', '_'); },
    () => { const a1 = rnd(5, 9), b1 = rnd(1, a1 - 1), a0 = rnd(0, 9), b0 = rnd(0, 9); return E(17, a1 * 10 + a0, '−', b1 * 10 + b0, '=', '_'); },
  ].slice(0, 3 + k);
  return P(`${H(`مراجعة: ${title}`, `مراجعة ${hd(k)}`)}
  ${grid(3, Array.from({ length: 15 }, (_, i) => makers[i % makers.length]()), 'fill')}
  ${sec(1, 'أكتبُ الأعداد التي يُمليها المعلّم', `<div class="row">${Array.from({ length: 8 }, () => '<div class="cell" style="height:16mm"></div>').join('')}</div>`)}
  <div class="sec" style="display:flex;justify-content:space-around;font-size:13pt;font-weight:700;padding:2.5mm"><span>الصحيح: ..... من ${hd(23)}</span><span>أتقنتُ؟ نعم ☐ لا ☐</span><span>توقيع المعلّم: .........</span></div>`);
}

// لوّن حسب الناتج: رسوم بكسليّة، كلّ مربّع مسألة
const PIC = [
  ['قلب', ['..11..11..', '.12211221.', '1222222221', '1222222221', '.12222221.', '..122221..', '...1221...', '....11....'], [['١٠', 'أسود'], ['١٢', 'أحمر'], ['غيره', 'أبيض']], (c, i) => c === 1 ? ['٦ + ٤', '٣ + ٧', '٨ + ٢', '٥ + ٥'][i % 4] : c === 2 ? ['٦ + ٦', '٩ + ٣', '٨ + ٤', '٧ + ٥'][i % 4] : ['٤ + ٤', '٩ + ٢', '٧ + ٦', '٥ + ٦'][i % 4]],
  ['سمكة', ['..........', '..1111...1', '.122221.11', '1232222211', '1222222211', '.122221.11', '..1111...1', '..........'], [['١٤', 'أسود'], ['٢٠', 'برتقاليّ'], ['٣٠', 'أبيض'], ['غيره', 'أزرق']], (c, i) => c === 1 ? ['٧ + ٧', '٩ + ٥', '٨ + ٦'][i % 3] : c === 2 ? ['١٠ + ١٠', '١٥ + ٥', '١٢ + ٨'][i % 3] : c === 3 ? ['١٥ + ١٥', '٢٠ + ١٠'][i % 2] : ['٢٢ + ٣', '٣١ + ٤', '٤٣ + ٥'][i % 3]],
  ['شجرة', ['...1111...', '..122221..', '.12222221.', '.12222221.', '..122221..', '....33....', '....33....', '..111111..'], [['١٥', 'أسود'], ['٢٥', 'أخضر'], ['٤٠', 'بنّي'], ['غيره', 'أبيض']], (c, i) => c === 1 ? ['٣٥ − ٢٠', '٢٥ − ١٠', '٤٥ − ٣٠'][i % 3] : c === 2 ? ['٣٥ − ١٠', '٤٠ − ١٥', '٥٢ − ٢٧'][i % 3] : c === 3 ? ['٦٠ − ٢٠', '٥٥ − ١٥'][i % 2] : ['٩٠ − ٢٠', '٧٨ − ٤٠', '٦٦ − ١١'][i % 3]],
  ['بيت', ['....11....', '...1221...', '..122221..', '.12222221.', '1111111111', '1333333331', '1344334431', '1344334431'], [['٥٠', 'أسود'], ['٧٠', 'أحمر'], ['٩٠', 'أصفر'], ['٣٣', 'أزرق'], ['غيره', 'أبيض']], (c, i) => c === 1 ? ['٢٥ + ٢٥', '٣٧ + ١٣', '٤٢ + ٨'][i % 3] : c === 2 ? ['٣٥ + ٣٥', '٤٨ + ٢٢', '٥٦ + ١٤'][i % 3] : c === 3 ? ['٤٥ + ٤٥', '٦٣ + ٢٧', '٥٥ + ٣٥'][i % 3] : c === 4 ? ['١٨ + ١٥', '٢٤ + ٩', '١٦ + ١٧'][i % 3] : ['٢ + ٢', '٣ + ٣'][i % 2]],
];

function diag(title, tag) {
  return [P(`${H(title, tag)}
    ${sec(1, 'أكتبُ العدد', grid(4, [[3, 5], [6, 0], [2, 8], [7, 4]].map(([t, o]) => `${bt(t, o, 26, 22)}${box()}`), 28))}
    ${sec(2, 'أكتبُ > أو < أو =', grid(4, [[47, 74], [60, 59], [38, 38], [91, 19]].map(([a, b]) => E(18, a, '_', b)), 18))}
    ${sec(3, 'أكملُ العدّ', grid(2, [[10, 10], [45, 5]].map(([s, d]) => E(18, s, '،', s + d, '،', s + 2 * d, '،', '_', '،', '_')), 18))}
    ${sec(4, 'حقائق الجمع والطرح', grid(4, [[6, '+', 6], [8, '+', 5], [9, '+', 7], [7, '+', 8], [13, '−', 6], [15, '−', 9], [12, '−', 5], [17, '−', 8]].map(p => E(18, ...p, '=', '_')), 17), 'grow')}`),
  P(`${H(title, tag)}
    ${sec(5, 'أجمعُ وأطرحُ', grid(3, [[34, 25], [47, 38], [56, 27]].map(([a, b], i) => colOp(a, b, i === 2 ? '−' : '+', { carry: i > 0 })), 86))}
    ${sec(6, 'عشرة أكثر وعشرة أقلّ', grid(4, [[45, '+', 10], [72, '−', 10], [30, '+', 40], [90, '−', 50]].map(p => E(18, ...p, '=', '_')), 17))}
    ${sec(7, 'مسألة', `<div style="font-size:13pt;font-weight:700;line-height:2">في الحديقة ${hd(36)} شجرة، وزرع العمّال ${hd(27)} أخرى. كم شجرة صار فيها؟ ${box(16, 11)}</div>`, 'grow')}
    <div class="sec" style="display:flex;justify-content:space-around;font-size:13pt;font-weight:700;padding:2.5mm"><span>المجموع: ..... من ${hd(30)}</span><span>التاريخ: ..../..../........</span></div>`)];
}

function gameBoard() {
  return P(`${H('لعبة السباق إلى ١٠٠', 'لعبة')}
  <div class="sec" style="font-size:12pt;line-height:1.8"><b>طريقة اللعب:</b> يرمي كلّ لاعب حجر النرد ويتقدّم بعدده وهو يعدّ بصوت عالٍ. إذا وقف على مربّع ملوّن يقفز عشرة (إلى المربّع الذي تحته). من يصل إلى ١٠٠ أوّلاً يفوز!</div>
  <div style="flex:1;min-height:0">${hundredChart({ shade: [7, 15, 23, 38, 44, 52, 61, 69, 77, 86] })}</div>`);
}

async function build(out) {
  K.reset();
  const pages = [K.title('المستوى الثاني', 'أجمع وأطرح<br>حتى ١٠٠', `<div style="display:flex;gap:4mm;height:100%"><div style="flex:0 0 40mm">${baseTen(3, 4)}</div><div style="flex:1">${openLine([28, 30, 35], [[28, 30, '+٢'], [30, 35, '+٥']], { h: 130 })}</div></div>`),
    ...K.parentPages('الجمع والطرح حتى ١٠٠: العشرات والآحاد، ولوحة المئة، وحقائق الجمع والطرح، والجمع والطرح مع الحمل والاستلاف، والمسائل', ['العدّ بالعشرات أثناء صعود الدرج.', 'لعبة «عشرة أكثر»: تقولون عدداً ويضيف الطفل ١٠.', 'حساب ثمن مشتريات بسيطة بالدينار.', 'أكمل العشرة: «٧ وكم تصير ١٠؟»'], ['حقائق دقيقة', 'ركن الأهل', 'مسألة من البيت', 'لعبة أعداد']),
    K.guide('يعالج هذا المستوى فجوتين شائعتين جدّاً: <b>القيمة المنزليّة</b> (الخلط بين العشرات والآحاد) و<b>العدّ على الأصابع</b> في الجمع والطرح. المرجع: دليل IES لمساعدة المتعثّرين في الرياضيات (٢٠٢١)، واستراتيجيات الحساب الذهنيّ (أكمل العشرة، المضاعفات، التفكير في الجمع)، وخطّ الأعداد المفتوح، ونموذج الأشرطة للمسائل.',
      [['ابدأ بالتشخيص', 'إن أخطأ التلميذ في الحقائق حتى ٢٠ فابدأ بالوحدات ٥–٧ قبل الأعداد الكبيرة.'], ['ستّ مراحل لكلّ وحدة', 'محسوس ← مصوّر ← مجرّد ← طلاقة ← تطبيق ← تحدّي التفكير.'], ['القطع قبل الأرقام', 'لا تعلّم الجمع العموديّ قبل أن يجمع التلميذ بالحزم والعيدان ويفهم «الحمل».'], ['خطّ الأعداد المفتوح', 'أداة للحساب الذهنيّ: القفز بالعشرات ثمّ الآحاد، أو إكمال العشرة.'], ['دقيقة طلاقة', 'هدفها حفظ الحقائق مع الفهم. نقارن التلميذ بنفسه فقط.'], ['المسائل بالأشرطة', 'يرسم التلميذ الشريط ليرى أين المجهول قبل أن يختار العمليّة.']],
      'عيدان (أعواد مثلّجات) ومطّاط لعمل الحزم، أغطية قناني، حجر نرد، وطباشير لرسم خطّ الأعداد على الأرض.'),
    ...K.numberTalks([E(26, 9, '+', 6), E(26, 8, '+', 7), E(26, 15, '−', 8), E(24, 29, '+', 9), E(24, 40, '−', 18), E(24, 25, '+', 26), `<div style="width:40mm;height:30mm">${baseTen(4, 7)}</div>`, E(24, 99, '+', 1), E(24, 50, '−', 1)]),
    ...diag('الاختبار التشخيصي', 'قبل البدء'), K.tracker(UNITS.map(u => u.t)),
    K.adventureMap(['العشرات والآحاد', 'لوحة المئة', 'المقارنة', 'العدّ بالقفز', 'المضاعفات', 'أكمل العشرة', 'عائلة الحقائق', 'العشرات', 'جمع دون حمل', 'جمع مع حمل', 'طرح مع استلاف', 'المسائل'])];
  const RV = { 2: 'الوحدات ١–٣', 5: 'الوحدات ١–٦', 8: 'الوحدات ١–٩', 11: 'الوحدات ١–١٢' };
  UNITS.forEach((u, i) => {
    pages.push(...u.pages(i + 1));
    if (RV[i]) { const k = Object.keys(RV).indexOf(String(i)) + 1; pages.push(review(k, RV[i]), K.colorByAnswer(...PIC[k - 1])); }
  });
  pages.push(gameBoard(), ...diag('الاختبار البعدي', 'نهاية المستوى'));
  let pad = 0;
  const MIX = [['تمرينٌ شامل: الجمع', () => { const a = rnd(10, 60); return [a, '+', rnd(5, 99 - a)]; }], ['تمرينٌ شامل: الطرح', () => { const a = rnd(30, 99); return [a, '−', rnd(5, a - 5)]; }], ['تمرينٌ شامل: الحقائق', () => { const a = rnd(5, 9); return rnd(0, 1) ? [a, '+', rnd(4, 9)] : [a + 9, '−', rnd(4, 9)]; }]];
  while ((pages.length + 1) % 4) { const [t, f] = MIX[pad++ % 3]; pages.push(K.drill(t, 'طلاقة', Array.from({ length: 21 }, f), 19)); }
  pages.push(K.certificate('المستوى الثاني', 'لإتقانه الجمع والطرح حتى ١٠٠', `<div style="display:flex;gap:6mm;height:100%;justify-content:center"><div style="width:40mm">${baseTen(5, 3)}</div><div style="width:60mm">${hundredChart({ rows: 3, shade: [12, 23] })}</div></div>`));
  await K.render(pages, out);
  return pages.length;
}
module.exports = { build };
if (require.main === module) build(path.join(ROOT, 'output/math2-interior.pdf')).then(c => console.log('pages', c));
