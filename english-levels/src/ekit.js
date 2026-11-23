// عُدّة سلسلة الإنكليزي «Read English with Confidence»: صفحات من اليسار إلى اليمين، تعليمات إنكليزيّة + ترجمة عربيّة
const fs = require('fs');
const path = require('path');
const R = '../../arabic-reading-levels/src/';
const { hd, shuffle, page, renderPDF } = require(R + 'common');
const { pic } = require(R + 'pics');
const MT = require('../../math-levels/src/mtheme');
const M = require('../../math-levels/src/mlib');
const ROOT = path.resolve(__dirname, '..');
// خطّ Cairo وحده (هويّة وصال): الأسماء Andika وFredoka مجرّد أسماء داخليّة تشير إلى ملفّات Cairo
const CF = f => fs.readFileSync(path.join(ROOT, '../arabic-reading-levels/fonts', f)).toString('base64');
const ff = (fam, f, wt) => `@font-face{font-family:'${fam}';font-weight:${wt};src:url(data:font/ttf;base64,${CF(f)}) format('truetype')}`;
const FONTS = ff('Andika', 'Cairo-SemiBold.ttf', 400) + ff('Andika', 'Cairo-Bold.ttf', 700) +
  ff('Fredoka', 'Cairo-SemiBold.ttf', 500) + ff('Fredoka', 'Cairo-Bold.ttf', 600) + ff('Fredoka', 'Cairo-ExtraBold.ttf', 700);

const VOW = 'aeiouAEIOU';
const VC = '#E63946', CC = '#1D4ED8';
const CSS = FONTS + MT.CSS + `
.page.en{direction:ltr}
.page.en .mh .side{border-right:none;border-left:.4mm dashed var(--st)}
.page.en .mh h1{font-family:Fredoka;font-weight:700;letter-spacing:.2pt}
.page.en .mh .goal{font-family:Fredoka;font-weight:600}
.page.en .tab{right:auto;left:0;border-radius:0 3mm 3mm 0}
.page.en .sami .b::before{right:auto;left:-2.3mm;border-left:0;border-right:2.2mm solid #E0B400}
.page.en .sec>.t{font-family:Fredoka;font-weight:600}
.ar{font-family:Cairo;direction:rtl;unicode-bidi:isolate;display:block}
.ar-i{font-family:Cairo;direction:rtl;unicode-bidi:isolate}
.en{font-family:Andika}
.sami .b .ar{font-size:10pt;color:#6b4e00;font-weight:600;margin-top:.3mm}
.sec>.t .ar-i{font-size:10pt;color:#475569;font-weight:600;margin-inline-start:2mm}
.mh .ar{font-size:10.5pt;color:#334155;font-weight:700;line-height:1.2}
`;

function makeKit(LV, GOALS) {
  let n = 0;
  const K = { CSS };
  K.reset = () => (n = 0);
  K.P = inner => page(inner, { n: ++n, level: LV, series: 'Read English with Confidence · أقرأ الإنكليزيّة بثقة' }).replace('<section class="page">', '<section class="page en">');
  // رأس الصفحة: إنكليزي + عربي
  K.H = (title, ar, { unit = 0, stage = null, tag = '', review = false } = {}) => {
    const g = unit ? GOALS[unit - 1] : null;
    let h = MT.mheader(title, { unit, stage, tag, review });
    const goalHtml = g ? `<div class="goal"><span style="width:4mm;height:4mm;display:inline-block">${M.icon('star', 'currentColor')}</span>I can ${g[0]} <span class="ar-i" style="font-weight:700;opacity:.85">· ${g[1]}</span></div>` : `<div class="ar">${ar}</div>`;
    h = h.replace('</h1>', '</h1>' + goalHtml);
    if (g) h = h.replace(/<\/h1>/, ` <span class="ar-i" style="font-size:11pt;color:#475569;font-weight:700">${ar}</span></h1>`);
    h = h.replace(/<div class="unit">الوحدة (.*?)<\/div>/, (_, u) => `<div class="unit" style="font-family:Fredoka">Unit ${u.replace(/[٠-٩]/g, d => '٠١٢٣٤٥٦٧٨٩'.indexOf(d))}</div>`);
    for (const [x, y] of [['محسوس', 'Do'], ['مصوّر', 'See'], ['مجرّد', 'Write'], ['طلاقة', 'Speed'], ['تطبيق', 'Use'], ['تفكير', 'Think'], ['مراجعة', 'Review']]) h = h.split(`>${x}<`).join(`>${y}<`).split(`</div>${x}</div>`).join(`</div>${y}</div>`);
    h = h.replace(/(<div class="tab"[^>]*>)([٠-٩]+)/, (m, a, d) => a + [...d].map(c => '٠١٢٣٤٥٦٧٨٩'.indexOf(c)).join(''));
    h = h.replace('<div class="ic">', '<div class="ic" style="font-family:Fredoka;font-size:10pt">');
    return h;
  };
  K.T = (en, ar) => `${en}<span class="ar-i">${ar}</span>`;
  let SAMI = null;
  K.sami = (en, ar) => { SAMI = SAMI || pic('monkey', 'pic', true); return `<div class="sami"><div class="m">${SAMI}</div><div class="b"><span style="font-family:Fredoka;font-weight:500;font-size:12.5pt">${en}</span><span class="ar">${ar}</span></div></div>`; };
  K.box = (w = 13, h = 12) => `<span style="display:inline-block;width:${w}mm;height:${h}mm;border:.5mm solid #111;border-radius:2mm;flex:none;background:#fff"></span>`;
  // كلمة ملوّنة: الحركات حمراء والصوامت زرقاء
  K.cw = (w, pt = 28, hl = null) => `<span class="en" style="font-weight:700;font-size:${pt}pt;line-height:1">${[...w].map((c, i) => `<span style="color:${hl !== null && i !== hl ? '#94a3b8' : VOW.includes(c) ? VC : CC}">${c}</span>`).join('')}</span>`;
  // كلمة بأزرار صوتيّة (نقطة تحت كلّ صوت)
  K.sb = (w, pt = 30) => `<span style="display:inline-flex;gap:1.4mm;align-items:flex-end">${[...w].map(c => `<span style="display:inline-flex;flex-direction:column;align-items:center"><span class="en" style="font-weight:700;font-size:${pt}pt;line-height:1.1;color:${VOW.includes(c) ? VC : CC}">${c}</span><span style="width:3.2mm;height:3.2mm;border-radius:50%;background:${VOW.includes(c) ? VC : CC};margin-top:.8mm"></span></span>`).join('')}</span>`;
  // سطر الكتابة الرباعيّ مع نصّ رماديّ للتتبّع
  K.hw = (text = '', { fs = 112, ls = 26 } = {}) => `<div style="width:100%;aspect-ratio:1000/150">${M.svg('0 0 1000 150', `<line x1="0" y1="24" x2="1000" y2="24" stroke="#94a3b8" stroke-width="2"/><line x1="0" y1="47" x2="1000" y2="47" stroke="#F87171" stroke-width="2.2" stroke-dasharray="12 9"/><line x1="0" y1="110" x2="1000" y2="110" stroke="#1E3A8A" stroke-width="3"/><line x1="0" y1="140" x2="1000" y2="140" stroke="#cbd5e1" stroke-width="2" stroke-dasharray="6 8"/><text x="18" y="110" font-family="Andika" font-size="${fs}" fill="#c4c9d1" letter-spacing="${ls}">${text}</text>`).replace('xMidYMid meet', 'xMinYMid meet')}</div>`;
  K.grid = (cols, items, h = 'fill', gap = 2.6) => h === 'fill'
    ? `<div style="display:grid;grid-template-columns:repeat(${cols},minmax(0,1fr));grid-auto-rows:1fr;gap:${gap}mm;flex:1;min-height:0">${items.map(it => `<div class="cell" style="padding:1.5mm;gap:2mm;min-height:0;min-width:0;overflow:hidden;flex-direction:column">${it}</div>`).join('')}</div>`
    : `<div style="display:grid;grid-template-columns:repeat(${cols},minmax(0,1fr));gap:${gap}mm">${items.map(it => `<div class="cell" style="height:${h}mm;padding:1.5mm;gap:2mm;min-width:0">${it}</div>`).join('')}</div>`;
  K.timer = () => `<div class="row" style="font-size:11pt;font-weight:700;font-family:Fredoka">${[1, 2, 3].map(k => `<div class="cell" style="height:11mm">Try ${k}: ..... correct <span class="ar-i" style="font-size:9pt">&nbsp;صحيحة في دقيقة</span></div>`).join('')}</div>`;
  K.parentBox = ar => `<div class="parent" style="direction:rtl"><b>ركن الأهل:</b><span>${ar}</span></div>`;
  K.faces = () => `<div class="row">${[[2, 'I can do it!', 'أستطيع وحدي'], [1, 'I need practice', 'أحتاج تدريباً'], [0, 'I need help', 'أحتاج مساعدة']].map(([m, e, a]) => `<div class="cell" style="height:22mm;gap:3mm"><div style="width:14mm;height:14mm">${M.face(m)}</div><span style="font-size:11pt;font-weight:700;font-family:Fredoka;line-height:1.3">${e}<span class="ar" style="font-size:9pt">${a}</span></span></div>`).join('')}</div>`;
  K.render = (pages, out) => renderPDF(pages, out, { css: CSS });
  return K;
}
module.exports = { makeKit, hd, shuffle, pic, M, MT, VC, CC, VOW };
