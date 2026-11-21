// أدوات الرسم الرياضي: نقاط، إطار العشرة، خط الأعداد، بيت العدد، أشياء للعدّ
const R = '../../arabic-reading-levels/src/';
const { hd, shuffle } = require(R + 'common');
const { pic } = require(R + 'pics');

const WORDS = ['صفر', 'واحد', 'اثنان', 'ثلاثة', 'أربعة', 'خمسة', 'ستّة', 'سبعة', 'ثمانية', 'تسعة', 'عشرة', 'أحد عشر', 'اثنا عشر', 'ثلاثة عشر', 'أربعة عشر', 'خمسة عشر', 'ستّة عشر', 'سبعة عشر', 'ثمانية عشر', 'تسعة عشر', 'عشرون'];
const svg = (vb, inner, cls = 'pic') => `<svg class="${cls}" xmlns="http://www.w3.org/2000/svg" viewBox="${vb}" preserveAspectRatio="xMidYMid meet" style="width:100%;height:100%;display:block">${inner}</svg>`;

// نقاط مثل حجر النرد (١–٦) أو ترتيب عشوائي
const DICE = { 1: [[1, 1]], 2: [[0, 0], [2, 2]], 3: [[0, 0], [1, 1], [2, 2]], 4: [[0, 0], [2, 0], [0, 2], [2, 2]], 5: [[0, 0], [2, 0], [1, 1], [0, 2], [2, 2]], 6: [[0, 0], [0, 1], [0, 2], [2, 0], [2, 1], [2, 2]] };
function dots(n, style = 'dice', seed = 1, fill = '#111') {
  let pts;
  if (style === 'dice' && DICE[n]) pts = DICE[n].map(([x, y]) => [20 + x * 30, 20 + y * 30]);
  else if (style === 'line') pts = Array.from({ length: n }, (_, i) => [8 + (i * 84) / Math.max(1, n - 1 || 1), 50]).map(([x, y]) => [n === 1 ? 50 : x, y]);
  else {
    const cells = shuffle(Array.from({ length: 16 }, (_, i) => i), seed).slice(0, n);
    pts = cells.map(c => [14 + (c % 4) * 24, 14 + Math.floor(c / 4) * 24]);
  }
  const r = style === 'line' && n > 5 ? 6 : 10;
  return svg('0 0 100 100', `<rect x="2" y="2" width="96" height="96" rx="12" fill="#fff" stroke="#111" stroke-width="2.5"/>${pts.map(([x, y]) => `<circle cx="${x}" cy="${y}" r="${r}" fill="${fill}"/>`).join('')}`);
}

// إطار العشرة: n نقاط ممتلئة، و(empty) دوائر فارغة للرسم
function tenFrame(n, { empty = false, marks = 0 } = {}) {
  let o = `<rect x="2" y="2" width="246" height="100" rx="6" fill="#fff" stroke="#111" stroke-width="4"/>`;
  for (let i = 1; i < 5; i++) o += `<line x1="${2 + i * 49.2}" y1="2" x2="${2 + i * 49.2}" y2="102" stroke="#111" stroke-width="3"/>`;
  o += `<line x1="2" y1="52" x2="248" y2="52" stroke="#111" stroke-width="3"/>`;
  for (let i = 0; i < 10; i++) {
    const cx = 26.6 + (i % 5) * 49.2, cy = 27 + Math.floor(i / 5) * 50;
    if (i < n && !empty) o += `<circle cx="${cx}" cy="${cy}" r="16" fill="#111"/>`;
    else if (i < n + marks && !empty) o += `<circle cx="${cx}" cy="${cy}" r="16" fill="#fff" stroke="#111" stroke-width="3" stroke-dasharray="5 4"/>`;
  }
  return svg('0 0 250 104', o);
}
const doubleFrame = n => `<div style="display:flex;flex-direction:column;gap:2mm;width:100%;height:100%"><div style="flex:1">${tenFrame(Math.min(n, 10))}</div><div style="flex:1">${tenFrame(Math.max(0, n - 10))}</div></div>`;

// خط الأعداد (من اليسار إلى اليمين كما في الرياضيات)، مع أعداد مخفية وقفزات
function numberLine(from, to, { hide = [], jumps = [], showAll = true, h = 70 } = {}) {
  const N = to - from, W = 1000, x = v => 40 + ((v - from) * (W - 80)) / N;
  let o = `<line x1="20" y1="30" x2="${W - 20}" y2="30" stroke="#111" stroke-width="4"/><path d="M${W - 20} 30 l-14 -8 v16Z M20 30 l14 -8 v16Z" fill="#111"/>`;
  for (let v = from; v <= to; v++) {
    o += `<line x1="${x(v)}" y1="18" x2="${x(v)}" y2="42" stroke="#111" stroke-width="3.5"/>`;
    if (hide.includes(v)) o += `<rect x="${x(v) - 17}" y="48" width="34" height="34" rx="5" fill="#fff" stroke="#111" stroke-width="2.5"/>`;
    else if (showAll) o += `<text x="${x(v)}" y="76" text-anchor="middle" font-family="Cairo" font-weight="700" font-size="${N > 12 ? 24 : 30}">${hd(v)}</text>`;
  }
  for (const [a, b] of jumps) {
    const mx = (x(a) + x(b)) / 2, hh = Math.min(28, 10 + Math.abs(x(b) - x(a)) / 6);
    o += `<path d="M${x(a)} 16 Q${mx} ${16 - hh * 1.6} ${x(b)} 16" fill="none" stroke="#111" stroke-width="3"/><path d="M${x(b)} 16 l${b > a ? -12 : 12} -6 l${b > a ? 2 : -2} 12Z" fill="#111"/>`;
  }
  return `<div style="height:${h}px;width:100%" dir="ltr">${svg(`0 ${-36} ${W} 124`, o)}</div>`;
}

// بيت العدد (الكلّ والجزآن)
function bond(whole, a, b) {
  const t = (v, x, y, r) => `<circle cx="${x}" cy="${y}" r="${r}" fill="#fff" stroke="#111" stroke-width="4"/>${v === null ? '' : `<text x="${x}" y="${y + 13}" text-anchor="middle" font-family="Cairo" font-weight="800" font-size="40">${hd(v)}</text>`}`;
  return svg('0 0 200 170', `<line x1="100" y1="46" x2="48" y2="122" stroke="#111" stroke-width="4"/><line x1="100" y1="46" x2="152" y2="122" stroke="#111" stroke-width="4"/>${t(whole, 100, 44, 38)}${t(a, 48, 126, 34)}${t(b, 152, 126, 34)}`);
}

// مجموعة أشياء للعدّ (n صور صغيرة)
const OBJS = ['apple', 'star', 'ball', 'lemon', 'carrot', 'banana', 'drum', 'pomegranate'];
function objects(n, img = 'apple', per = 5) {
  return `<div style="display:grid;grid-template-columns:repeat(${per},1fr);gap:1mm;width:100%;height:100%;align-content:center">${Array.from({ length: n }, () => `<div style="aspect-ratio:1">${pic(img)}</div>`).join('')}</div>`;
}

// معادلة: تُكتب من اليسار إلى اليمين بأرقام هندية
const eq = (...parts) => `<span dir="ltr" style="unicode-bidi:isolate;font-weight:800;white-space:nowrap">${parts.map(p => (p === '_' ? '<span style="display:inline-block;width:12mm;height:11mm;border:.5mm solid #111;border-radius:2mm;vertical-align:middle"></span>' : typeof p === 'number' ? hd(p) : p)).join(' ')}</span>`;

module.exports = { WORDS, dots, tenFrame, doubleFrame, numberLine, bond, objects, OBJS, eq, svg };
