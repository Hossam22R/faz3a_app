// القوالب المشتركة لكتب «أقرأ بثقة»
const fs = require('fs');
const path = require('path');
const ROOT = path.resolve(__dirname, '..');
const fdir = p => path.join(ROOT, 'node_modules/@fontsource', p);
const b64 = f => fs.readFileSync(f).toString('base64');
const face = (fam, file, wt) => `@font-face{font-family:'${fam}';font-weight:${wt};src:url(data:font/woff2;base64,${b64(file)}) format('woff2')}`;
const fontFile = f => path.join(ROOT, 'fonts', f);
const ttf = (fam, file, wt) => `@font-face{font-family:'${fam}';font-weight:${wt};src:url(data:font/ttf;base64,${b64(fontFile(file))}) format('truetype')}`;
// الخطوط المعتمدة من المستخدم: Cairo للعناوين والتعليمات، Amiri Quran للنص المقروء والقرآني
const FONTS = [[400, 'Regular'], [500, 'SemiBold'], [600, 'SemiBold'], [700, 'Bold'], [800, 'ExtraBold'], [900, 'Black']].map(([wt, f]) => ttf('Cairo', `Cairo-${f}.ttf`, wt)).join('') +
  [400, 700].map(wt => ttf('Naskh', 'AmiriQuran-Regular.ttf', wt) + ttf('Quran', 'AmiriQuran-Regular.ttf', wt)).join('');

const HD = '٠١٢٣٤٥٦٧٨٩';
const hd = n => String(n).replace(/\d/g, d => HD[d]);
const H = { fatha: 'َ', damma: 'ُ', kasra: 'ِ', sukun: 'ْ', shadda: 'ّ', an: 'ً', un: 'ٌ', in: 'ٍ' };
const shuffle = (arr, seed = 7) => {
  const a = [...arr];
  let s = seed;
  for (let i = a.length - 1; i > 0; i--) {
    s = (s * 1103515245 + 12345) & 0x7fffffff;
    const j = s % (i + 1);
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
};
// تمييز حرف داخل كلمة مشكولة (الحرف + حركاته)
const DIAC = /[ً-ْٰ]/;
function hl(word, letters) {
  const set = Array.isArray(letters) ? letters : [letters];
  let out = '', i = 0;
  while (i < word.length) {
    let j = i + 1;
    while (j < word.length && DIAC.test(word[j])) j++;
    const chunk = word.slice(i, j);
    out += set.includes(word[i]) ? `<b class="hl">${chunk}</b>` : chunk;
    i = j;
  }
  return out;
}

const CSS = `${FONTS}
@page{size:210mm 297mm;margin:0}
*{box-sizing:border-box}
html,body{margin:0;padding:0;background:#fff;color:#111}
body{font-family:Cairo;direction:rtl}
.page{width:210mm;height:297mm;padding:12.5mm 13mm 16mm;position:relative;overflow:hidden;page-break-after:always;break-after:page;display:flex;flex-direction:column;gap:3.6mm}
.page:last-child{page-break-after:auto;break-after:auto}
.nk{font-family:Naskh;font-weight:400;line-height:normal!important;display:inline-block;margin:-.62em 0 -.04em}
.qr{font-family:Quran;font-weight:400}
.wsl{position:absolute;inset:4.5mm;border:.45mm solid #111;border-radius:3mm;pointer-events:none}
.wsl::after{content:'';position:absolute;inset:3.4mm;border:.25mm solid #111;border-radius:1.6mm}
.wsl .bt,.wsl .bb{position:absolute;left:6mm;right:6mm;height:3.4mm;font-size:5.6pt;line-height:3.4mm;white-space:nowrap;overflow:hidden;text-align:center;color:#333;letter-spacing:.2pt}
.wsl .bt{top:0}.wsl .bb{bottom:0}
.wsl .bl,.wsl .br{position:absolute;top:6mm;bottom:6mm;width:3.4mm;font-size:5.6pt;line-height:3.4mm;writing-mode:vertical-rl;white-space:nowrap;overflow:hidden;text-align:center;color:#333}
.wsl .bl{left:0;transform:rotate(180deg)}.wsl .br{right:0}
.wsl i{position:absolute;width:2.4mm;height:2.4mm;background:#111;transform:rotate(45deg)}
.wmk{position:absolute;left:50%;top:50%;transform:translate(-50%,-50%) rotate(-32deg);font-weight:900;font-size:44pt;color:#000;opacity:.028;white-space:nowrap;pointer-events:none;z-index:0}
.hl{color:#000;font-weight:700;text-decoration:underline;text-decoration-thickness:1.2mm;text-underline-offset:3.4mm;text-decoration-skip-ink:none}
.hdr{display:flex;align-items:center;gap:4mm;border:1mm solid #111;border-radius:6mm;padding:2.6mm 5mm;background:#fff}
.hdr .tag{background:#111;color:#fff;border-radius:4mm;padding:1mm 4mm;font-weight:700;font-size:13pt;white-space:nowrap}
.hdr h1{margin:0;font-size:26pt;font-weight:900;line-height:1.25;flex:1}
.hdr .lv{border:.7mm solid #111;border-radius:50%;width:17mm;height:17mm;display:flex;flex-direction:column;align-items:center;justify-content:center;font-size:8pt;font-weight:700;line-height:1.1}
.hdr .lv b{font-size:17pt;font-weight:900}
.sec{border:.6mm solid #111;border-radius:5mm;padding:3mm 4.5mm 4mm;position:relative}
.sec>.t{display:flex;align-items:center;gap:2.5mm;font-weight:700;font-size:15pt;margin:-.5mm 0 2.5mm;line-height:1.3}
.sec>.t i{font-style:normal;background:#111;color:#fff;width:8.5mm;height:8.5mm;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:12pt;flex:none}
.sec>.t small{font-weight:400;font-size:10.5pt;color:#333}
.grow{flex:1;display:flex;flex-direction:column}
.row{display:flex;gap:3mm;justify-content:space-between;align-items:stretch}
.cell{border:.5mm solid #111;border-radius:3.5mm;display:flex;align-items:center;justify-content:center;flex:1;text-align:center}
.foot{position:absolute;bottom:10mm;left:13mm;right:13mm;display:flex;justify-content:space-between;align-items:center;font-size:8.5pt;color:#444}
.foot .pn{border:.5mm solid #111;border-radius:50%;width:9mm;height:9mm;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:11pt;color:#111}
.parent{border:.6mm dashed #111;border-radius:5mm;padding:2.5mm 4.5mm;font-size:11pt;line-height:1.6;display:flex;gap:3mm;align-items:center}
.parent b{white-space:nowrap}
.nk.hero{font-size:150pt;line-height:1.15}.nk.big{font-size:62pt;line-height:1.3}.nk.mid{font-size:44pt;line-height:1.4}.nk.sm{font-size:30pt;line-height:1.5}.nk.sm2{font-size:36pt;line-height:1.4}
.pic{width:100%;height:100%;display:block}
.trace{color:#b9b9b9}
.lines{background:repeating-linear-gradient(to bottom,transparent 0,transparent 13.4mm,#111 13.4mm,#111 13.8mm);}
table{border-collapse:collapse;width:100%}
td,th{border:.45mm solid #111;text-align:center}
`;

const BAND = Array(14).fill('مؤسسة وصال التعليمية ◆ جميع الحقوق محفوظة ◆').join(' ');
const PROTECT = `<div class="wmk">مؤسسة وصال التعليمية</div><div class="wsl"><div class="bt">${BAND}</div><div class="bb">${BAND}</div><div class="bl">${BAND}</div><div class="br">${BAND}</div>
  <i style="top:.5mm;left:.5mm"></i><i style="top:.5mm;right:.5mm"></i><i style="bottom:.5mm;left:.5mm"></i><i style="bottom:.5mm;right:.5mm"></i></div>`;
function page(inner, { n, series = 'سلسلة أقرأ بثقة', level, foot = true } = {}) {
  return `<section class="page">${PROTECT}${inner}${foot ? `<div class="foot"><span>${series}${level ? ` · المستوى ${hd(level)}` : ''}</span><span class="pn">${hd(n)}</span><span>© مؤسسة وصال التعليمية</span></div>` : ''}</section>`;
}
const header = (title, tag, level) =>
  `<div class="hdr">${tag ? `<span class="tag">${tag}</span>` : ''}<h1 style="font-size:${title.length > 24 ? 19 : title.length > 17 ? 22 : 26}pt">${title}</h1><span class="lv">المستوى<b>${hd(level)}</b></span></div>`;
const sec = (num, title, body, extra = '', note = '') =>
  `<div class="sec ${extra}"><div class="t"><i>${hd(num)}</i><span>${title}</span>${note ? `<small>${note}</small>` : ''}</div>${body}</div>`;

// حرف/كلمة كبيرة تُضبط على حدود الحبر الفعلية (لا على صندوق الخط) فتتوسّط مكانها دائماً
const inkSVG = (t, { stroke = 0, fill = '#111', pad = 0.06, cls = '', font = 'Naskh', weight = 400 } = {}) =>
  `<svg class="ink ${cls}" data-pad="${pad}" data-sw="${stroke}" data-font="${weight} 200px ${font}" viewBox="-100 -100 200 200" width="100%" height="100%" preserveAspectRatio="xMidYMid meet"><text x="0" y="0" text-anchor="middle" direction="rtl" font-family="${font}" font-weight="${weight}" font-size="200" fill="${stroke ? '#fff' : fill}" ${stroke ? `stroke="#111" stroke-width="${stroke}" stroke-linejoin="round" paint-order="stroke"` : ''}>${t}</text></svg>`;
const FIT_JS = `
{ const c = document.createElement('canvas').getContext('2d');
  for (const s of document.querySelectorAll('svg.ink')) {
    const t = s.querySelector('text'); c.font = s.dataset.font || '200px Naskh'; c.direction = 'rtl'; c.textAlign = 'center';
    const m = c.measureText(t.textContent); const sw = +s.dataset.sw / 2;
    const x0 = -m.actualBoundingBoxLeft - sw, x1 = m.actualBoundingBoxRight + sw, y0 = -m.actualBoundingBoxAscent - sw, y1 = m.actualBoundingBoxDescent + sw;
    const p = Math.max(x1 - x0, y1 - y0) * +s.dataset.pad;
    s.setAttribute('viewBox', [x0 - p, y0 - p, x1 - x0 + 2 * p, y1 - y0 + 2 * p].join(' '));
  } }
for (const s of document.querySelectorAll('svg[data-fit]')) {
  const b = s.querySelector('g').getBBox(); const p = 10;
  s.setAttribute('viewBox', [b.x - p, b.y - p, b.width + 2 * p, b.height + 2 * p].join(' '));
}`;

async function renderPDF(pagesHTML, file, { browser, css = '' } = {}) {
  const { chromium } = require('playwright');
  const html = `<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><style>${CSS}${css}</style></head><body>${pagesHTML.join('')}</body></html>`;
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file.replace(/\.pdf$/, '.html'), html);
  const own = !browser;
  browser = browser || (await chromium.launch());
  const p = await browser.newPage();
  await p.setContent(html, { waitUntil: 'load' });
  await p.evaluate(() => document.fonts.ready);
  await p.evaluate(FIT_JS);
  // فحص الفيض: أي عنصر يتجاوز الهامش السفلي (قبل التذييل)
  const over = await p.evaluate(() => [...document.querySelectorAll('.page')].map((pg, i) => {
    const lim = pg.getBoundingClientRect().bottom - 15.5 * 96 / 25.4;
    let mx = 0;
    pg.querySelectorAll(':scope > *:not(.foot):not(.wsl):not(.wmk)').forEach(el => (mx = Math.max(mx, el.getBoundingClientRect().bottom)));
    return mx > lim + 0.5 ? i + 1 : 0;
  }).filter(Boolean));
  if (over.length) console.log('OVERFLOW pages:', over.join(','));
  // فحص أفقي: أي عنصر يخرج عن الإطار الداخلي يميناً أو يساراً
  const side = await p.evaluate(() => [...document.querySelectorAll('.page')].map((pg, i) => {
    const r = pg.getBoundingClientRect(), m = 8.4 * 96 / 25.4;
    for (const el of pg.querySelectorAll('*')) {
      if (el.closest('.wsl') || el.closest('.wmk') || el.closest('.tab')) continue;
      if (el.ownerSVGElement) continue; // ما داخل الرسوم يُقصّ بحدودها
      const b = el.getBoundingClientRect();
      if (b.width && (b.left < r.left + m - 0.5 || b.right > r.right - m + 0.5)) return i + 1;
    }
    return 0;
  }).filter(Boolean));
  if (side.length) console.log('SIDE-OVERFLOW pages:', side.join(','));
  await p.pdf({ path: file, width: '210mm', height: '297mm', printBackground: true, margin: { top: 0, right: 0, bottom: 0, left: 0 } });
  await p.close();
  if (own) await browser.close();
}

module.exports = { inkSVG, CSS, hd, H, hl, shuffle, page, header, sec, renderPDF, ROOT };
