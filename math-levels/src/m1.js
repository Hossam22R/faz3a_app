// «أحسب بثقة» — المستوى الأول: أفهم العدد (٠–٢٠)
// المرجع: دليل IES 2021 لمساعدة المتعثّرين في الرياضيات (تعليم صريح منظّم، تمثيلات بصرية وخط الأعداد،
// أنشطة طلاقة موقوتة، مسائل لفظية، مراجعة تراكمية) + التدرّج من المحسوس إلى المصوّر إلى المجرّد
const path = require('path');
const R = '../../arabic-reading-levels/src/';
const { hd, shuffle, page, header, sec, renderPDF, inkSVG } = require(R + 'common');
const { pic } = require(R + 'pics');
const X = require(R + 'extra');
const { WORDS, dots, tenFrame, doubleFrame, numberLine, bond, objects, eq, svg, scatter, face } = require('./mlib');
const ROOT = path.resolve(__dirname, '..');
const LV = 1;
let n = 0;
const P = inner => page(inner, { n: ++n, level: LV, series: 'سلسلة أحسب بثقة' });
const H = (t, tag) => header(t, tag, LV);
const box = (w = 13, h = 12) => `<span style="display:inline-block;width:${w}mm;height:${h}mm;border:.5mm solid #111;border-radius:2mm;flex:none"></span>`;
const big = (t, pt = 26) => `<span style="font-weight:800;font-size:${pt}pt;line-height:1">${t}</span>`;
const stage = (k) => ['محسوس', 'مصوّر', 'مجرّد', 'طلاقة', 'تطبيق'][k];
const tagU = (u, k) => `الوحدة ${hd(u)} · ${stage(k)}`;
const parent = t => `<div class="parent"><b>ركن الأهل:</b><span>${t}</span></div>`;
const timer = () => `<div class="row" style="font-size:11pt;font-weight:700">${[1, 2, 3].map(k => `<div class="cell" style="height:11mm">المحاولة ${hd(k)}: ..... صحيحة في دقيقة</div>`).join('')}</div>`;
const grid = (cols, items, h, gap = 2.6) => h === 'fill'
  ? `<div style="display:grid;grid-template-columns:repeat(${cols},minmax(0,1fr));grid-auto-rows:1fr;gap:${gap}mm;flex:1;min-height:0">${items.map(it => `<div class="cell" style="padding:1.5mm;gap:2mm;min-height:0;min-width:0;overflow:hidden">${it}</div>`).join('')}</div>`
  : `<div style="display:grid;grid-template-columns:repeat(${cols},minmax(0,1fr));gap:${gap}mm">${items.map(it => `<div class="cell" style="height:${h}mm;padding:1.5mm;gap:2mm">${it}</div>`).join('')}</div>`;
const rnd = (() => { let s = 17; return (a, b) => { s = (s * 16807) % 2147483647; return a + (s % (b - a + 1)); }; })();

// ---------- صفحات عامة ----------
function digitPage(d, u, k) {
  const ob = ['apple', 'star', 'ball', 'lemon', 'carrot', 'banana'][d % 6];
  return P(`${H(`العدد ${hd(d)} : ${WORDS[d]}`, tagU(u, k))}
  <div class="row" style="height:64mm">
    <div class="cell" style="flex:0 0 52mm;padding:4mm">${d === 0 ? svg('0 0 100 100', '<path d="M50 22 L72 50 L50 78 L28 50Z" fill="#fff" stroke="#111" stroke-width="4" stroke-linejoin="round"/>') : inkSVG(hd(d), { stroke: 5, pad: 0.05 }).replace('font-family="Naskh"', 'font-family="Cairo" font-weight="800"')}</div>
    <div class="cell" style="flex-direction:column;padding:3mm;gap:2mm"><div style="width:100%;height:24mm">${tenFrame(d)}</div><div style="width:100%;height:26mm;overflow:hidden">${d ? objects(d, ob, d <= 5 ? 5 : 10) : '<span style="font-size:12pt">صحنٌ فارغ: لا شيء</span>'}</div></div>
  </div>
  ${sec(1, `أكتبُ العدد ${hd(d)}`, `<div class="row">${[0, 1, 2, 3, 4, 5].map(i => `<div class="cell" style="height:25mm">${i < 3 ? big(hd(d), 40).replace('font-weight:800', 'font-weight:800;color:#bbb') : ''}</div>`).join('')}</div>`)}
  ${sec(2, d ? `ألوّنُ ${WORDS[d]} ${d > 2 && d < 11 ? 'من الأشياء' : ''}` : 'لا ألوّنُ شيئاً: صفر', `<div style="height:30mm">${objects(10, ob, 10)}</div>`)}
  ${sec(3, `أضعُ دائرةً حولَ ${hd(d)} على خطّ الأعداد`, numberLine(0, 10, { h: 96 }), 'grow')}
  ${parent(`ابحثوا مع طفلكم عن ${WORDS[d]} أشياء في البيت، وعدّوها معاً بالإشارة إلى كلّ شيء مرّة واحدة.`)}`);
}

function fluencyPage(title, tag, items, cols = 6, h = 20) {
  return P(`${H(title, tag)}
  <div style="font-size:11.5pt">يقرأ التلميذ بأسرع ما يستطيع لمدّة دقيقة واحدة، والمعلّم يعدّ الإجابات الصحيحة.</div>
  ${grid(cols, items, 'fill', 2.2)}
  ${timer()}`);
}

function drill(title, tag, list) {
  return P(`${H(title, tag)}
  <div style="font-size:11.5pt">⏱ دقيقة واحدة: أحلّ أكبر عدد من المسائل. ثمّ أصحّح مع المعلّم وأحاول أن أتحسّن.</div>
  <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:2.2mm 4mm;flex:1;align-content:start">${list.map(([a, op, b]) => `<div class="cell" style="height:16mm;font-size:22pt;justify-content:center">${eq(a, op, b, '=', '_')}</div>`).join('')}</div>
  ${timer()}`);
}

function barModel(a, b, whole) {
  const W = 300, wa = (W * b) / whole; [a, b] = [b, a]; // الجزء الأوّل على اليمين
  const lab = v => (v === null ? '?' : hd(v));
  return svg('0 0 320 110', `<rect x="10" y="10" width="${W}" height="34" rx="4" fill="#fff" stroke="#111" stroke-width="3"/><text x="${10 + W / 2}" y="35" text-anchor="middle" font-family="Cairo" font-weight="800" font-size="24">${lab(null)}</text>
  <rect x="10" y="56" width="${wa}" height="34" rx="4" fill="#fff" stroke="#111" stroke-width="3"/><rect x="${10 + wa}" y="56" width="${W - wa}" height="34" rx="4" fill="#fff" stroke="#111" stroke-width="3"/>
  <text x="${10 + wa / 2}" y="81" text-anchor="middle" font-family="Cairo" font-weight="800" font-size="24">${hd(a)}</text><text x="${10 + wa + (W - wa) / 2}" y="81" text-anchor="middle" font-family="Cairo" font-weight="800" font-size="24">${hd(b)}</text>`);
}
function barSub(whole, part) {
  const W = 300, wq = ((whole - part) / whole) * W; // الجزء المعلوم على اليمين
  return svg('0 0 320 110', `<rect x="10" y="10" width="${W}" height="34" rx="4" fill="#fff" stroke="#111" stroke-width="3"/><text x="${10 + W / 2}" y="35" text-anchor="middle" font-family="Cairo" font-weight="800" font-size="24">${hd(whole)}</text>
  <rect x="10" y="56" width="${wq}" height="34" rx="4" fill="#fff" stroke="#111" stroke-width="3"/><rect x="${10 + wq}" y="56" width="${W - wq}" height="34" rx="4" fill="#fff" stroke="#111" stroke-width="3"/>
  <text x="${10 + wq / 2}" y="81" text-anchor="middle" font-family="Cairo" font-weight="800" font-size="24">?</text><text x="${10 + wq + (W - wq) / 2}" y="81" text-anchor="middle" font-family="Cairo" font-weight="800" font-size="24">${hd(part)}</text>`);
}
function wordProblems(title, tag, probs, sub) {
  return P(`${H(title, tag)}
  <div style="font-size:11.5pt">أقرأ المسألة (أو يقرؤها المعلّم)، وأنظر إلى الشريط، ثمّ أكتب الجملة العدديّة والجواب.</div>
  ${probs.map(([t, a, b], i) => `<div class="sec" style="display:flex;gap:4mm;align-items:center;padding:3mm 4mm">
    <div style="flex:1.3;font-size:13.5pt;font-weight:700;line-height:1.8"><b>${hd(i + 1)}.</b> ${t}</div>
    <div style="flex:1;height:30mm">${sub ? barSub(a, b) : barModel(a, b, a + b)}</div>
    <div style="display:flex;flex-direction:column;align-items:center;gap:2mm;font-size:11pt;font-weight:700">الجملة العدديّة<span style="width:36mm;height:11mm;border:.5mm solid #111;border-radius:2mm"></span>الجواب ${box(16, 11)}</div></div>`).join('')}
  ${parent('حوّلوا مواقف البيت إلى مسائل: «عندنا ٤ صحون، ونحتاج ٢ أخريين. كم صحناً نحتاج؟»')}`);
}

// ---------- الوحدات ----------
const UNITS = [
  { t: 'أرى الكمية دون عدّ', pages: u => [
    P(`${H('أرى الكمية دون عدّ (١–٥)', tagU(u, 0))}
      <div class="sec" style="font-size:12.5pt;line-height:1.85"><b>هيّا نلعب:</b> يُظهر المعلّم البطاقة ثانيتين ثمّ يُخفيها، ويقول التلميذ العدد دون أن يعدّ. ثمّ نلعب بحبوب أو أغطية قناني على الطاولة.</div>
      ${grid(3, [1, 2, 3, 4, 5, 3, 4, 2, 5].map((v, i) => `<div style="width:40mm;height:40mm">${dots(v, i < 5 ? 'dice' : 'rand', i)}</div>`), 'fill')}
      ${parent('ارموا حجر النرد مع طفلكم، واطلبوا منه أن يقول العدد بنظرة سريعة.')}`),
    P(`${H('أنظرُ بسرعة وأكتبُ العدد', tagU(u, 1))}
      ${grid(3, shuffle([1, 2, 3, 4, 5, 2, 3, 4, 5, 1, 3, 4], 3).map((v, i) => `<div style="width:34mm;height:34mm">${dots(v, i % 2 ? 'rand' : 'dice', i + 5)}</div>${box(15, 14)}`), 'fill')}`),
    P(`${H('أصلُ النقاط بالعدد', tagU(u, 2))}
      ${sec(1, 'أصلُ بخطّ', `<div style="display:grid;grid-template-columns:34mm 1fr 30mm;row-gap:4mm">${(() => { const a = shuffle([1, 2, 3, 4, 5], 4), b = shuffle([1, 2, 3, 4, 5], 9); return a.map((v, i) => `<div style="height:30mm;width:30mm">${dots(v, 'rand', i + 2)}</div><div style="display:flex;justify-content:space-between;align-items:center;padding:0 3mm"><b>●</b><b>●</b></div><div class="cell" style="height:30mm">${big(hd(b[i]), 36)}</div>`).join(''); })()}</div>`, 'grow')}`),
    fluencyPage('أقولُ العدد بسرعة', tagU(u, 3), Array.from({ length: 30 }, (_, i) => `<div style="width:22mm;height:22mm">${dots(rnd(1, 5), i % 3 ? 'rand' : 'dice', i + 30)}</div>`), 6, 30),
    P(`${H('ألوّنُ العددَ المطلوب', tagU(u, 4))}
      <div style="display:flex;flex-direction:column;gap:3mm;flex:1">${[3, 1, 5, 2, 4, 3].map((v, i) => `<div class="cell" style="flex:1;gap:4mm;padding:0 4mm">${big(hd(v), 34)}<div style="flex:1;height:20mm">${objects(6, ['star', 'apple', 'ball'][i % 3], 6)}</div></div>`).join('')}</div>`),
  ] },
  { t: 'أعدّ الأشياء حتى ١٠', pages: u => [
    P(`${H('أعدُّ في صفّي', tagU(u, 0))}
      <div class="sec" style="font-size:12.5pt;line-height:1.85"><b>قواعد العدّ:</b> ١) أشير إلى كلّ شيء مرّة واحدة. ٢) أقول عدداً واحداً لكلّ شيء. ٣) آخر عدد أقوله هو عدد الأشياء كلّها.</div>
      <table style="font-size:13pt"><thead><tr style="height:11mm;background:#eee"><th>ماذا أعدّ؟</th><th>أرسم خطّاً لكلّ واحد</th><th style="width:28mm">العدد</th></tr></thead>
      <tbody>${['الأبواب', 'النوافذ', 'المصابيح', 'السبّورات', 'أقلامي', 'دفاتري', 'أصابع يدي', 'أصدقائي على المقعد'].map(t => `<tr style="height:19mm"><td style="font-weight:700">${t}</td><td></td><td></td></tr>`).join('')}</tbody></table>`),
    P(`${H('أعدُّ وأكتبُ العدد', tagU(u, 1))}
      <div style="display:flex;flex-direction:column;gap:3mm;flex:1">${[4, 7, 3, 9, 6, 10, 8].map((v, i) => `<div class="cell" style="flex:1;gap:4mm;padding:0 4mm"><div style="flex:1;height:17mm">${objects(v, ['apple', 'star', 'ball', 'lemon', 'carrot', 'banana', 'drum'][i], 10)}</div>${box(16, 13)}</div>`).join('')}</div>`),
    P(`${H('ألوّنُ العددَ المطلوب', tagU(u, 2))}
      <div style="display:flex;flex-direction:column;gap:3mm;flex:1">${[6, 9, 4, 8, 7, 10, 5].map((v, i) => `<div class="cell" style="flex:1;gap:4mm;padding:0 4mm">${big(hd(v), 30)}<div style="flex:1;height:17mm">${objects(10, ['star', 'ball', 'apple'][i % 3], 10)}</div></div>`).join('')}</div>`),
    fluencyPage('أقرأُ إطار العشرة بسرعة', tagU(u, 3), Array.from({ length: 20 }, () => `<div style="width:38mm;height:17mm">${tenFrame(rnd(0, 10))}</div>`), 4, 30),
    P(`${H('أرسمُ دوائرَ بعدد الرقم', tagU(u, 4))}
      ${grid(2, [5, 8, 3, 10, 6, 9, 4, 7].map(v => `${big(hd(v), 34)}<div style="flex:1;height:90%;border:.4mm dashed #111;border-radius:2mm"></div>`), 'fill')}`),
  ] },
  { t: 'الأعداد من ١ إلى ٥', pages: u => [1, 2, 3, 4, 5].map((d, k) => digitPage(d, u, k)) },
  { t: 'الأعداد من ٦ إلى ١٠', pages: u => [6, 7, 8, 9, 10].map((d, k) => digitPage(d, u, k)) },
  { t: 'الصفر وإطار العشرة', pages: u => [
    digitPage(0, u, 0),
    P(`${H('أقرأُ إطار العشرة وأكتبُ العدد', tagU(u, 1))}${grid(3, shuffle([2, 5, 7, 10, 0, 4, 9, 6, 3, 8, 1, 5], 2).map(v => `<div style="width:50mm;height:21mm">${tenFrame(v)}</div>${box(15, 14)}`), 'fill')}`),
    P(`${H('أرسمُ النقاط في إطار العشرة', tagU(u, 2))}${grid(2, [3, 7, 5, 9, 2, 6, 8, 10].map(v => `${big(hd(v), 32)}<div style="width:62mm;height:27mm">${tenFrame(0)}</div>`), 'fill')}`),
    P(`${H('كم ينقصُ ليمتلئَ الإطار؟', tagU(u, 3))}<div style="font-size:12pt">أرسم الدوائر الناقصة، ثمّ أكتب عددها.</div>${grid(2, [6, 3, 8, 5, 9, 4, 7, 2].map(v => `<div style="width:62mm;height:27mm">${tenFrame(v)}</div>${box(15, 14)}`), 'fill')}`),
    fluencyPage('أقرأُ إطار العشرة بسرعة', tagU(u, 4), Array.from({ length: 20 }, () => `<div style="width:38mm;height:17mm">${tenFrame(rnd(0, 10))}</div>`), 4, 30),
  ] },
  { t: 'خطّ الأعداد', pages: u => [
    P(`${H('أتعرّفُ خطَّ الأعداد', tagU(u, 0))}
      <div class="sec" style="font-size:12.5pt;line-height:1.85"><b>هيّا نلعب:</b> نرسم خطّ الأعداد على أرض الصفّ بالطباشير، ويمشي التلميذ عليه وهو يعدّ: إلى الأمام (يزيد العدد) وإلى الخلف (ينقص العدد).</div>
      ${sec(1, 'أقرأُ الأعدادَ من اليمين إلى اليسار', numberLine(0, 10, { h: 90 }))}
      ${sec(2, 'أعدُّ إلى الأمام', numberLine(0, 10, { jumps: [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5]], h: 90 }))}
      ${sec(3, 'أعدُّ إلى الخلف', numberLine(0, 10, { jumps: [[10, 9], [9, 8], [8, 7], [7, 6]], h: 90 }), 'grow')}
      ${parent('العبوا لعبة «الدرج»: كلّ درجة عدد، صعوداً نعدّ إلى الأمام ونزولاً إلى الخلف.')}`),
    P(`${H('أكتبُ الأعدادَ الناقصة', tagU(u, 1))}<div style="display:flex;flex-direction:column;gap:4mm;flex:1;justify-content:space-between">${[[2, 5, 8], [1, 4, 9], [3, 6, 10], [0, 7, 5], [2, 4, 6, 8], [1, 3, 9]].map(hide => `<div class="sec">${numberLine(0, 10, { hide, h: 78 })}</div>`).join('')}</div>`),
    P(`${H('قبلُ وبعدُ وبين', tagU(u, 2))}
      ${sec(1, 'العدد الذي قبل', grid(4, [4, 7, 2, 9].map(v => eq('_', v)), 18))}
      ${sec(2, 'العدد الذي بعد', grid(4, [3, 6, 8, 1].map(v => eq(v, '_')), 18))}
      ${sec(3, 'العدد الذي بين', grid(4, [[4, 6], [7, 9], [1, 3], [5, 7]].map(([a, b]) => eq(a, '_', b)), 18), 'grow')}`),
    P(`${H('الضفدعُ يقفزُ على خطّ الأعداد', tagU(u, 3))}<div style="font-size:12pt">أرسم القفزات وأكتب المكان الذي يصل إليه الضفدع.</div>
      <div style="display:flex;flex-direction:column;gap:3mm;flex:1;justify-content:space-between">${[[2, 3], [5, 2], [1, 4], [6, 3], [4, 4]].map(([a, k]) => `<div class="sec" style="display:flex;align-items:center;gap:3mm"><div style="flex:0 0 60mm;font-size:12.5pt;font-weight:700">يقف على ${hd(a)} ويقفز ${hd(k)} إلى الأمام. يصل إلى ${box(13, 11)}</div><div style="flex:1">${numberLine(0, 10, { h: 64 })}</div></div>`).join('')}</div>`),
    P(`${H('أكملُ العدّ', tagU(u, 4))}<div style="display:flex;flex-direction:column;gap:3mm;flex:1">${[[2, 1], [5, 1], [10, -1], [7, -1], [0, 2], [10, -2], [1, 2], [3, 1]].map(([s, d]) => `<div class="cell" style="flex:1;font-size:22pt;gap:3mm;justify-content:center">${eq(...[s, '،', s + d, '،', s + 2 * d, '،', '_', '،', '_'])}</div>`).join('')}</div>`),
  ] },
  { t: 'المقارنة', pages: u => [
    P(`${H('أيُّهما أكثر؟', tagU(u, 0))}<div style="font-size:12pt">أعدّ، ثمّ أضع دائرة حول المجموعة الأكثر.</div>
      <div style="display:flex;flex-direction:column;gap:3mm;flex:1">${[[3, 5], [7, 4], [2, 6], [8, 9], [5, 1]].map(([a, b], i) => `<div class="row" style="flex:1"><div class="cell" style="padding:2mm">${objects(a, ['apple', 'star', 'ball', 'lemon', 'banana'][i], 5)}</div><div class="cell" style="padding:2mm">${objects(b, ['apple', 'star', 'ball', 'lemon', 'banana'][i], 5)}</div></div>`).join('')}</div>`),
    P(`${H('أقارنُ إطارات العشرة', tagU(u, 1))}<div style="font-size:12pt">أضع دائرة حول الأقلّ.</div>${grid(2, [[4, 7], [9, 6], [3, 3], [5, 8], [10, 2], [6, 7]].map(([a, b]) => `<div style="width:40mm;height:18mm">${tenFrame(a)}</div><div style="width:40mm;height:18mm">${tenFrame(b)}</div>`), 'fill')}`),
    P(`${H('أكبرُ وأصغرُ ويساوي', tagU(u, 2))}${sec(1, 'أضعُ دائرةً حولَ العدد الأكبر', grid(5, [[3, 8], [9, 4], [6, 7], [10, 5], [2, 1]].map(([a, b]) => `${big(hd(a), 28)}${big(hd(b), 28)}`), 22))}
      ${sec(2, 'أضعُ دائرةً حولَ العدد الأصغر', grid(5, [[5, 9], [8, 2], [4, 6], [7, 3], [1, 10]].map(([a, b]) => `${big(hd(a), 28)}${big(hd(b), 28)}`), 22))}
      <div class="sec" style="font-size:13pt;line-height:2"><b>تذكّر:</b> ${eq(7, '>', 3)} نقرؤها: سبعة أكبر من ثلاثة. ${eq(2, '<', 5)} نقرؤها: اثنان أصغر من خمسة. ${eq(4, '=', 4)} يساوي.<br>فمُ التمساح يأكل العدد الأكبر دائماً 🐊</div>
      ${sec(3, 'أكتبُ > أو < أو =', grid(4, [[6, 2], [3, 9], [5, 5], [8, 10], [1, 4], [7, 7], [10, 3], [2, 6]].map(([a, b]) => eq(a, '_', b)), 18), 'grow')}`),
    P(`${H('أرتّبُ الأعداد', tagU(u, 3))}${sec(1, 'من الأصغر إلى الأكبر', `<div style="display:flex;flex-direction:column;gap:3mm">${[[5, 2, 8, 4], [9, 1, 6, 3], [7, 10, 2, 5]].map(s => `<div class="cell" style="height:22mm;gap:5mm">${s.map(v => big(hd(v), 24)).join('<span style="width:5mm"></span>')}<span style="width:8mm"></span><span style="display:flex;gap:2mm">${s.map(() => box(12, 11)).join('')}</span></div>`).join('')}</div>`)}
      ${sec(2, 'من الأكبر إلى الأصغر', `<div style="display:flex;flex-direction:column;gap:3mm">${[[3, 9, 6, 1], [4, 8, 2, 10]].map(s => `<div class="cell" style="height:22mm;gap:5mm">${s.map(v => big(hd(v), 24)).join('<span style="width:5mm"></span>')}<span style="width:8mm"></span><span style="display:flex;gap:2mm">${s.map(() => box(12, 11)).join('')}</span></div>`).join('')}</div>`, 'grow')}`),
    fluencyPage('أيُّهما أكبر؟ أقولُ بسرعة', tagU(u, 4), Array.from({ length: 28 }, () => { const a = rnd(0, 10); let b = rnd(0, 10); if (b === a) b = (a + 3) % 11; return `${big(hd(a), 24)}<span style="font-size:12pt">أم</span>${big(hd(b), 24)}`; }), 4, 25),
  ] },
  { t: 'تركيب العدد وتحليله', pages: u => [
    P(`${H('أُكوّنُ العدد ٥ و٦ بطرق مختلفة', tagU(u, 0))}
      <div class="sec" style="font-size:12.5pt;line-height:1.85"><b>هيّا نلعب «هزّ واسكب»:</b> نضع ${hd(5)} أغطية في كوب ونسكبها: كم غطاءً على وجهه وكم على ظهره؟ نلوّن الدوائر ونكتب الجزأين.</div>
      ${grid(2, [[5, 2], [5, 4], [5, 0], [6, 3], [6, 1], [6, 5]].map(([w, a]) => `<div style="flex:1;height:14mm">${svg(`0 0 ${w * 30} 30`, Array.from({ length: w }, (_, i) => `<circle cx="${w * 30 - 15 - i * 30}" cy="15" r="12" fill="${i < a ? '#111' : '#fff'}" stroke="#111" stroke-width="2.5"/>`).join(''))}</div><span style="font-size:18pt">${eq('_', '+', '_', '=', w)}</span>`), 'fill')}`),
    P(`${H('بيتُ العدد: أكملُ الجزء الناقص', tagU(u, 1))}${grid(4, [[6, 2, null], [6, null, 4], [7, 3, null], [7, null, 5], [7, 1, null], [6, null, 0], [7, 6, null], [6, 3, null]].map(([w, a, b]) => `<div style="width:42mm;height:36mm">${bond(w, a, b)}</div>`), 'fill')}`),
    P(`${H('بيتُ العدد: ٨ و٩ و١٠', tagU(u, 2))}${grid(4, [[8, 5, null], [8, null, 2], [9, 4, null], [9, null, 7], [10, 6, null], [10, null, 3], [10, 8, null], [9, 9, null]].map(([w, a, b]) => `<div style="width:42mm;height:36mm">${bond(w, a, b)}</div>`), 'fill')}`),
    P(`${H('جدولُ بيتِ العدد', tagU(u, 3))}<div style="font-size:12pt">أكتب كلّ الطرق لتكوين العدد.</div>
      <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:3mm;flex:1">${[7, 8, 9, 10].map(w => `<div style="border:.6mm solid #111;border-radius:3mm;display:flex;flex-direction:column"><div style="text-align:center;font-weight:900;font-size:24pt;border-bottom:.6mm solid #111;background:#eee;border-radius:3mm 3mm 0 0">${hd(w)}</div>${Array.from({ length: w + 1 }, (_, a) => `<div style="flex:1;display:flex;align-items:center;justify-content:center;border-bottom:.3mm solid #999;font-size:15pt">${eq(a, '+', '_')}</div>`).join('')}</div>`).join('')}</div>`),
    fluencyPage('أكملُ بيت العدد بسرعة', tagU(u, 4), Array.from({ length: 16 }, () => { const w = rnd(4, 10), a = rnd(0, w); return `<div style="width:28mm;height:24mm">${bond(w, a, null)}</div>`; }), 4, 30),
  ] },
  { t: 'أصدقاء العشرة', pages: u => [
    P(`${H('أصدقاءُ العشرة', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.85">عددان «صديقان» إذا كان مجموعهما عشرة. نملأ إطار العشرة ونرى: كم عندي؟ وكم ينقص؟</div>
      ${grid(2, [7, 4, 9, 2, 6, 3, 8, 5].map(v => `<div style="width:48mm;height:21mm;flex:none">${tenFrame(v)}</div><span style="font-size:18pt">${eq(v, '+', '_', '=', 10)}</span>`), 'fill')}`),
    P(`${H('أصلُ كلَّ عدد بصديقه', tagU(u, 1))}${sec(1, 'مجموعُهما عشرة', `<div style="display:grid;grid-template-columns:30mm 1fr 30mm;row-gap:3.5mm">${(() => { const a = [1, 3, 5, 6, 8, 9], b = shuffle(a.map(v => 10 - v), 5); return a.map((v, i) => `<div class="cell" style="height:24mm">${big(hd(v), 32)}</div><div style="display:flex;justify-content:space-between;align-items:center;padding:0 3mm"><b>●</b><b>●</b></div><div class="cell" style="height:24mm">${big(hd(b[i]), 32)}</div>`).join(''); })()}</div>`, 'grow')}`),
    P(`${H('أكملُ لأحصلَ على عشرة', tagU(u, 2))}${grid(3, [4, 7, 1, 9, 3, 6, 8, 2, 5, 0, 10, 7, 6, 3, 9].map(v => `<span style="font-size:24pt">${eq(v, '+', '_', '=', 10)}</span>`), 'fill')}`),
    drill('تمرينُ دقيقة: أصدقاء العشرة', tagU(u, 3), Array.from({ length: 27 }, () => { const a = rnd(0, 10); return [a, '+', 10 - a]; })),
    P(`${H('ألوّنُ أصدقاء العشرة', tagU(u, 4))}<div style="font-size:12pt">ألوّن كلّ بطاقة مجموعها عشرة بلون واحد، وأترك الباقي.</div>
      ${grid(4, shuffle([[3, 7], [4, 6], [5, 5], [2, 8], [1, 9], [6, 4], [3, 5], [2, 6], [7, 2], [8, 2], [9, 1], [4, 4], [6, 3], [10, 0], [5, 3], [7, 3]], 6).map(([a, b]) => `<span style="font-size:26pt">${eq(a, 'و', b)}</span>`), 'fill')}`),
  ] },
  { t: 'الأعداد من ١١ إلى ٢٠', pages: u => [
    P(`${H('عشرةٌ وآحاد', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.85">نجمع ${hd(10)} عيدان ونربطها حزمة واحدة، ثمّ نضع بجانبها عيداناً مفردة: حزمة و${hd(3)} = ${hd(13)}.</div>
      ${grid(2, [13, 16, 11, 18, 15, 20].map(v => `<div style="width:40mm;height:38mm;flex:none">${doubleFrame(v)}</div><span style="font-size:14pt;font-weight:700;white-space:nowrap;display:flex;align-items:center;gap:1.5mm">عشرة و ${box(10, 9)} = ${box(12, 9)}</span>`), 'fill')}`),
    P(`${H('أقرأُ وأكتبُ الأعداد ١١–٢٠', tagU(u, 1))}<table style="font-size:14pt"><thead><tr style="height:10mm;background:#eee"><th>العدد</th><th>اسمه</th><th>أكتبه فوق الرماديّ</th><th>أكتبه وحدي</th></tr></thead>
      <tbody>${Array.from({ length: 10 }, (_, i) => i + 11).map(v => `<tr style="height:21mm"><td style="font-weight:900;font-size:22pt">${hd(v)}</td><td style="font-weight:700">${WORDS[v]}</td><td style="color:#bbb;font-size:24pt;font-weight:800">${hd(v)}  ${hd(v)}</td><td></td></tr>`).join('')}</tbody></table>`),
    P(`${H('خطُّ الأعداد من ١٠ إلى ٢٠', tagU(u, 2))}<div style="display:flex;flex-direction:column;gap:4mm;flex:1;justify-content:space-between">${[[12, 15, 18], [11, 14, 19], [13, 16, 20], [10, 17, 15], [12, 14, 16, 18]].map(hide => `<div class="sec">${numberLine(10, 20, { hide, h: 78 })}</div>`).join('')}</div>`),
    P(`${H('أقارنُ وأرتّبُ', tagU(u, 3))}${sec(1, 'أكتبُ > أو < أو =', grid(4, [[14, 11], [12, 19], [16, 16], [20, 13], [15, 18], [17, 12], [11, 11], [19, 20]].map(([a, b]) => eq(a, '_', b)), 18))}
      ${sec(2, 'أرتّبُ من الأصغر إلى الأكبر', `<div style="display:flex;flex-direction:column;gap:3mm">${[[15, 12, 19, 11], [18, 14, 20, 16]].map(s => `<div class="cell" style="height:22mm;gap:5mm">${s.map(v => big(hd(v), 24)).join('<span style="width:5mm"></span>')}<span style="width:8mm"></span><span style="display:flex;gap:2mm">${s.map(() => box(13, 11)).join('')}</span></div>`).join('')}</div>`, 'grow')}`),
    fluencyPage('أقرأُ الأعداد ٠–٢٠ بسرعة', tagU(u, 4), Array.from({ length: 36 }, () => big(hd(rnd(0, 20)), 28)), 6, 25),
  ] },
  { t: 'الجمع حتى ١٠', pages: u => [
    P(`${H('أجمعُ: أضمُّ المجموعتين', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.8">الجمع يعني أن نضمّ مجموعتين معاً ونعدّ الكلّ. نجرّب بالحبوب أوّلاً ثمّ بالصور.</div>
      <div style="display:flex;flex-direction:column;gap:2.6mm;flex:1">${[[3, 2], [4, 4], [5, 3], [2, 6], [6, 1], [5, 5]].map(([a, b], i) => `<div class="cell" style="flex:1;gap:3mm;padding:0 3mm"><div style="flex:${a};height:14mm">${objects(a, ['apple', 'star', 'ball'][i % 3], a)}</div><b style="font-size:22pt">+</b><div style="flex:${b};height:14mm">${objects(b, ['apple', 'star', 'ball'][i % 3], b)}</div><span style="font-size:20pt">${eq(a, '+', b, '=', '_')}</span></div>`).join('')}</div>`),
    P(`${H('أجمعُ على خطّ الأعداد', tagU(u, 1))}<div style="font-size:12pt">أبدأ من العدد الأوّل، وأقفز إلى الأمام بعدد الثاني.</div>
      <div style="display:flex;flex-direction:column;gap:3mm;flex:1;justify-content:space-between">${[[3, 4], [5, 2], [1, 6], [6, 3], [2, 5], [4, 4]].map(([a, b]) => `<div class="sec" style="display:flex;align-items:center;gap:3mm"><span style="font-size:20pt;flex:none">${eq(a, '+', b, '=', '_')}</span><div style="flex:1">${numberLine(0, 10, { h: 74 })}</div></div>`).join('')}</div>`),
    P(`${H('أجمعُ بإطار العشرة', tagU(u, 2))}<div style="font-size:12pt">ألوّن العدد الأوّل بلون، والثاني بلون آخر، ثمّ أعدّ الكلّ.</div>${grid(2, [[4, 3], [6, 2], [5, 4], [3, 7], [2, 2], [7, 1], [8, 2], [1, 5]].map(([a, b]) => `<div style="width:46mm;height:20mm;flex:none">${tenFrame(0)}</div><span style="font-size:19pt">${eq(a, '+', b, '=', '_')}</span>`), 'fill')}`),
    wordProblems('مسائل الجمع', tagU(u, 3), [['عند سلمى ٣ تفّاحات، وأعطتها أمّها ٢ أخريين. كم تفّاحة عندها الآن؟', 3, 2], ['في الحديقة ٤ عصافير، وجاءت ٣ عصافير أخرى. كم عصفوراً في الحديقة؟', 4, 3], ['مع عليّ ٥ أقلام، ومع أخيه ٤ أقلام. كم قلماً معهما معاً؟', 5, 4], ['قرأ حسن قصّتين يوم السبت، و٥ قصص يوم الأحد. كم قصّة قرأ؟', 2, 5]]),
    drill('تمرينُ دقيقة: الجمع حتى ١٠', tagU(u, 4), Array.from({ length: 27 }, () => { const a = rnd(0, 9); return [a, '+', rnd(0, 10 - a)]; })),
  ] },
  { t: 'الطرح حتى ١٠', pages: u => [
    P(`${H('أطرحُ: آخذُ من المجموعة', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.8">الطرح يعني أن نأخذ من المجموعة ونعدّ ما بقي. أشطب ما أُخذ بخطّ، ثمّ أعدّ الباقي.</div>
      <div style="display:flex;flex-direction:column;gap:2.6mm;flex:1">${[[5, 2], [7, 3], [6, 1], [9, 4], [8, 5], [10, 6]].map(([a, b], i) => `<div class="cell" style="flex:1;gap:3mm;padding:0 3mm"><div style="flex:1;height:14mm">${objects(a, ['apple', 'star', 'ball'][i % 3], 10)}</div><span style="font-size:13pt;font-weight:700;flex:none">أشطب ${hd(b)}</span><span style="font-size:20pt;flex:none">${eq(a, '−', b, '=', '_')}</span></div>`).join('')}</div>`),
    P(`${H('أطرحُ على خطّ الأعداد', tagU(u, 1))}<div style="font-size:12pt">أبدأ من العدد الأوّل، وأقفز إلى الخلف بعدد الثاني.</div>
      <div style="display:flex;flex-direction:column;gap:3mm;flex:1;justify-content:space-between">${[[7, 3], [9, 4], [6, 2], [10, 5], [8, 6], [5, 3]].map(([a, b]) => `<div class="sec" style="display:flex;align-items:center;gap:3mm"><span style="font-size:20pt;flex:none">${eq(a, '−', b, '=', '_')}</span><div style="flex:1">${numberLine(0, 10, { h: 74 })}</div></div>`).join('')}</div>`),
    P(`${H('الجزء الناقص', tagU(u, 2))}<div style="font-size:12pt">أستعين ببيت العدد: الكلّ ناقص جزء = الجزء الآخر.</div>${grid(4, [[8, 3], [10, 4], [7, 5], [9, 2]].map(([w, a]) => `<div style="width:36mm;height:30mm">${bond(w, a, null)}</div>`), 36)}
      ${grid(3, [[9, 3], [6, 4], [10, 7], [8, 8], [7, 0], [5, 2], [10, 1], [4, 3], [9, 6]].map(([a, b]) => `<span style="font-size:22pt">${eq(a, '−', b, '=', '_')}</span>`), 'fill')}`),
    wordProblems('مسائل الطرح', tagU(u, 3), [['عند زينب ٨ بالونات، طار منها ٣. كم بالوناً بقي؟', 8, 3], ['على الشجرة ٧ طيور، طار منها ٢. كم طيراً بقي على الشجرة؟', 7, 2], ['في الصحن ١٠ تمرات، أكل أحمد ٤. كم تمرة بقيت؟', 10, 4], ['مع مريم ٩ ملصقات، أعطت صديقتها ٥. كم ملصقاً بقي معها؟', 9, 5]], true),
    drill('تمرينُ دقيقة: الطرح حتى ١٠', tagU(u, 4), Array.from({ length: 27 }, () => { const a = rnd(1, 10); return [a, '−', rnd(0, a)]; })),
  ] },
];

// ---------- المراجعة والتلوين والأدوات ----------
function review(k, title) {
  const items = [
    () => `<div style="width:22mm;height:22mm">${dots(rnd(1, 5), 'rand', rnd(1, 99))}</div>${box()}`,
    () => `<div style="width:36mm;height:15mm">${tenFrame(rnd(1, 10))}</div>${box()}`,
    () => `<span style="font-size:20pt">${eq(rnd(0, 5), '+', rnd(0, 5), '=', '_')}</span>`,
    () => { const a = rnd(3, 10); return `<span style="font-size:20pt">${eq(a, '−', rnd(0, a), '=', '_')}</span>`; },
    () => `<span style="font-size:20pt">${eq(rnd(0, 20), '_', rnd(0, 20))}</span>`,
    () => { const w = rnd(4, 10); return `<div style="width:30mm;height:25mm">${bond(w, rnd(0, w), null)}</div>`; },
  ].slice(0, k + 2);
  const list = Array.from({ length: 12 }, (_, i) => items[i % items.length]());
  return P(`${H(`مراجعة: ${title}`, `مراجعة ${hd(k)}`)}
  ${grid(3, list, 32)}
  ${sec(1, 'أكتبُ الأعداد التي يُمليها المعلّم', `<div class="row">${Array.from({ length: 8 }, () => '<div class="cell" style="height:18mm"></div>').join('')}</div>`)}
  <div class="sec" style="display:flex;justify-content:space-around;font-size:13pt;font-weight:700;padding:2.5mm"><span>الصحيح: ..... من ${hd(20)}</span><span>أتقنتُ؟ نعم ☐ لا ☐</span><span>توقيع المعلّم: .........</span></div>`);
}

// لوّن حسب الرقم: رسوم بكسليّة
const PIX = [
  ['قلب', ['..1111..1111..', '.112211112211.', '11222211222211', '11222222222211', '11222222222211', '.112222222211.', '..1122222211..', '...11222211...', '....112211....', '.....1111.....', '..............'], { 1: 'أسود', 2: 'أحمر' }],
  ['بيت', ['......11......', '.....1221.....', '....122221....', '...12222221...', '..1222222221..', '.111111111111.', '.133333333331.', '.134433333331.', '.134433355331.', '.133333355331.', '.111111111111.'], { 1: 'بنّي', 2: 'أحمر', 3: 'أصفر', 4: 'أزرق', 5: 'أخضر' }],
  ['سمكة', ['..............', '.....111......', '...1122211..1.', '..122222221.11', '.12322222221.1', '.12222222222.1', '.12222222221.1', '..122222221.11', '...1122211..1.', '.....111......', '..............'], { 1: 'أسود', 2: 'برتقاليّ', 3: 'أبيض' }],
  ['شجرة', ['.....1111.....', '...11222211...', '..1222222221..', '.122222222221.', '.122222222221.', '..1222222221..', '...11222211...', '.....1331.....', '.....1331.....', '.....1331.....', '...11111111...'], { 1: 'أسود', 2: 'أخضر', 3: 'بنّي' }],
  ['بالون', ['....111111....', '...12222221...', '..1222222221..', '..1222222221..', '..1222222221..', '...12222221...', '....122221....', '......11......', '.......1......', '......1.......', '.......1......'], { 1: 'أسود', 2: 'أحمر' }],
  ['سيّارة', ['..............', '....1111111...', '...123323321..', '..12222222221.', '.1222222222221', '.1222222222221', '.1111111111111', '...144...144..', '...144...144..', '....1.....1...', '..............'], { 1: 'أسود', 2: 'أحمر', 3: 'أزرق', 4: 'رماديّ' }],
];
function colorByNumber([name, rows, legend], k) {
  const cells = rows.flatMap((r, y) => [...r].map((c, x) => ({ c, x, y })));
  const W = rows[0].length, Hh = rows.length, s = 40;
  const o = cells.map(({ c, x, y }) => `<rect x="${x * s}" y="${y * s}" width="${s}" height="${s}" fill="#fff" stroke="#111" stroke-width="1.6"/>${c === '.' ? '' : `<text x="${x * s + s / 2}" y="${y * s + 28}" text-anchor="middle" font-family="Cairo" font-weight="700" font-size="20">${hd(c)}</text>`}`).join('');
  return P(`${H(`ألوّنُ حسب الرقم: ${name}`, 'تلوين')}
  <div class="sec" style="display:flex;flex-wrap:wrap;gap:4mm;justify-content:center;font-size:14pt;font-weight:700">${Object.entries(legend).map(([d, c]) => `<span>${hd(d)} = ${c}</span>`).join('<span>◆</span>')}<span>◆</span><span>الفارغ = أبيض</span></div>
  <div style="flex:1" dir="ltr">${svg(`-4 -4 ${W * s + 8} ${Hh * s + 8}`, o)}</div>`);
}

function cutouts() {
  const cut = 'border:.5mm dashed #111';
  return [
    P(`${H('أدواتي للقصّ: إطارات العشرة', 'أدوات')}<div style="display:flex;flex-direction:column;gap:6mm;flex:1;justify-content:center">${[0, 0, 0, 0].map(() => `<div style="${cut};padding:4mm;height:50mm">${tenFrame(0)}</div>`).join('')}</div><div style="text-align:center;font-size:11pt">✂ أقصّ الإطارات وأستعمل معها حبوباً أو أغطية قناني</div>`),
    P(`${H('أدواتي للقصّ: بطاقات الأعداد', 'أدوات')}<div style="display:grid;grid-template-columns:repeat(4,1fr);grid-auto-rows:1fr;flex:1;${cut}">${Array.from({ length: 24 }, (_, i) => `<div style="${cut};display:flex;align-items:center;justify-content:center;font-size:40pt;font-weight:900">${i <= 20 ? hd(i) : ['+', '−', '='][i - 21]}</div>`).join('')}</div>`),
    P(`${H('أدواتي للقصّ: بطاقات النقاط', 'أدوات')}<div style="display:grid;grid-template-columns:repeat(4,1fr);grid-auto-rows:1fr;gap:0;flex:1;${cut}">${[1, 2, 3, 4, 5, 6, 1, 2, 3, 4, 5, 6, 2, 3, 4, 5, 3, 4, 5, 2].map((v, i) => `<div style="${cut};padding:3mm">${dots(v, i < 12 ? 'dice' : 'rand', i)}</div>`).join('')}</div>`),
    P(`${H('أدواتي للقصّ: خطّ الأعداد ٠–٢٠', 'أدوات')}<div style="display:flex;flex-direction:column;gap:10mm;flex:1;justify-content:center">${[[0, 10], [10, 20]].map(([a, b]) => `<div style="${cut};padding:4mm">${numberLine(a, b, { h: 110 })}</div>`).join('')}</div><div style="text-align:center;font-size:11pt">✂ أقصّ الشريطين وألصقهما عند العدد ${hd(10)} فيصبح عندي خطّ أعداد من ${hd(0)} إلى ${hd(20)}</div>`),
  ];
}

// ---------- أساليب حديثة: أيّها لا ينتمي، أقدّر ثمّ أعدّ، اكتشف الخطأ، كيف أشعر ----------
const T = (t, pt = 26) => `<span style="font-weight:800;font-size:${pt}pt">${t}</span>`;
const fr = (v, w = 40, h = 17) => `<div style="width:${w}mm;height:${h}mm">${tenFrame(v)}</div>`;
const dt = (v, st, sd) => `<div style="width:30mm;height:30mm">${dots(v, st, sd)}</div>`;
const THINK = [
  { w: [dt(3, 'dice'), dt(3, 'line'), dt(4, 'dice'), dt(3, 'rand', 4)], e: [12, 'star'], err: [dt(5, 'dice'), 'قال سامي: هنا ٤ نقاط.'] },
  { w: [`<div style="width:100%;height:20mm">${objects(5, 'apple', 5)}</div>`, `<div style="width:100%;height:20mm">${objects(5, 'star', 5)}</div>`, `<div style="width:100%;height:20mm">${objects(4, 'apple', 5)}</div>`, `<div style="width:100%;height:20mm">${objects(5, 'apple', 5)}</div>`], e: [9, 'apple'], err: [`<div style="width:60mm;height:22mm">${objects(7, 'star', 7)}</div>`, 'عدّ سامي النجوم فقال: ٨.'] },
  { w: [T(eq(3), 40), fr(3), dt(3, 'dice'), fr(5)], e: [14, 'ball'], err: [`<div style="width:50mm;height:20mm">${objects(4, 'apple', 4)}</div>`, 'كتب سامي تحت الصورة العدد ٣.'] },
  { w: [T(eq(7), 40), fr(7), `<div style="width:100%;height:22mm">${objects(7, 'lemon', 4)}</div>`, T(eq(9), 40)], e: [16, 'star'], err: [fr(8, 50, 21), 'قال سامي: في الإطار ٧ نقاط.'] },
  { w: [fr(10), fr(0), fr(5), fr(10)], e: [11, 'lemon'], err: [fr(6, 50, 21), 'قال سامي: ينقص ٥ ليمتلئ الإطار.'] },
  { w: [T(eq(2, '،', 3, '،', 4), 22), T(eq(5, '،', 6, '،', 7), 22), T(eq(8, '،', 7, '،', 6), 22), T(eq(1, '،', 2, '،', 3), 22)], e: [15, 'ball'], err: [T(eq(3, '،', 4, '،', 6, '،', 7), 26), 'عدّ سامي هكذا.'] },
  { w: [T(eq(3, '<', 5), 24), T(eq(7, '>', 2), 24), T(eq(4, '=', 4), 24), T(eq(6, '<', 9), 24)], e: [18, 'star'], err: [T(eq(8, '<', 5), 30), 'كتب سامي هذه المقارنة.'] },
  { w: [`<div style="width:34mm;height:28mm">${bond(5, 2, 3)}</div>`, `<div style="width:34mm;height:28mm">${bond(5, 4, 1)}</div>`, `<div style="width:34mm;height:28mm">${bond(6, 3, 3)}</div>`, `<div style="width:34mm;height:28mm">${bond(5, 0, 5)}</div>`], e: [13, 'apple'], err: [`<div style="width:38mm;height:31mm">${bond(7, 3, 5)}</div>`, 'أكمل سامي بيت العدد هكذا.'] },
  { w: [T(eq(3, 'و', 7), 26), T(eq(4, 'و', 6), 26), T(eq(5, 'و', 4), 26), T(eq(2, 'و', 8), 26)], e: [17, 'lemon'], err: [T(eq(6, '+', 3, '=', 10), 28), 'قال سامي: ٦ و٣ صديقان للعشرة.'] },
  { w: [T(eq(12), 34), T(eq(15), 34), T(eq(18), 34), T(eq(20), 34)], e: [20, 'star'], err: [`<div style="display:flex;flex-direction:column;gap:1mm">${fr(10, 44, 18)}${fr(4, 44, 18)}</div>`, 'قال سامي: هذا العدد ١٥.'] },
  { w: [T(eq(3, '+', 4), 24), T(eq(5, '+', 2), 24), T(eq(6, '+', 1), 24), T(eq(4, '+', 4), 24)], e: [19, 'ball'], err: [T(eq(5, '+', 3, '=', 7), 30), 'هذا حلّ سامي.'] },
  { w: [T(eq(9, '−', 4), 24), T(eq(8, '−', 3), 24), T(eq(7, '−', 2), 24), T(eq(10, '−', 4), 24)], e: [14, 'apple'], err: [T(eq(9, '−', 4, '=', 6), 30), 'هذا حلّ سامي.'] },
];
function thinkPage(i) {
  const t = THINK[i];
  return P(`${H(`تحدّي التفكير: ${UNITS[i].t}`, `الوحدة ${hd(i + 1)} · تفكير`)}
  ${sec(1, 'أيّها لا ينتمي؟', `<div class="row" style="height:36mm">${t.w.map(x => `<div class="cell" style="padding:1.5mm">${x}</div>`).join('')}</div><div style="font-size:11.5pt;margin-top:2mm">أضع دائرة حول واحد وأشرح لماذا: ...........................................................</div>`, '', 'لا توجد إجابة واحدة!')}
  <div class="row" style="flex:1;min-height:0">
    ${sec(2, 'أقدّرُ ثمّ أعدّ', `<div style="height:50mm">${scatter(t.e[0], t.e[1], i + 5)}</div><div class="row" style="font-size:12pt;font-weight:700;margin-top:2mm"><div class="cell" style="height:12mm;gap:2mm">تقديري ${box(12, 9)}</div><div class="cell" style="height:12mm;gap:2mm">العدد ${box(12, 9)}</div></div>`, 'grow')}
    ${sec(3, 'أكتشفُ خطأ سامي', `<div class="cell" style="height:40mm;flex-direction:column;gap:2mm;padding:2mm"><span style="font-size:12.5pt;font-weight:700">${t.err[1]}</span>${t.err[0]}</div><div style="font-size:11.5pt;margin-top:2mm;line-height:2">صحيح ☐ خطأ ☐ &nbsp; الصواب: ${box(16, 9)}</div>`, 'grow')}
  </div>
  ${sec(4, 'كيف أشعرُ بعد هذه الوحدة؟', `<div class="row">${[[2, 'فهمتُ وأستطيع أن أشرح'], [1, 'فهمتُ وأحتاج تدريباً'], [0, 'أحتاج مساعدة']].map(([m, l]) => `<div class="cell" style="height:24mm;gap:3mm"><div style="width:15mm;height:15mm">${face(m)}</div><span style="font-size:11pt;font-weight:700">${l}</span></div>`).join('')}</div>`)}`);
}

function numberTalks() {
  return [P(`${H('حوار الأعداد: خمس دقائق كلّ يوم', 'للمعلّم')}
    <div class="sec" style="font-size:12.5pt;line-height:1.9">«حوار الأعداد» روتين صفّيّ قصير تستعمله المدارس الحديثة لبناء الحسّ العدديّ والحساب الذهنيّ: يعرض المعلّم صورة أو مسألة، ويفكّر التلاميذ بصمت، ثمّ يشرح كلّ واحد <b>كيف</b> رأى الحلّ. المهمّ هو الطريقة لا السرعة.</div>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:3.5mm">${[['أعرض', 'أُري التلاميذ صورة من الصفحة التالية (أو أرسمها على السبّورة).'], ['أفكّر بصمت', 'يضع التلميذ إبهامه على صدره عندما يجد الجواب، ويبحث عن طريقة ثانية.'], ['أشارك', 'يقول عدّة تلاميذ أجوبتهم دون حكم، ثمّ يشرحون طرقهم.'], ['أسجّل', 'أرسم طرق التلاميذ على السبّورة: «رأيتُ ٣ ثمّ ٢»، «رأيتُ ٥ ناقص واحد».'], ['أشجّع', 'أمدح الطريقة والشرح، وأقبل الخطأ فرصةً للتعلّم.'], ['أكرّر', 'خمس دقائق يوميّاً تكفي، في بداية حصّة الرياضيات.']].map(([t, d], k) => `<div class="sec" style="padding:3mm 4.5mm"><div class="t"><i>${hd(k + 1)}</i><span>${t}</span></div><div style="font-size:11.5pt;line-height:1.7">${d}</div></div>`).join('')}</div>
    ${sec(7, 'أسئلة الحوار', `<div style="font-size:12.5pt;line-height:2">● كم ترى؟ كيف رأيتها؟ ● من رآها بطريقة أخرى؟ ● هل تتّفق مع صديقك؟ لماذا؟ ● كيف نتأكّد؟</div>`, 'grow')}`),
  P(`${H('صور حوار الأعداد', 'للمعلّم')}<div style="display:grid;grid-template-columns:repeat(3,1fr);gap:4mm;flex:1">${[dt(5, 'dice'), fr(7, 52, 22), dt(6, 'dice'), fr(9, 52, 22), `<div style="width:40mm;height:40mm">${bond(8, 5, null)}</div>`, T(eq(5, '+', 5, '+', 1), 22), dt(4, 'rand', 3), fr(4, 52, 22), T(eq(9, '+', 1), 30)].map(x => `<div class="cell" style="padding:3mm">${x}</div>`).join('')}</div>`)];
}

function adventureMap(stations) {
  const pts = stations.map((_, i) => { const row = Math.floor(i / 3), col = i % 3, c = row % 2 ? 2 - col : col; return [830 - c * 330, 110 + row * 235]; });
  const path = 'M' + pts.map(p => p.join(' ')).join(' L') + ` L${pts[pts.length - 1][0]} 1000`;
  return P(`${H('خريطةُ مغامرتي', 'نجاح')}
  <div style="font-size:12pt;text-align:center">كلّما أنهيتُ محطّة ألوّنُها وأرسم فيها نجمة. في نهاية الطريق تنتظرني شهادة الإتقان!</div>
  <div style="flex:1;min-height:0">${svg('0 0 1000 1130', `<path d="${path}" fill="none" stroke="#111" stroke-width="10" stroke-dasharray="4 22" stroke-linecap="round"/>
    ${pts.map(([x, y], i) => `<circle cx="${x}" cy="${y}" r="62" fill="#fff" stroke="#111" stroke-width="6"/><text x="${x}" y="${y + 15}" text-anchor="middle" font-family="Cairo" font-weight="900" font-size="44">${hd(i + 1)}</text>
      <text x="${x}" y="${y + 100}" text-anchor="middle" font-family="Cairo" font-weight="800" font-size="30">${stations[i]}</text>`).join('')}
    <g transform="translate(${pts[pts.length - 1][0]} 1040)"><path d="M-55 -60 H55 V-20 Q55 30 0 34 Q-55 30 -55 -20Z" fill="#fff" stroke="#111" stroke-width="6"/><path d="M-55 -45 Q-95 -45 -85 -10 Q-75 10 -50 8 M55 -45 Q95 -45 85 -10 Q75 10 50 8" fill="none" stroke="#111" stroke-width="6"/><rect x="-14" y="32" width="28" height="22" fill="#fff" stroke="#111" stroke-width="5"/><rect x="-45" y="52" width="90" height="22" rx="4" fill="#fff" stroke="#111" stroke-width="5"/><text x="0" y="-12" text-anchor="middle" font-family="Cairo" font-weight="900" font-size="24">الشهادة</text></g>`)}</div>`);
}

function gameBoard() {
  const cells = Array.from({ length: 30 }, (_, i) => i + 1);
  const special = { 4: 'تقدّم ٢', 9: 'ارجع ٣', 13: 'تقدّم ٣', 18: 'ارجع ٢', 22: 'تقدّم ٢', 27: 'ارجع ٤' };
  const rows = [0, 1, 2, 3, 4].map(r => { const s = cells.slice(r * 6, r * 6 + 6); return r % 2 ? s.reverse() : s; }).reverse();
  return P(`${H('لعبة السباق إلى ٣٠', 'لعبة')}
  <div class="sec" style="font-size:12pt;line-height:1.8"><b>طريقة اللعب:</b> يرمي كلّ لاعب حجر النرد ويقول العدد بنظرة سريعة، ثمّ يتقدّم ويعدّ المربّعات بصوت عالٍ. من يصل إلى ${hd(30)} أوّلاً يفوز!</div>
  <div style="display:grid;grid-template-columns:repeat(6,1fr);grid-auto-rows:1fr;gap:2mm;flex:1">${rows.flat().map(v => `<div class="cell" style="flex-direction:column;gap:1mm;${special[v] ? 'border-width:1mm' : ''}"><b style="font-size:24pt">${hd(v)}</b>${special[v] ? `<span style="font-size:10pt;font-weight:800">${special[v]}</span>` : ''}</div>`).join('')}</div>`);
}

function diag(title, tag) {
  return [P(`${H(title, tag)}
    ${sec(1, 'أكتبُ عدد النقاط (نظرة سريعة)', grid(4, [3, 5, 2, 4].map((v, i) => `<div style="width:22mm;height:22mm">${dots(v, i % 2 ? 'rand' : 'dice', i + 70)}</div>${box()}`), 28))}
    ${sec(2, 'أعدُّ وأكتبُ', grid(3, [[7, 'apple'], [9, 'star'], [6, 'ball']].map(([v, o]) => `<div style="flex:1;height:22mm">${objects(v, o, 5)}</div>${box()}`), 30))}
    ${sec(3, 'أكتبُ ما يُمليه المعلّم', `<div class="row">${Array.from({ length: 6 }, () => '<div class="cell" style="height:18mm"></div>').join('')}</div>`)}
    ${sec(4, 'أكملُ خطّ الأعداد', numberLine(0, 10, { hide: [3, 6, 9], h: 74 }), 'grow')}`),
  P(`${H(title, tag)}
    ${sec(5, 'أضعُ دائرةً حولَ الأكبر', grid(4, [[4, 7], [9, 2], [12, 15], [18, 11]].map(([a, b]) => `${big(hd(a), 26)}${big(hd(b), 26)}`), 20))}
    ${sec(6, 'أكملُ بيت العدد', grid(3, [[5, 2], [8, 3], [10, 6]].map(([w, a]) => `<div style="width:32mm;height:27mm">${bond(w, a, null)}</div>`), 32))}
    ${sec(7, 'أجمعُ وأطرحُ', grid(4, [[3, '+', 2], [4, '+', 5], [6, '+', 4], [2, '+', 7], [5, '−', 2], [9, '−', 4], [8, '−', 8], [10, '−', 3]].map(([a, o, b]) => `<span style="font-size:18pt">${eq(a, o, b, '=', '_')}</span>`), 18))}
    ${sec(8, 'مسألة', `<div style="font-size:13pt;font-weight:700">مع ليلى ${hd(6)} حلوى، وأعطتها جدّتها ${hd(3)}. كم حلوى معها؟ ${box(16, 11)}</div>`, 'grow')}
    <div class="sec" style="display:flex;justify-content:space-around;font-size:13pt;font-weight:700;padding:2.5mm"><span>المجموع: ..... من ${hd(30)}</span><span>التاريخ: ..../..../........</span></div>`)];
}

function titlePage() {
  return P(`<div style="border:1.2mm solid #111;border-radius:9mm;flex:1;display:flex;flex-direction:column;align-items:center;padding:12mm 10mm;gap:6mm;text-align:center">
    <div style="font-size:14pt;font-weight:700;border:.6mm solid #111;border-radius:5mm;padding:1mm 6mm">سلسلة علاج الضعف في الرياضيات</div>
    <div style="font-size:66pt;font-weight:900;line-height:1.15">أحسب بثقة</div>
    <div style="font-size:22pt;font-weight:900;background:#111;color:#fff;border-radius:6mm;padding:2mm 10mm">المستوى الأول</div>
    <div style="font-size:18pt;font-weight:700;line-height:1.5">أفهم العدد<br>من ٠ إلى ٢٠</div>
    <div style="width:56mm;height:46mm">${pic("monkey")}</div><div class="row" style="width:150mm;height:30mm"><div style="flex:1">${tenFrame(7)}</div><div style="flex:0 0 30mm">${dots(5)}</div><div style="flex:0 0 36mm">${bond(10, 6, 4)}</div></div>
    <div style="width:150mm">${numberLine(0, 10, { h: 70 })}</div>
    <div style="margin-top:auto;width:100%;font-size:15pt;line-height:2.4;text-align:right">اسم التلميذ: ............................................................<br>الصف والشعبة: ......................... المدرسة: ..................................</div></div>`);
}
function guidePage() {
  const steps = [
    ['ابدأ بالتشخيص', 'الاختبار التشخيصي يحدّد من أين يبدأ التلميذ. لا تبدأ من الوحدة الأولى إن أتقنها.'],
    ['خمس صفحات لكلّ وحدة', 'محسوس (أشياء حقيقيّة) ← مصوّر (رسوم وإطار العشرة) ← مجرّد (أرقام) ← طلاقة ← تطبيق.'],
    ['تعليم صريح', 'اعرض الحلّ وأنت تفكّر بصوت مسموع، ثمّ حلّ مع التلميذ، ثمّ دعه يحلّ وحده مع تصحيح فوريّ.'],
    ['خطّ الأعداد وإطار العشرة', 'هما الأداتان الأساسيّتان في كلّ الوحدات، مع «تحدّي التفكير» و«حوار الأعداد».'],
    ['دقيقة طلاقة', 'نشاط موقوت قصير في كلّ وحدة. نقارن التلميذ بنفسه لا بزملائه.'],
    ['مراجعة تراكميّة', 'كلّ مراجعة تعيد مهارات الوحدات السابقة كلّها، لأنّ المتعثّر ينسى بسرعة.'],
  ];
  return P(`${H('كيف تستعمل هذا الكتاب؟', 'دليل المعلّم')}
  <div class="sec" style="font-size:12pt;line-height:1.75">يعالج هذا المستوى أكثر فجوة شائعة عند المتعثّرين: <b>الحسّ العدديّ</b>. التلميذ الذي يعدّ على أصابعه ليجمع ٨ + ٥ لن يتقدّم في الضرب والكسور. <b>المرجع:</b> دليل IES لمساعدة المتعثّرين في الرياضيات (٢٠٢١)، وأبحاث خطّ الأعداد والإدراك السريع للكمية، والتدرّج من المحسوس إلى المجرّد.</div>
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:3.5mm">${steps.map(([t, d], i) => `<div class="sec" style="padding:3mm 4.5mm"><div class="t"><i>${hd(i + 1)}</i><span>${t}</span></div><div style="font-size:11pt;line-height:1.65">${d}</div></div>`).join('')}</div>
  ${sec(7, 'موادّ بسيطة نحتاجها', `<div style="font-size:11.5pt;line-height:1.8">أغطية قناني أو حبوب، عيدان (أعواد مثلّجات)، حجر نرد، وطباشير لرسم خطّ الأعداد على الأرض.</div>`)}
  <div class="parent" style="font-size:11pt"><b>ملاحظة:</b><span>تُكتب الجمل العدديّة وخطّ الأعداد من اليمين إلى اليسار كما في كتابتنا العربيّة.</span></div>`);
}
function parentPages() {
  return [P(`${H('رسالة إلى الأهل الكرام', 'للأهل')}
    <div class="sec" style="font-size:13pt;line-height:1.95">أولياء الأمور الكرام، تحيّة طيّبة.<br>يتعلّم طفلكم في هذا الكتاب <b>فهم العدد من ٠ إلى ٢٠</b>: العدّ، والمقارنة، وتكوين العدد، والجمع والطرح البسيطين. الرياضيات تُبنى درجةً درجة، وعشر دقائق يوميّاً من اللعب بالأعداد تصنع فرقاً كبيراً.</div>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:4mm">
      ${sec(1, 'ألعاب بيتيّة', `<div style="font-size:12pt;line-height:1.9">● عدّ الدرج والصحون والأحذية.<br>● حجر النرد: كم نقطة؟<br>● «أيّهما أكثر؟» بالتمر أو الحلوى.<br>● تقسيم ١٠ حبّات بين شخصين بطرق مختلفة.</div>`)}
      ${sec(2, 'عبارات تشجيع', `<div style="font-size:12pt;line-height:1.9">● «طريقتك ذكيّة، اشرحها لي».<br>● «أخطأت؟ ممتاز، نتعلّم من الخطأ».<br>● «أنت أسرع من الأمس!»<br>● «هيّا نعدّ معاً».</div>`)}
      ${sec(3, 'ما نتجنّبه', `<div style="font-size:12pt;line-height:1.9">● قول «أنا أيضاً كنت ضعيفاً في الرياضيات».<br>● الحفظ دون فهم.<br>● حلّ الواجب عن الطفل.<br>● المقارنة بالآخرين.</div>`)}
      ${sec(4, 'علامات التقدّم', `<div style="font-size:12pt;line-height:1.9">● يعرف الكمية الصغيرة دون عدّ.<br>● يعدّ دون أن يكرّر أو يقفز.<br>● يعرف أصدقاء العشرة بسرعة.<br>● يشرح كيف وصل إلى الجواب.</div>`)}
    </div>`),
  P(`${H('خطّة البيت الأسبوعيّة', 'للأهل')}
    <table style="font-size:11pt"><thead><tr style="height:11mm;background:#eee"><th style="width:24mm">اليوم</th>${['لعبة عدّ', 'ركن الأهل', 'تمرين دقيقة', 'أعدّ أشياء البيت'].map(t => `<th>${t}</th>`).join('')}<th style="width:28mm">توقيع وليّ الأمر</th></tr></thead>
    <tbody>${['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'].map(d => `<tr style="height:15mm"><td style="font-weight:700">${d}</td>${[0, 1, 2, 3].map(() => '<td style="font-size:16pt">☐</td>').join('')}<td></td></tr>`).join('')}</tbody></table>
    ${sec(1, 'ملاحظات الأهل للمعلّم', `${X.lineBox(11)}${X.lineBox(11)}${X.lineBox(11)}`, 'grow')}`)];
}
function trackerPage() {
  return P(`${H('جدول متابعة التقدّم', 'للمعلّم')}
  <table style="font-size:11pt"><thead><tr style="height:11mm;background:#eee"><th style="width:52mm">الوحدة</th><th>محسوس</th><th>مصوّر</th><th>مجرّد</th><th>الطلاقة (صحيحة/دقيقة)</th><th style="width:24mm">التاريخ</th></tr></thead>
  <tbody>${UNITS.map((u, i) => `<tr style="height:16.5mm"><td style="font-weight:700">${hd(i + 1)}. ${u.t}</td><td></td><td></td><td></td><td></td><td></td></tr>`).join('')}</tbody></table>`);
}
function certificate() {
  return P(`<div style="border:1.4mm double #111;border-radius:9mm;flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:7mm;text-align:center;padding:12mm">
    <div style="height:42mm;width:42mm">${pic('star')}</div>
    <div style="font-size:42pt;font-weight:900">شهادةُ إتقان</div>
    <div style="font-size:20pt;font-weight:700">المستوى الأول من سلسلة «أحسب بثقة»</div>
    <div style="font-size:16pt;line-height:2.2">تُمنح هذه الشهادة للتلميذ/ة<br>.......................................................................<br>لإتقانه فهم الأعداد من ٠ إلى ٢٠ والجمع والطرح البسيطين</div>
    <div style="display:flex;gap:30mm;font-size:14pt;margin-top:6mm"><span>المعلّم/ة: ..................</span><span>التاريخ: ..../..../........</span></div>
    <div class="row" style="width:150mm;height:26mm"><div style="flex:1">${tenFrame(10)}</div></div></div>`);
}

async function build(out) {
  n = 0;
  const pages = [titlePage(), ...parentPages(), guidePage(), ...numberTalks(), ...diag('الاختبار التشخيصي', 'قبل البدء'), trackerPage(),
    adventureMap(['أرى دون عدّ', 'أعدّ الأشياء', '١ إلى ٥', '٦ إلى ١٠', 'الصفر والإطار', 'خطّ الأعداد', 'المقارنة', 'بيت العدد', 'أصدقاء العشرة', '١١ إلى ٢٠', 'الجمع', 'الطرح'])];
  const RV = { 2: 'الوحدات ١–٣', 5: 'الوحدات ١–٦', 8: 'الوحدات ١–٩', 11: 'الوحدات ١–١٢' };
  let pix = 0;
  UNITS.forEach((u, i) => {
    pages.push(...u.pages(i + 1), thinkPage(i));
    if (RV[i]) { const k = Object.keys(RV).indexOf(String(i)) + 1; pages.push(review(k, RV[i]), colorByNumber(PIX[pix], pix + 1)); pix++; }
  });
  pages.push(gameBoard(), ...diag('الاختبار البعدي', 'نهاية المستوى'));
  while ((pages.length + 1) % 4 && pix < PIX.length) { pages.push(colorByNumber(PIX[pix], pix + 1)); pix++; }
  while ((pages.length + 1) % 4) pages.push(gameBoard());
  pages.push(certificate());
  await renderPDF(pages, out);
  return pages.length;
}
module.exports = { build, UNITS };
if (require.main === module) build(path.join(ROOT, 'output/math1-interior.pdf')).then(c => console.log('pages', c));
