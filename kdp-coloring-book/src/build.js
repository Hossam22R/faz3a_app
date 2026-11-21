// يبني ملفات KDP النهائية: الصفحات الداخلية + الغلاف + صور تسويقية
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');
const { setMode, INK, BG, G, C, E, P, R, L, face } = require('./lib');
const { pageSVG, artOnly } = require('./page');
const animals = require('./animals');
const CFG = require('./config');

const ROOT = path.resolve(__dirname, '..');
const OUT = path.join(ROOT, 'output');
fs.mkdirSync(OUT, { recursive: true });
const fontDir = path.join(ROOT, 'node_modules/@fontsource/fredoka/files');
const fontCSS = [400, 500, 600, 700].map(wt => `@font-face{font-family:Fredoka;font-weight:${wt};src:url(data:font/woff2;base64,${fs.readFileSync(`${fontDir}/fredoka-latin-${wt}-normal.woff2`).toString('base64')}) format('woff2')}`).join('');
const byName = n => animals.find(a => a.name === n);
const svgWrap = (inner, vb = '0 0 850 1100') => `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${vb}" width="100%" height="100%">${inner}</svg>`;
const T = (x, y, txt, size, o = {}) =>
  `<text x="${x}" y="${y}" text-anchor="${o.anchor || 'middle'}" font-family="Fredoka" font-weight="${o.weight || 700}" font-size="${size}" fill="${o.fill || INK}"
  ${o.stroke ? `stroke="${o.stroke}" stroke-width="${o.sw || 6}" stroke-linejoin="round" paint-order="stroke"` : 'stroke="none"'} ${o.ls ? `letter-spacing="${o.ls}"` : ''}>${txt}</text>`;
// يضع رسمة حيوان بحجم مصغّر في مكان آخر
const place = (a, mode, x, y, k, ax = 425, ay = 610) => `<g transform="translate(${x} ${y}) scale(${k}) translate(${-ax} ${-ay})">${artOnly(a, mode)}</g>`;
const ROOTG = inner => `<g fill="none" stroke="${INK}" stroke-width="7" stroke-linejoin="round" stroke-linecap="round">${inner}</g>`;

// ---------------- الصفحات التمهيدية ----------------
function titlePage() {
  setMode('line');
  return svgWrap(ROOTG(
    `<rect x="60" y="60" width="730" height="980" rx="40" stroke-width="8"/>` +
    T(425, 230, CFG.titleLine1, 84, { fill: '#fff', stroke: INK, sw: 6, ls: 3 }) + T(425, 330, CFG.titleLine2, 84, { fill: '#fff', stroke: INK, sw: 6, ls: 3 }) +
    T(425, 400, CFG.subtitle, 36, { weight: 600 }) +
    place(byName('BUNNY'), 'line', 235, 690, 0.55) + place(byName('LION'), 'line', 425, 660, 0.62) + place(byName('PANDA'), 'line', 615, 690, 0.55) +
    BG.star(140, 520, 20) + BG.star(710, 520, 20) + BG.heart(425, 470, 1) +
    T(425, 960, CFG.author, 30, { weight: 600 })));
}
function copyrightPage() {
  const lines = CFG.copyright;
  return svgWrap(lines.map((l, i) => T(425, 760 + i * 34, l, 20, { weight: 400 })).join(''));
}
function belongsPage() {
  setMode('line');
  return svgWrap(ROOTG(
    `<rect x="60" y="60" width="730" height="980" rx="40" stroke-width="8"/>` +
    `<rect x="85" y="85" width="680" height="930" rx="28" stroke-width="4" stroke-dasharray="2 16"/>` +
    T(425, 250, 'THIS BOOK', 96, { fill: '#fff', stroke: INK, sw: 6, ls: 4 }) + T(425, 360, 'BELONGS TO', 96, { fill: '#fff', stroke: INK, sw: 6, ls: 4 }) +
    L('M170 520 H680', 6) + place(byName('PUPPY'), 'line', 290, 780, 0.5) + place(byName('KITTY'), 'line', 560, 780, 0.5) +
    BG.star(140, 160, 22) + BG.star(710, 160, 22) + BG.heart(425, 440, 1.1) + BG.sparkle(130, 520, 16) + BG.sparkle(720, 520, 16)));
}
function testColorsPage() {
  setMode('line');
  let shapes = '';
  for (let r = 0; r < 5; r++)
    for (let c = 0; c < 4; c++) {
      const x = 200 + c * 150, y = 400 + r * 130, k = (r + c) % 4;
      shapes += k === 0 ? C(x, y, 48) : k === 1 ? BG.heart(x, y + 20, 2) : k === 2 ? BG.star(x, y, 56, '#fff') : R(x - 46, y - 46, 92, 92, 22);
    }
  return svgWrap(ROOTG(`<rect x="60" y="60" width="730" height="980" rx="40" stroke-width="8"/>` +
    T(425, 200, 'TEST YOUR COLORS', 70, { fill: '#fff', stroke: INK, sw: 6, ls: 3 }) + T(425, 265, 'Try your crayons and markers here!', 30, { weight: 400 }) + shapes));
}
function blankBack() {
  return svgWrap(T(425, 1040, 'This page is left blank so colors don’t bleed through.', 14, { weight: 400, fill: '#9a9a9a' }));
}
function certificatePage() {
  setMode('line');
  return svgWrap(ROOTG(
    `<rect x="60" y="60" width="730" height="980" rx="40" stroke-width="8"/><rect x="85" y="85" width="680" height="930" rx="28" stroke-width="4"/>` +
    BG.star(425, 250, 90, '#fff') + T(425, 400, 'GREAT JOB!', 104, { fill: '#fff', stroke: INK, sw: 7, ls: 4 }) +
    T(425, 470, 'This certificate is proudly given to', 32, { weight: 400 }) + L('M170 570 H680', 6) +
    T(425, 640, 'for coloring all the happy animals!', 32, { weight: 400 }) +
    L('M170 760 H400 M450 760 H680', 5) + T(285, 795, 'Date', 24, { weight: 600 }) + T(565, 795, 'Signature', 24, { weight: 600 }) +
    place(byName('CHICK'), 'line', 425, 900, 0.36) +
    BG.star(150, 180, 22) + BG.star(700, 180, 22) + BG.sparkle(170, 900, 18) + BG.sparkle(680, 900, 18) + BG.heart(220, 300, 1) + BG.heart(630, 300, 1)));
}

// ---------------- الغلاف ----------------
function coverSVG(pages) {
  setMode('color');
  const spine = +(pages * CFG.paperInPerPage).toFixed(4);
  const W = +(0.125 * 2 + 8.5 * 2 + spine).toFixed(4), H = 11.25;
  const u = 100, Wu = W * u, Hu = H * u;
  const fx = (0.125 + 8.5 + spine) * u; // بداية الغلاف الأمامي
  const fcx = fx + 425; // مركز الأمامي
  const bcx = 12.5 + 425;
  // أشعة الشمس الخلفية
  let rays = '';
  for (let i = 0; i < 24; i++) {
    const a1 = (i / 24) * Math.PI * 2, a2 = ((i + 0.5) / 24) * Math.PI * 2, rr = 1400;
    rays += `<path d="M${fcx} 640 L${fcx + rr * Math.cos(a1)} ${640 + rr * Math.sin(a1)} L${fcx + rr * Math.cos(a2)} ${640 + rr * Math.sin(a2)}Z" fill="#ffffff" opacity="0.35"/>`;
  }
  const colors = ['#ff6b6b', '#ffa94d', '#ffd23f', '#51cf66', '#4dabf7', '#9775fa', '#f783ac'];
  const rainbowText = (txt, x, y, size, ls = 4) => {
    // أحرف ملونة متناوبة
    const spans = [...txt].map((ch, i) => `<tspan fill="${ch === ' ' ? 'none' : colors[i % colors.length]}">${ch}</tspan>`).join('');
    return `<text x="${x}" y="${y}" text-anchor="middle" font-family="Fredoka" font-weight="700" font-size="${size}" letter-spacing="${ls}"
      stroke="#2b2d42" stroke-width="16" stroke-linejoin="round" paint-order="stroke">${spans}</text>`;
  };
  const front = `
  <g clip-path="url(#frontclip)">
   <rect x="${fx}" y="0" width="${Wu - fx}" height="${Hu}" fill="#8fd3ff"/>
   ${rays}
  </g>
  ${ROOTG(`<g transform="translate(${fx - 0} 0)">` +
    BG.cloud(120, 470, 0.9) + BG.cloud(740, 430, 0.8) + BG.star(90, 600, 18) + BG.star(780, 590, 20) + BG.sparkle(170, 650, 14) + BG.sparkle(700, 680, 14) +
    BG.hills(915, '#a8e6a1', '#69db7c') + `</g>`)}
  ${ROOTG(
    place(byName('GIRAFFE'), 'color', fx + 115, 790, 0.56, 425, 640) +
    place(byName('ELEPHANT'), 'color', fx + 715, 820, 0.5) +
    place(byName('UNICORN'), 'color', fx + 255, 900, 0.46, 425, 640) +
    place(byName('PANDA'), 'color', fx + 595, 905, 0.44) +
    place(byName('LION'), 'color', fcx, 815, 0.6) +
    place(byName('BUNNY'), 'color', fx + 110, 1010, 0.34) + place(byName('PUPPY'), 'color', fx + 745, 1010, 0.34, 445, 620) +
    place(byName('CHICK'), 'color', fcx - 150, 1035, 0.28) + place(byName('FROG'), 'color', fcx + 150, 1035, 0.3, 420, 640))}
  ${rainbowText('HAPPY ANIMALS', fcx, 205, 94, 2)}
  <g transform="translate(${fcx} 290)">
    <path d="M-330 -42 L330 -42 L300 0 L330 42 L-330 42 L-300 0Z" fill="#ff6b6b" stroke="#2b2d42" stroke-width="7" stroke-linejoin="round"/>
    <text x="0" y="22" text-anchor="middle" font-family="Fredoka" font-weight="700" font-size="60" fill="#fff" letter-spacing="6">COLORING BOOK</text>
  </g>
  ${T(fcx, 380, CFG.coverSubtitle, 38, { fill: '#ffffff', stroke: '#2b2d42', sw: 9, weight: 700 })}
  <g transform="translate(${fx + 705} 520) rotate(12)">
    <circle r="78" fill="#ffd23f" stroke="#2b2d42" stroke-width="7"/>
    <text y="-8" text-anchor="middle" font-family="Fredoka" font-weight="700" font-size="60" fill="#2b2d42">30</text>
    <text y="28" text-anchor="middle" font-family="Fredoka" font-weight="600" font-size="18" fill="#2b2d42">CUTE ANIMALS</text>
  </g>
  <g transform="translate(${fx + 140} 520) rotate(-10)">
    <circle r="70" fill="#ff8fab" stroke="#2b2d42" stroke-width="7"/>
    <text y="-6" text-anchor="middle" font-family="Fredoka" font-weight="600" font-size="24" fill="#fff">AGES</text>
    <text y="34" text-anchor="middle" font-family="Fredoka" font-weight="700" font-size="46" fill="#fff">3-8</text>
  </g>`;

  // الغلاف الخلفي
  const thumbs = ['OWL', 'UNICORN', 'WHALE', 'DINO', 'FOX', 'OCTOPUS'];
  let grid = '';
  thumbs.forEach((n, i) => {
    const col = i % 3, row = Math.floor(i / 3);
    const x = 115 + col * 245, y = 430 + row * 300, rot = [-4, 3, -2, 3, -3, 4][i];
    const inner = pageSVG(byName(n), 'line').replace('width="100%" height="100%"', 'x="0" y="0" width="850" height="1100"');
    grid += `<g transform="translate(${x} ${y}) rotate(${rot} 105 136)">
      <rect x="-6" y="-6" width="222" height="284" rx="14" fill="#fff" stroke="#2b2d42" stroke-width="4"/>
      <svg x="0" y="0" width="210" height="272" viewBox="0 0 850 1100">${inner}</svg></g>`;
  });
  const back = `
  <rect x="0" y="0" width="${fx}" height="${Hu}" fill="#fff4d6"/>
  ${ROOTG(BG.hills(985, '#a8e6a1', '#69db7c') + BG.star(110, 300, 18, '#ffd23f') + BG.star(770, 270, 16, '#ffd23f') + BG.sparkle(60, 330, 12) + BG.heart(800, 330, 0.9))}
  ${T(bcx, 150, 'Hours of Happy Coloring!', 50, { fill: '#ff6b6b', stroke: '#2b2d42', sw: 10 })}
  ${CFG.backBlurb.map((l, i) => T(bcx, 215 + i * 38, l, 27, { weight: 500, fill: '#2b2d42' })).join('')}
  ${grid}
  `;
  const features = `${ROOTG(BG.star(85, 1032, 14, '#ffd23f'))}${T(108, 1043, CFG.backBullets.join('   ★   '), 22, { anchor: 'start', weight: 600, fill: '#2b2d42' })}`;

  return {
    W, H, spine,
    svg: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${Wu} ${Hu}" width="${W}in" height="${H}in">
    <defs><clipPath id="frontclip"><rect x="${fx}" y="0" width="${Wu - fx}" height="${Hu}"/></clipPath></defs>
    ${back}${features}
    <rect x="${fx - spine * u}" y="0" width="${spine * u}" height="${Hu}" fill="#ffd23f"/>
    ${front}</svg>`,
    fx, u,
  };
}

// ---------------- التجميع ----------------
async function toPDF(browser, html, file, wIn, hIn) {
  const p = await browser.newPage();
  await p.setContent(html, { waitUntil: 'load' });
  await p.evaluate(() => document.fonts.ready);
  await p.pdf({ path: file, width: `${wIn}in`, height: `${hIn}in`, printBackground: true, margin: { top: 0, right: 0, bottom: 0, left: 0 }, preferCSSPageSize: false });
  await p.close();
}
const doc = (pagesHTML, wIn, hIn) => `<!doctype html><html><head><meta charset="utf-8"><style>${fontCSS}
@page{size:${wIn}in ${hIn}in;margin:0}html,body{margin:0;padding:0}
.pg{width:${wIn}in;height:${hIn}in;overflow:hidden;page-break-after:always;break-after:page;position:relative}
.pg:last-child{page-break-after:auto;break-after:auto}.pg>svg{display:block}</style></head><body>${pagesHTML}</body></html>`;

(async () => {
  const pages = [titlePage(), copyrightPage(), belongsPage(), blankBack(), testColorsPage(), blankBack()];
  for (const a of animals) pages.push(pageSVG(a, 'line'), blankBack());
  pages.push(certificatePage(), blankBack());
  if (pages.length % 2) pages.push(blankBack());
  const html = doc(pages.map(s => `<div class="pg">${s}</div>`).join(''), 8.5, 11);
  const browser = await chromium.launch();
  await toPDF(browser, html, path.join(OUT, 'interior.pdf'), 8.5, 11);

  const cv = coverSVG(pages.length);
  await toPDF(browser, doc(`<div class="pg">${cv.svg}</div>`, cv.W, cv.H), path.join(OUT, 'cover.pdf'), cv.W, cv.H);

  // صور تسويقية: الغلاف الأمامي + معاينة الصفحات الملونة
  const p = await browser.newPage({ viewport: { width: 1275, height: 1650 } });
  const frontOnly = cv.svg.replace(/viewBox="[^"]+" width="[^"]+" height="[^"]+"/, `viewBox="${cv.fx} 12.5 850 1100" width="1275" height="1650"`);
  await p.setContent(`<html><head><style>${fontCSS}body{margin:0}</style></head><body>${frontOnly}</body></html>`);
  await p.evaluate(() => document.fonts.ready);
  await p.screenshot({ path: path.join(OUT, 'cover-front.png') });
  await p.setViewportSize({ width: 2400, height: 1000 });
  const full = cv.svg.replace(/width="[^"]+in" height="[^"]+in"/, `width="2400" height="${Math.round((2400 * cv.H) / cv.W)}"`);
  await p.setContent(`<html><head><style>${fontCSS}body{margin:0}</style></head><body>${full}</body></html>`);
  await p.evaluate(() => document.fonts.ready);
  await p.screenshot({ path: path.join(OUT, 'cover-full-preview.png'), fullPage: true });
  await browser.close();
  console.log(JSON.stringify({ interiorPages: pages.length, coverWidthIn: cv.W, coverHeightIn: cv.H, spineIn: cv.spine }));
})();
