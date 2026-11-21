// أغلفة «أقرأ بثقة» — هوية مطبعة وصال: فن رقمي غني بالتدرّجات + لوحة نص داكنة
// المسار: فن SVG ← صورة PNG بدقة ~355dpi ← تركيب نصوص Cairo حقيقية ← PDF بمقاس 216×303 مم
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');
const { CSS, hd, ROOT } = require('./common');
const KDP = '../../kdp-coloring-book/src/';
const { setMode, INK } = require(KDP + 'lib');
const animals = require(KDP + 'animals');
const byName = nm => animals.find(a => a.name === nm);

const W = 2160, Hh = 3030; // وحدة = 0.1 مم
const LEVELS = [
  {
    n: 1, thumbs: [30, 32, 116], blurb: 'يتعلّم طفلك في هذا الكتاب الحروف العربيّة الثمانية والعشرين وقراءتها بالفتحة والضمّة والكسرة، بأسلوب متدرّج ممتع يجمع القراءة والكتابة والتلوين وكلمات القرآن الكريم.', tiles: ['٢٨ درساً للحروف', '٣ صفحات لكلّ حرف', 'الفاتحة وكلمات قرآنيّة', 'إملاء بعد كلّ عائلة', 'تخطيط وتلوين', 'دمج وتقطيع', 'اختبار قبلي وبعدي', 'لوحة نجاح وشهادة'], pages: 120, name: 'المستوى الأول', sub: 'أتعرّف الحروف وأقرؤها بالحركات القصيرة', sky: ['#0d2f4f', '#1f6f8b', '#ff9a4d', '#ffd98a'], sun: '#fff2c2',
    accent: '#ff8a1f', panel: '#10263a', glyphs: [['أ', 680, 820, 280], ['بَ', 1080, 700, 320], ['تُ', 1480, 820, 280], ['ثِ', 820, 1130, 190], ['نَ', 1340, 1130, 190]],
    land: 'ziggurat', hero: 'LION', heroAt: [1080, 1530, 0.95],
  },
  {
    n: 2, thumbs: [9, 13, 11], blurb: 'ينتقل طفلك من الحرف إلى الكلمة والجملة: المدود والسكون والتنوين والشدّة والتاء المربوطة واللام القمريّة والشمسيّة، مع سورة قصيرة في كلّ وحدة.', tiles: ['١٢ وحدة متدرّجة', '١٢ سورة قصيرة', 'إملاء لكلّ وحدة', 'تخطيط وخطّ', 'قراءات قصصيّة', 'تلوين وبطاقات للقصّ', 'قياس الطلاقة', 'لوحة نجاح وشهادة'], pages: 104, name: 'المستوى الثاني', sub: 'أقرأ المدود والسكون والتنوين والشدّة', sky: ['#062f33', '#0f6f6a', '#36c19a', '#f3e9a6'], sun: '#fffbe0',
    accent: '#2fe0a0', panel: '#0b2a26', glyphs: [['بَا', 660, 820, 240], ['بُو', 1080, 700, 280], ['بِي', 1500, 820, 240], ['دُبٌّ', 640, 1120, 170], ['شَمْسٌ', 1520, 1120, 160]],
    land: 'malwiya', hero: 'ELEPHANT', heroAt: [1080, 1540, 0.82],
  },
  {
    n: 3, thumbs: [27, 26, 28], blurb: 'يقرأ طفلك الجمل والنصوص القصيرة بطلاقة ويفهمها: عشرون نصّاً من بيئته وقيمه، وعشر سور قصيرة، مع أسئلة فهم وإملاء وخطّ وتلوين.', tiles: ['٢٠ نصّاً مشكولاً', '١٠ سور قصيرة', 'أسئلة فهم متدرّجة', 'إملاء الجمل', 'خطّ ونسخ', 'تلوين وقاموس مصوّر', 'قياس الطلاقة', 'لوحة نجاح وشهادة'], pages: 96, name: 'المستوى الثالث', sub: 'أقرأ الجمل والنصوص بطلاقة وفهم', sky: ['#120f3d', '#3b2a8f', '#9b5de5', '#ffc2d9'], sun: '#fff0f7',
    accent: '#c08cff', panel: '#17123a', glyphs: [['أَقْرَأُ', 1500, 900, 200], ['قِصَّةً', 1080, 720, 230], ['جَمِيلَةً', 660, 900, 200]],
    land: 'taq', hero: 'OWL', heroAt: [1080, 1520, 0.85], night: true,
  },
  {
    n: 4, thumbs: [8, 12, 13], blurb: 'يتقن طفلك الكتابة الصحيحة: الهمزات بأنواعها، والتاء المربوطة والمفتوحة، والألف الليّنة، والحروف المتقاربة، ويقرأ نصوصاً أطول بطلاقة وفهم.', tiles: ['١٠ دروس إملائيّة', 'قاعدة وأمثلة مصنّفة', '١٠ نصوص للطلاقة', '١٠ سور من جزء عمّ', 'إملاء لكلّ درس', 'أختار الكتابة الصحيحة', 'مقياس السرعة', 'لوحة نجاح وشهادة'],
    pages: 92, name: 'المستوى الرابع', sub: 'أقرأ وأكتب بلا أخطاء', sky: ['#3b0a1e', '#9c2a4a', '#ff8a5c', '#ffe0a3'], sun: '#fff3d6',
    accent: '#ff5d73', panel: '#2a0d18', glyphs: [['ء', 1080, 700, 300], ['أ', 680, 820, 260], ['ؤ', 1480, 820, 260], ['ئـ', 820, 1130, 200], ['ة', 1340, 1130, 200]],
    land: 'ishtar', hero: 'GIRAFFE', heroAt: [1120, 1500, 0.92],
  },
];

const rnd = (() => { let s = 99; return () => ((s = (s * 16807) % 2147483647) / 2147483647); })();

function palmSil(x, y, s, flip, rim) {
  const leaves = [[-210, -40], [-150, -150], [-30, -190], [90, -150], [200, -60], [230, 40], [-230, 50]];
  let o = `<path d="M-14 0 Q-6 -260 40 -520 L64 -514 Q24 -260 18 0Z" fill="url(#trunk)" stroke="${rim}" stroke-width="3" stroke-opacity=".6"/>`;
  for (let i = 1; i < 12; i++) o += `<path d="M${-10 + i * 4} ${-i * 44} l26 6" stroke="#000" stroke-opacity=".35" stroke-width="5"/>`;
  for (const [lx, ly] of leaves)
    o += `<path d="M52 -520 Q${52 + lx * 0.45} ${-640 + ly * 0.6} ${52 + lx} ${-500 + ly * 0.5} Q${52 + lx * 0.5} ${-560 + ly * 0.45} 52 -520Z" fill="url(#leaf)" stroke="${rim}" stroke-width="4" stroke-opacity=".7"/>`;
  o += `<circle cx="40" cy="-505" r="20" fill="#5a3216"/><circle cx="66" cy="-498" r="20" fill="#6b3d1b"/>`;
  return `<g transform="translate(${x} ${y}) scale(${flip ? -s : s} ${s})">${o}</g>`;
}

function landmark(kind, rim, cx = 1080, base = 1700) {
  const st = `stroke="${rim}" stroke-width="5" stroke-linejoin="round"`;
  if (kind === 'ziggurat') {
    let o = '';
    [[760, 170], [560, 150], [360, 130]].forEach(([w, h], i) => {
      const y = base - 170 - [0, 170, 320][i];
      o += `<path d="M${cx - w / 2} ${y + h} L${cx - w / 2 + 30} ${y} L${cx + w / 2 - 30} ${y} L${cx + w / 2} ${y + h}Z" fill="url(#stone)" ${st}/>`;
      for (let k = 1; k < 4; k++) o += `<path d="M${cx - w / 2 + 10} ${y + (h * k) / 4} H${cx + w / 2 - 10}" stroke="#000" stroke-opacity=".18" stroke-width="4"/>`;
    });
    o += `<path d="M${cx - 50} ${base} L${cx - 30} ${base - 450} L${cx + 30} ${base - 450} L${cx + 50} ${base}Z" fill="#c9965c" ${st}/>`;
    for (let k = 0; k < 14; k++) o += `<path d="M${cx - 48 + k * 1.4} ${base - k * 32} H${cx + 48 - k * 1.4}" stroke="#7a5230" stroke-width="4"/>`;
    return o;
  }
  if (kind === 'malwiya') {
    const top = base - 820;
    let o = `<rect x="${cx - 300}" y="${base - 70}" width="600" height="70" fill="url(#stone)" ${st}/>`;
    o += `<path d="M${cx - 230} ${base - 70} L${cx - 70} ${top} L${cx + 70} ${top} L${cx + 230} ${base - 70}Z" fill="url(#stone)" ${st}/>`;
    for (let k = 0; k < 7; k++) {
      const y1 = base - 70 - k * 110, y2 = y1 - 110;
      const wAt = y => 70 + ((y - top) / (base - 70 - top)) * 160;
      o += `<path d="M${cx - wAt(y1)} ${y1} L${cx + wAt(y2)} ${y2 + 30}" stroke="#6e4a2a" stroke-width="10" stroke-linecap="round"/>`;
    }
    o += `<rect x="${cx - 60}" y="${top - 90}" width="120" height="90" rx="10" fill="url(#stone)" ${st}/><path d="M${cx - 34} ${top} V${top - 60} Q${cx} ${top - 100} ${cx + 34} ${top - 60} V${top}Z" fill="#3b2412"/>`;
    return o;
  }
  if (kind === 'shanasheel') {
    // بيوت الشناشيل البصريّة: شرفات خشبيّة بارزة بمشبّكات
    let o = '';
    [[cx - 620, 360, 560], [cx - 230, 460, 680], [cx + 260, 380, 600]].forEach(([x, w, h], i) => {
      o += `<rect x="${x}" y="${base - h}" width="${w}" height="${h}" fill="url(#stone)" ${st}/>`;
      o += `<rect x="${x - 12}" y="${base - h - 22}" width="${w + 24}" height="26" fill="#7a4a22" ${st}/>`;
      const ow = w * 0.7, ox = x + (w - ow) / 2, oy = base - h + 70, oh = h * 0.42;
      o += `<rect x="${ox - 18}" y="${oy}" width="${ow + 36}" height="${oh}" rx="6" fill="#8a5a2b" ${st}/>`;
      for (let k = 0; k < 6; k++) o += `<rect x="${ox + k * (ow / 6) + 6}" y="${oy + 16}" width="${ow / 6 - 12}" height="${oh - 50}" fill="#2a1608" stroke="#c98b5a" stroke-width="3"/>`;
      for (let k = 0; k < 6; k++) for (let r = 1; r < 5; r++) o += `<path d="M${ox + k * (ow / 6) + 6} ${oy + 16 + r * (oh - 50) / 5} h${ow / 6 - 12}" stroke="#c98b5a" stroke-width="2"/>`;
      o += `<path d="M${ox - 18} ${oy + oh} l26 40 h${ow - 16} l26 -40Z" fill="#6b4220" ${st}/>`;
      o += `<path d="M${x + w / 2 - 50} ${base} V${base - 150} Q${x + w / 2} ${base - 210} ${x + w / 2 + 50} ${base - 150} V${base}Z" fill="#5a3216" stroke="${rim}" stroke-width="5"/>`;
    });
    return o;
  }
  if (kind === 'ishtar') {
    // بوّابة عشتار: برجان مسنّنان وقوس، آجرّ أزرق مزجّج وحيوانات ذهبيّة
    let o = '';
    const tower = (x, w, h) => {
      let t = `<rect x="${x}" y="${base - h}" width="${w}" height="${h}" fill="url(#glaze)" ${st}/>`;
      for (let k = 0; k < w / 40; k++) t += `<path d="M${x + k * 40 + 4} ${base - h} v-30 h28 v30" fill="url(#glaze)" ${st}/>`;
      for (let r = 1; r < h / 46; r++) t += `<path d="M${x + 6} ${base - h + r * 46} H${x + w - 6}" stroke="#0d2350" stroke-opacity=".35" stroke-width="3"/>`;
      return t;
    };
    o += tower(cx - 520, 300, 640) + tower(cx + 220, 300, 640) + tower(cx - 240, 480, 720);
    o += `<path d="M${cx - 130} ${base} V${base - 330} Q${cx} ${base - 470} ${cx + 130} ${base - 330} V${base}Z" fill="#2a1608" stroke="#ffd54a" stroke-width="10"/>`;
    for (const [x, y] of [[cx - 430, base - 470], [cx - 430, base - 300], [cx + 310, base - 470], [cx + 310, base - 300], [cx - 150, base - 600], [cx + 40, base - 600]])
      o += `<g transform="translate(${x} ${y})"><path d="M0 30 Q10 0 40 4 Q70 0 86 18 L100 8 L96 30 Q80 44 50 42 L46 62 L38 62 L36 44 Q20 44 12 62 L4 62 L8 42Z" fill="#ffd54a" stroke="#7a5200" stroke-width="3"/></g>`;
    o += `<path d="M${cx - 540} ${base - 150} H${cx + 540}" stroke="#ffd54a" stroke-width="8"/><path d="M${cx - 540} ${base - 560} H${cx - 220} M${cx + 220} ${base - 560} H${cx + 540}" stroke="#ffd54a" stroke-width="6"/>`;
    return o;
  }
  // طاق كسرى
  let o = `<rect x="${cx - 700}" y="${base - 420}" width="440" height="420" fill="url(#stone)" ${st}/>`;
  for (let r = 0; r < 3; r++) for (let c = 0; c < 4; c++) {
    const x = cx - 670 + c * 104, y = base - 390 + r * 130;
    o += `<path d="M${x} ${y + 100} V${y + 40} Q${x + 34} ${y - 6} ${x + 68} ${y + 40} V${y + 100}Z" fill="#3b2412" fill-opacity=".75"/>`;
  }
  o += `<path d="M${cx - 300} ${base} V${base - 300} Q${cx - 300} ${base - 820} ${cx} ${base - 860} Q${cx + 300} ${base - 820} ${cx + 300} ${base - 300} V${base}Z" fill="url(#stone)" ${st}/>`;
  o += `<path d="M${cx - 190} ${base} V${base - 280} Q${cx - 190} ${base - 680} ${cx} ${base - 710} Q${cx + 190} ${base - 680} ${cx + 190} ${base - 280} V${base}Z" fill="#2a1a10" fill-opacity=".85"/>`;
  for (let k = 0; k < 12; k++) o += `<path d="M${cx - 300} ${base - 40 - k * 60} h110 M${cx + 190} ${base - 40 - k * 60} h110" stroke="#000" stroke-opacity=".15" stroke-width="4"/>`;
  return o;
}

function art(L, back = false) {
  const [s0, s1, s2, s3] = L.sky;
  const rim = L.accent;
  let stars = '';
  for (let i = 0; i < 90; i++) stars += `<circle cx="${rnd() * W}" cy="${rnd() * 1500}" r="${2 + rnd() * 5}" fill="#fff" opacity="${0.15 + rnd() * 0.5}"/>`;
  let rays = '';
  for (let i = 0; i < 18; i++) {
    const a1 = (i / 18) * Math.PI * 2, a2 = a1 + 0.08;
    rays += `<path d="M1080 1350 L${1080 + 2600 * Math.cos(a1)} ${1350 + 2600 * Math.sin(a1)} L${1080 + 2600 * Math.cos(a2)} ${1350 + 2600 * Math.sin(a2)}Z" fill="#fff" opacity=".06"/>`;
  }
  const glyphs = L.glyphs.map(([t, x, y, sz]) =>
    `<text x="${x}" y="${y}" text-anchor="middle" font-family="Naskh" font-weight="700" font-size="${sz}" fill="#000" opacity=".25" transform="translate(10 16)">${t}</text>
     <text x="${x}" y="${y}" text-anchor="middle" font-family="Naskh" font-weight="700" font-size="${sz}" fill="url(#gl)" stroke="#fff" stroke-width="5" filter="url(#glow)">${t}</text>`).join('');
  setMode('color');
  const a = byName(L.hero);
  const [hx, hy, hs] = L.heroAt;
  const hero = `<g transform="translate(${hx} ${hy}) scale(${hs}) translate(-425 -610)"><g fill="none" stroke="${INK}" stroke-width="7" stroke-linejoin="round" stroke-linecap="round">${a.main()}</g></g>`;
  const moon = L.night ? `<circle cx="1640" cy="330" r="110" fill="#fff6d8"/><circle cx="1690" cy="300" r="100" fill="${s0}"/>` : '';
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${W} ${Hh}" width="100%" height="100%" preserveAspectRatio="none">
  <defs>
    <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${s0}"/><stop offset=".3" stop-color="${s1}"/><stop offset=".48" stop-color="${s2}"/><stop offset=".6" stop-color="${s3}"/></linearGradient>
    <radialGradient id="sun" cx="1080" cy="1350" r="900" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="${L.sun}"/><stop offset=".25" stop-color="${L.sun}" stop-opacity=".85"/><stop offset="1" stop-color="${L.sun}" stop-opacity="0"/></radialGradient>
    <linearGradient id="glaze" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#4f8ff0"/><stop offset=".6" stop-color="#2156b8"/><stop offset="1" stop-color="#132f72"/></linearGradient>
    <linearGradient id="stone" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#e9c38a"/><stop offset=".55" stop-color="#b9824b"/><stop offset="1" stop-color="#7a4f2a"/></linearGradient>
    <linearGradient id="trunk" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#3a2210"/><stop offset="1" stop-color="#7a4a22"/></linearGradient>
    <linearGradient id="leaf" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#3fae5a"/><stop offset="1" stop-color="#0f4a2a"/></linearGradient>
    <linearGradient id="gl" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fffbe6"/><stop offset=".5" stop-color="#ffd54a"/><stop offset="1" stop-color="${L.accent}"/></linearGradient>
    <linearGradient id="ground" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#5fbf6a"/><stop offset="1" stop-color="#1d5a34"/></linearGradient>
    <linearGradient id="river" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#bfeaff"/><stop offset="1" stop-color="#2b7fb8"/></linearGradient>
    <filter id="glow" x="-30%" y="-30%" width="160%" height="160%"><feGaussianBlur stdDeviation="14" result="b"/><feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge></filter>
    <filter id="haze"><feGaussianBlur stdDeviation="30"/></filter>
  </defs>
  <rect width="${W}" height="${Hh}" fill="url(#sky)"/>
  ${stars}${moon}
  <circle cx="1080" cy="1350" r="900" fill="url(#sun)"/>${rays}
  <path d="M0 1560 Q300 1420 640 1520 T1300 1480 T2160 1500 V1900 H0Z" fill="${s1}" opacity=".55" filter="url(#haze)"/>
  <g>${landmark(L.land, rim)}</g>
  <path d="M0 1640 Q540 1580 1080 1650 T2160 1620 V2000 H0Z" fill="url(#river)"/>
  ${[1680, 1720, 1760].map((y, i) => `<path d="M${200 + i * 140} ${y} h220 M${1100 + i * 90} ${y + 10} h260" stroke="#fff" stroke-width="7" stroke-linecap="round" opacity=".6"/>`).join('')}
  <path d="M0 1760 Q520 1680 1080 1760 T2160 1740 V3030 H0Z" fill="url(#ground)"/>
  ${palmSil(200, 1830, 1.25, false, rim)}${palmSil(1960, 1830, 1.25, true, rim)}${palmSil(420, 1790, 0.8, false, rim)}${palmSil(1760, 1790, 0.8, true, rim)}
  ${back ? '' : glyphs}
  ${back ? '' : hero}
  <rect width="${W}" height="${Hh}" fill="url(#sky)" opacity="0"/>
  </svg>`;
}

// اللوحة الداكنة والنصوص (متّجهة)
function overlay(L) {
  const oct = (cx, cy, w, h, c) => {
    const k = 34;
    return `M${cx - w / 2 + k} ${cy - h / 2} H${cx + w / 2 - k} L${cx + w / 2} ${cy - h / 2 + k} V${cy + h / 2 - k} L${cx + w / 2 - k} ${cy + h / 2} H${cx - w / 2 + k} L${cx - w / 2} ${cy + h / 2 - k} V${cy - h / 2 + k}Z`;
  };
  const nodes = [[-1, -1], [1, -1], [-1, 1], [1, 1]].map(([sx, sy]) => `<circle cx="${1080 + sx * 760}" cy="${2290 + sy * 190}" r="13" fill="${L.accent}" stroke="#fff" stroke-width="4"/>`).join('');
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${W} ${Hh}" width="100%" height="100%" style="position:absolute;inset:0">
    <path d="M0 1930 Q1080 1800 2160 1930 V3030 H0Z" fill="${L.panel}"/>
    <path d="M0 1930 Q1080 1800 2160 1930" fill="none" stroke="${L.accent}" stroke-width="7"/>
    <path d="M0 1952 Q1080 1822 2160 1952" fill="none" stroke="#ffd54a" stroke-width="2.5" opacity=".7"/>
    <circle cx="1080" cy="2290" r="560" fill="${L.accent}" opacity=".07"/>
    <path d="${oct(1080, 2290, 1520, 380)}" fill="#000" fill-opacity=".25" stroke="#ffd54a" stroke-width="6"/>
    <path d="${oct(1080, 2290, 1480, 340)}" fill="none" stroke="${L.accent}" stroke-width="3"/>
    ${nodes}
  </svg>`;
}

function coverHTML(L, artSrc) {
  return `<!doctype html><html dir="rtl"><head><meta charset="utf-8"><style>${CSS}
  .cv{width:216mm;height:303mm;position:relative;overflow:hidden;font-family:Cairo;color:#fff}
  .cv img,.cv .art{position:absolute;inset:0;width:100%;height:100%}
  .t{position:absolute;left:0;right:0;text-align:center}
  </style></head><body><div class="cv">
  ${artSrc ? `<img src="${artSrc}">` : `<div class="art">${art(L)}</div>`}
  ${overlay(L)}
  <div class="t" style="top:17mm"><div style="display:inline-flex;gap:1.6mm;background:rgba(0,0,0,.38);border:.5mm solid #ffd54a;border-radius:7mm;padding:1.4mm 3mm;box-shadow:0 1mm 3mm rgba(0,0,0,.35)">${(L.chips || ['قراءة', 'قرآن كريم', 'إملاء', 'خطّ', 'تلوين', 'دمج ومقاطع', 'قراءات']).map(c => `<span style="background:#fff;color:#111;font-weight:800;font-size:9.5pt;border-radius:4mm;padding:.2mm 2.6mm">${c}</span>`).join('')}</div></div>
  <div style="position:absolute;top:29mm;left:18mm;width:30mm;height:30mm;border-radius:50%;background:radial-gradient(circle at 35% 30%,#fff7c2,#ffd54a 55%,${L.accent});border:1mm solid #fff;box-shadow:0 1.5mm 4mm rgba(0,0,0,.45);display:flex;flex-direction:column;align-items:center;justify-content:center;transform:rotate(-10deg);color:#111;line-height:1.05">
    <b style="font-size:21pt;font-weight:900">${hd(L.pages)}</b><span style="font-size:9.5pt;font-weight:800">صفحة تعليميّة</span></div>
  <div style="position:absolute;top:28mm;right:16mm;width:50mm;padding:2.4mm 2mm 2.8mm;border-radius:6mm;background:#fff;border:1.1mm solid ${L.accent};box-shadow:0 1.5mm 4mm rgba(0,0,0,.45);transform:rotate(5deg);color:#111;line-height:1.3;text-align:center">
    ${(() => { const bd = L.badge || ['منهج مجرّب', 'التسلسل النورانيّ', 'متعدّد الحواس', 'أرى · أسمع · أنطق · أكتب · ألوّن']; return `<div style="font-size:9pt;font-weight:800;color:#555">${bd[0]}</div>
    <div style="font-size:13.5pt;font-weight:900">${bd[1]}</div>
    <div style="font-size:11pt;font-weight:900;background:${L.accent};border-radius:3mm;margin:1mm 3mm">${bd[2]}</div>
    <div style="font-size:8.5pt;font-weight:800">${bd[3]}</div>`; })()}</div>
  <div class="t" style="top:195mm"><span style="border:.5mm solid #ffd54a;color:#ffe9a8;border-radius:5mm;padding:.5mm 6mm;font-weight:700;font-size:12pt">${L.series || 'سلسلة علاج الضعف القرائي'}</span></div>
  <div class="t" style="top:${L.titleTop || 205.5}mm;font-weight:900;font-size:${L.titlePt || 74}pt;line-height:1.1;text-shadow:0 1.2mm 2.5mm rgba(0,0,0,.45)">${L.title || 'أقرأ بثقة'}</div>
  <div class="t" style="top:248.5mm"><span style="background:${L.accent};color:#111;font-weight:900;font-size:19pt;padding:.4mm 9mm;border-radius:3mm;box-shadow:0 1mm 0 #00000055">${L.name}</span></div>
  <div class="t" style="top:261.5mm;font-weight:700;font-size:15pt;color:#ffe9a8">${L.sub}</div>
  <div class="t" style="top:272mm;font-size:9.5pt;color:#e8e2d0">${L.fine || 'للتلاميذ المتلكّئين في القراءة · من الصفّ الثاني إلى الرابع الابتدائي'}</div>
  <div class="t" style="top:278mm;font-size:9pt;color:#cfc6b0">© مؤسسة وصال التعليمية · جميع الحقوق محفوظة · هاتف: ${hd('07744482082')}</div>
  </div></body></html>`;
}

function backHTML(L, artSrc, thumbs) {
  const names = L.names || ['المستوى الأول', 'المستوى الثاني', 'المستوى الثالث', 'المستوى الرابع'];
  return `<!doctype html><html dir="rtl"><head><meta charset="utf-8"><style>${CSS}
  .bk{width:216mm;height:303mm;position:relative;overflow:hidden;font-family:Cairo;color:#fff;background:linear-gradient(180deg,${L.panel} 0%,#05070d 100%)}
  .ab{position:absolute;left:0;right:0}
  </style></head><body><div class="bk">
  <img src="${artSrc}" style="position:absolute;top:0;left:0;width:100%;height:95mm;object-fit:cover;object-position:50% 58%">
  <div class="ab" style="top:0;height:96mm;background:linear-gradient(180deg,rgba(0,0,0,.45) 0%,rgba(0,0,0,.15) 45%,${L.panel} 100%)"></div>
  <div class="ab" style="top:94mm;height:209mm;background:radial-gradient(ellipse at 50% 10%,${L.accent}33,transparent 60%)"></div>
  <div class="ab" style="top:17mm;text-align:center"><span style="font-weight:900;font-size:40pt;text-shadow:0 1mm 3mm rgba(0,0,0,.6)">${L.title || 'أقرأ بثقة'}</span><br>
    <span style="background:${L.accent};color:#111;font-weight:900;font-size:14pt;padding:.3mm 7mm;border-radius:3mm">${L.name}</span></div>
  <div class="ab" style="top:76mm;margin:0 18mm;background:rgba(255,255,255,.96);color:#111;border-radius:6mm;padding:4mm 6mm;font-size:12.5pt;line-height:1.75;font-weight:600;text-align:center;border:1mm solid ${L.accent};box-shadow:0 2mm 5mm rgba(0,0,0,.4)">${L.blurb}</div>
  <div class="ab" style="top:111mm;margin:0 18mm"><div style="text-align:center;font-weight:900;font-size:15pt;color:#ffd54a;margin-bottom:2mm">ماذا في هذا الكتاب؟</div>
    <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:2.4mm">${L.tiles.map((t, k) => `<div style="background:rgba(255,255,255,.1);border:.5mm solid ${L.accent};border-radius:4mm;padding:2mm 1.5mm;text-align:center;font-weight:800;font-size:10.5pt;line-height:1.3;display:flex;align-items:center;justify-content:center;gap:1.5mm;min-height:13mm"><span style="background:${L.accent};color:#111;border-radius:50%;width:6mm;height:6mm;display:inline-flex;align-items:center;justify-content:center;font-size:9pt;flex:none">${hd(k + 1)}</span>${t}</div>`).join('')}</div></div>
  <div class="ab" style="top:157mm;height:72mm;display:flex;justify-content:center;gap:9mm">${thumbs.map((t, k) => `<img src="${t}" style="height:68mm;border:1.2mm solid #fff;border-radius:2mm;box-shadow:0 2mm 5mm rgba(0,0,0,.55);transform:rotate(${[-6, 0, 6][k]}deg) translateY(${[3, 0, 3][k]}mm)">`).join('')}</div>
  <div class="ab" style="top:236mm;text-align:center"><div style="font-weight:800;font-size:11pt;color:#ffe9a8;margin-bottom:1.5mm">مستويات السلسلة</div>
    <div style="display:inline-flex;gap:3mm">${names.map((nm, k) => `<span style="border:.6mm solid ${k + 1 === L.n ? L.accent : '#ffffff55'};background:${k + 1 === L.n ? L.accent : 'transparent'};color:${k + 1 === L.n ? '#111' : '#ddd'};font-weight:800;font-size:11pt;padding:.6mm 3.5mm;border-radius:4mm">${nm}</span>`).join('')}</div></div>
  <div class="ab" style="top:256mm;margin:0 18mm;border:.6mm solid #ffd54a;border-radius:5mm;padding:2.6mm 4mm;text-align:center;background:rgba(0,0,0,.35)">
    <div style="font-weight:900;font-size:15pt">مؤسسة وصال التعليمية</div>
    <div style="font-size:9pt;color:#e8e2d0;line-height:1.6">جميع الحقوق محفوظة · يُمنع النسخ أو التصوير أو إعادة الطبع دون إذن خطّي<br>هاتف: ${hd('07744482082')}</div></div>
  </div></body></html>`;
}

async function renderCovers(LEVELS, out, prefix = 'level') {
  const tmp = path.join(ROOT, 'build');
  fs.mkdirSync(tmp, { recursive: true });
  const b = await chromium.launch();
  for (const L of LEVELS) {
    // ١) الفن وحده كصورة عالية الدقة
    const pg = await b.newPage({ viewport: { width: 816, height: 1145 }, deviceScaleFactor: 3.7 });
    await pg.setContent(`<!doctype html><html><head><style>${CSS}body{margin:0}</style></head><body><div style="width:816px;height:1145px">${art(L)}</div></body></html>`);
    await pg.evaluate(() => document.fonts.ready);
    const png = path.join(tmp, `${prefix}cover${L.n}-art.png`);
    await pg.screenshot({ path: png, clip: { x: 0, y: 0, width: 816, height: 1145 } });
    await pg.close();
    // ٢) تركيب النصوص وإخراج PDF
    const p2 = await b.newPage();
    const src = 'data:image/png;base64,' + fs.readFileSync(png).toString('base64');
    await p2.setContent(coverHTML(L, src), { waitUntil: 'load' });
    await p2.evaluate(() => document.fonts.ready);
    await p2.pdf({ path: path.join(out, `${prefix}${L.n}-cover.pdf`), width: '216mm', height: '303mm', printBackground: true, margin: { top: 0, right: 0, bottom: 0, left: 0 }, pageRanges: '1' });
    await p2.close();
    // ٣) الغلاف الخلفي
    const { execSync } = require('child_process');
    const thumbs = L.thumbs.map(pn => {
      const base = path.join(tmp, `${prefix}th${L.n}-${pn}`);
      execSync(`pdftoppm -r 70 -png -f ${pn} -l ${pn} -singlefile ${path.join(out, `${prefix}${L.n}-interior.pdf`)} ${base}`);
      return 'data:image/png;base64,' + fs.readFileSync(base + '.png').toString('base64');
    });
    const pb = await b.newPage({ viewport: { width: 816, height: 1145 }, deviceScaleFactor: 2 });
    await pb.setContent(`<!doctype html><html><head><style>${CSS}body{margin:0}</style></head><body><div style="width:816px;height:1145px">${art(L, true)}</div></body></html>`);
    const pngB = path.join(tmp, `${prefix}cover${L.n}-art-back.png`);
    await pb.screenshot({ path: pngB, clip: { x: 0, y: 0, width: 816, height: 1145 } });
    await pb.close();
    const srcB = 'data:image/png;base64,' + fs.readFileSync(pngB).toString('base64');
    const p3 = await b.newPage();
    await p3.setContent(backHTML(L, srcB, thumbs), { waitUntil: 'load' });
    await p3.evaluate(() => document.fonts.ready);
    await p3.pdf({ path: path.join(out, `${prefix}${L.n}-back-cover.pdf`), width: '216mm', height: '303mm', printBackground: true, margin: { top: 0, right: 0, bottom: 0, left: 0 }, pageRanges: '1' });
    await p3.close();
    console.log('cover', L.n);
  }
  await b.close();
}
module.exports = { renderCovers, art, landmark };
if (require.main === module) renderCovers(LEVELS, path.join(ROOT, 'output'));
