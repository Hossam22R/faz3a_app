// أدوات الرسم الرياضي: نقاط، إطار العشرة، خط الأعداد، بيت العدد، أشياء للعدّ
const R = '../../arabic-reading-levels/src/';
const { hd, shuffle } = require(R + 'common');
const { pic } = require(R + 'pics');

const WORDS = ['صفر', 'واحد', 'اثنان', 'ثلاثة', 'أربعة', 'خمسة', 'ستّة', 'سبعة', 'ثمانية', 'تسعة', 'عشرة', 'أحد عشر', 'اثنا عشر', 'ثلاثة عشر', 'أربعة عشر', 'خمسة عشر', 'ستّة عشر', 'سبعة عشر', 'ثمانية عشر', 'تسعة عشر', 'عشرون'];
const svg = (vb, inner, cls = 'pic') => `<svg class="${cls}" xmlns="http://www.w3.org/2000/svg" viewBox="${vb}" preserveAspectRatio="xMidYMid meet" style="width:100%;height:100%;display:block">${inner}</svg>`;

// نقاط مثل حجر النرد (١–٦) أو ترتيب عشوائي
const DICE = { 1: [[1, 1]], 2: [[0, 0], [2, 2]], 3: [[0, 0], [1, 1], [2, 2]], 4: [[0, 0], [2, 0], [0, 2], [2, 2]], 5: [[0, 0], [2, 0], [1, 1], [0, 2], [2, 2]], 6: [[0, 0], [0, 1], [0, 2], [2, 0], [2, 1], [2, 2]] };
function dots(n, style = 'dice', seed = 1, fill = '#2563EB') {
  let pts;
  // كلّ النقاط داخل المربّع بهامش ثابت: المربّع من ٢ إلى ٩٨، والنقاط بين ٢٢ و٧٨
  if (style === 'dice' && DICE[n]) pts = DICE[n].map(([x, y]) => [78 - x * 28, 22 + y * 28]);
  else if (style === 'line') pts = Array.from({ length: n }, (_, i) => [n === 1 ? 50 : 84 - (i * 68) / (n - 1), 50]);
  else {
    const cells = shuffle(Array.from({ length: 9 }, (_, i) => i), seed).slice(0, Math.min(n, 9));
    pts = cells.map(c => [78 - (c % 3) * 28, 22 + Math.floor(c / 3) * 28]);
  }
  const r = style === 'line' && n > 5 ? 5.5 : 9;
  return svg('0 0 100 100', `<rect x="2" y="2" width="96" height="96" rx="12" fill="#F2F7FF" stroke="#1E3A8A" stroke-width="2.5"/>${pts.map(([x, y]) => `<circle cx="${x}" cy="${y}" r="${r}" fill="${fill}"/>`).join('')}`);
}

// إطار العشرة: n نقاط ممتلئة، و(empty) دوائر فارغة للرسم
function tenFrame(n, { empty = false, marks = 0 } = {}) {
  let o = `<rect x="2" y="2" width="246" height="100" rx="6" fill="#FFF8EC" stroke="#7C2D12" stroke-width="4"/>`;
  for (let i = 1; i < 5; i++) o += `<line x1="${2 + i * 49.2}" y1="2" x2="${2 + i * 49.2}" y2="102" stroke="#7C2D12" stroke-width="3"/>`;
  o += `<line x1="2" y1="52" x2="248" y2="52" stroke="#7C2D12" stroke-width="3"/>`;
  for (let i = 0; i < 10; i++) {
    const cx = 26.6 + (4 - (i % 5)) * 49.2, cy = 27 + Math.floor(i / 5) * 50; // يُملأ من اليمين
    if (i < n && !empty) o += `<circle cx="${cx}" cy="${cy}" r="16" fill="#E63946" stroke="#9B1C25" stroke-width="2"/>`;
    else if (i < n + marks && !empty) o += `<circle cx="${cx}" cy="${cy}" r="16" fill="#fff" stroke="#111" stroke-width="3" stroke-dasharray="5 4"/>`;
  }
  return svg('0 0 250 104', o);
}
const doubleFrame = n => `<div style="display:flex;flex-direction:column;gap:2mm;width:100%;height:100%"><div style="flex:1">${tenFrame(Math.min(n, 10))}</div><div style="flex:1">${tenFrame(Math.max(0, n - 10))}</div></div>`;

// خط الأعداد (من اليسار إلى اليمين كما في الرياضيات)، مع أعداد مخفية وقفزات
function numberLine(from, to, { hide = [], jumps = [], showAll = true, h = 70 } = {}) {
  const N = to - from, W = 1000, x = v => W - 40 - ((v - from) * (W - 80)) / N; // يبدأ من اليمين
  let o = `<line x1="20" y1="30" x2="${W - 20}" y2="30" stroke="#1E3A8A" stroke-width="5"/><path d="M${W - 20} 30 l-14 -8 v16Z M20 30 l14 -8 v16Z" fill="#1E3A8A"/>`;
  for (let v = from; v <= to; v++) {
    o += `<line x1="${x(v)}" y1="18" x2="${x(v)}" y2="42" stroke="#1E3A8A" stroke-width="3.5"/>`;
    if (hide.includes(v)) o += `<rect x="${x(v) - 17}" y="48" width="34" height="34" rx="5" fill="#fff" stroke="#111" stroke-width="2.5"/>`;
    else if (showAll) o += `<text x="${x(v)}" y="76" text-anchor="middle" font-family="Cairo" font-weight="700" font-size="${N > 12 ? 24 : 30}">${hd(v)}</text>`;
  }
  for (const [a, b] of jumps) {
    const mx = (x(a) + x(b)) / 2, hh = Math.min(28, 10 + Math.abs(x(b) - x(a)) / 6);
    o += `<path d="M${x(a)} 16 Q${mx} ${16 - hh * 1.6} ${x(b)} 16" fill="none" stroke="#F97316" stroke-width="4"/><path d="M${x(b)} 16 l${x(b) > x(a) ? -12 : 12} -6 l${x(b) > x(a) ? 2 : -2} 12Z" fill="#F97316"/>`;
  }
  return `<div style="height:${h}px;width:100%">${svg(`0 ${-36} ${W} 124`, o)}</div>`;
}

// بيت العدد (الكلّ والجزآن)
function bond(whole, a, b) {
  const t = (v, x, y, r) => `<circle cx="${x}" cy="${y}" r="${r}" fill="${r > 36 ? '#FFE08A' : '#CDEBFF'}" stroke="#1E3A8A" stroke-width="4"/>${v === null ? '' : `<text x="${x}" y="${y + 13}" text-anchor="middle" font-family="Cairo" font-weight="800" font-size="40">${hd(v)}</text>`}`;
  return svg('0 0 200 170', `<line x1="100" y1="46" x2="48" y2="122" stroke="#1E3A8A" stroke-width="4"/><line x1="100" y1="46" x2="152" y2="122" stroke="#1E3A8A" stroke-width="4"/>${t(whole, 100, 44, 38)}${t(a, 48, 126, 34)}${t(b, 152, 126, 34)}`);
}

// مجموعة أشياء للعدّ (n صور صغيرة)
const OBJS = ['apple', 'star', 'ball', 'lemon', 'carrot', 'banana', 'drum', 'pomegranate'];
function objects(n, img = 'apple', per = 5, color = true) {
  const one = pic(img, 'pic', color);
  return `<div style="display:grid;grid-template-columns:repeat(${per},1fr);gap:1mm;width:100%;height:100%;align-content:center">${Array.from({ length: n }, () => `<div style="aspect-ratio:1">${one}</div>`).join('')}</div>`;
}

// معادلة عربيّة: تُقرأ من اليمين إلى اليسار بأرقام هندية (رموز < > تنعكس تلقائياً)
const eq = (...parts) => `<span dir="rtl" style="unicode-bidi:isolate;font-weight:800;white-space:nowrap">${parts.map(p => (p === '_' ? '<span style="display:inline-block;width:12mm;height:11mm;border:.5mm solid #111;border-radius:2mm;vertical-align:middle"></span>' : typeof p === 'number' ? hd(p) : p)).join(' ')}</span>`;

function scatter(n, img = 'star', seed = 3) {
  const cells = shuffle(Array.from({ length: 30 }, (_, i) => i), seed).slice(0, n);
  return `<div style="position:relative;width:100%;height:100%">${cells.map(c => `<div style="position:absolute;width:13%;height:16%;right:${2 + (c % 6) * 16 + ((c * 7) % 5)}%;top:${3 + Math.floor(c / 6) * 19 + ((c * 3) % 4)}%">${pic(img, 'pic', true)}</div>`).join('')}</div>`;
}
const face = mood => svg('0 0 100 100', `<circle cx="50" cy="50" r="44" fill="${['#FFD6D6', '#FFF1B8', '#C9F2D0'][mood]}" stroke="#111" stroke-width="5"/><circle cx="35" cy="40" r="6" fill="#111"/><circle cx="65" cy="40" r="6" fill="#111"/>` +
  (mood === 2 ? '<path d="M28 60 Q50 82 72 60" fill="none" stroke="#111" stroke-width="5" stroke-linecap="round"/>' : mood === 1 ? '<path d="M30 66 H70" stroke="#111" stroke-width="5" stroke-linecap="round"/>' : '<path d="M28 72 Q50 52 72 72" fill="none" stroke="#111" stroke-width="5" stroke-linecap="round"/>'));
const ICONS = {
  hand: 'M7 11V6a1.5 1.5 0 0 1 3 0v5M10 10V4.5a1.5 1.5 0 0 1 3 0V10M13 10V5.5a1.5 1.5 0 0 1 3 0V11M16 11V8a1.5 1.5 0 0 1 3 0v6a7 7 0 0 1-7 7h-1a6 6 0 0 1-5-3l-2-4a1.5 1.5 0 0 1 2.5-1.5L7 14',
  eye: 'M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12zM12 9a3 3 0 1 0 0 6 3 3 0 0 0 0-6z',
  pencil: 'M4 20l4-1L19 8l-3-3L5 16l-1 4zM14 7l3 3',
  watch: 'M12 21a8 8 0 1 0 0-16 8 8 0 0 0 0 16zM12 13V9M10 2h4M12 2v3M19 6l1.5-1.5',
  puzzle: 'M8 4h3a2 2 0 1 1 4 0h3v4a2 2 0 1 1 0 4v6h-4a2 2 0 1 0-4 0H6v-4a2 2 0 1 0 0-4V4z',
  bulb: 'M9 18h6M10 21h4M12 3a6 6 0 0 0-4 10.5c1 1 1 2 1 2.5h6c0-.5 0-1.5 1-2.5A6 6 0 0 0 12 3z',
  star: 'M12 3l2.6 5.6 6 .7-4.5 4.1 1.2 6L12 16.5 6.7 19.4l1.2-6L3.4 9.3l6-.7z',
  book: 'M4 5a2 2 0 0 1 2-2h13v16H6a2 2 0 0 0-2 2zM4 19V5M8 7h7M8 11h7',
  heart: 'M12 20s-7-4.5-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.5-7 10-7 10z',
};
const icon = (k, c = '#fff', sz = '100%') => `<svg viewBox="0 0 24 24" style="width:${sz};height:${sz};display:block" fill="none" stroke="${c}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="${ICONS[k]}"/></svg>`;
module.exports = { icon, ICONS, scatter, face, WORDS, dots, tenFrame, doubleFrame, numberLine, bond, objects, OBJS, eq, svg };
