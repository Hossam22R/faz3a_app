// مكتبة الرسم: أشكال متجهية بخطوط سميكة مناسبة لتلوين الأطفال
// كل الأشكال تُرسم بوضعين: line (أبيض وأسود للصفحات) و color (ملون للغلاف)
const INK = '#1d1d1f';
const st = { mode: 'line', s: 1 };
const setMode = m => (st.mode = m);
const F = c => {
  if (c === 'none') return 'none';
  if (c === 'ink') return INK;
  if (c === 'white!') return '#ffffff';
  return st.mode === 'line' ? '#ffffff' : c;
};
const w = n => +(n / st.s).toFixed(2);
const n2 = v => +(+v).toFixed(1);
const rotA = (r, x, y) => (r ? ` transform="rotate(${r} ${x} ${y})"` : '');

const C = (x, y, r, c = '#fff', a = '') => `<circle cx="${n2(x)}" cy="${n2(y)}" r="${n2(r)}" fill="${F(c)}" ${a}/>`;
const E = (x, y, rx, ry, c = '#fff', r = 0, a = '') =>
  `<ellipse cx="${n2(x)}" cy="${n2(y)}" rx="${n2(rx)}" ry="${n2(ry)}" fill="${F(c)}"${rotA(r, x, y)} ${a}/>`;
const P = (d, c = '#fff', a = '') => `<path d="${d}" fill="${F(c)}" ${a}/>`;
const R = (x, y, wd, h, rx, c = '#fff', r = 0, a = '') =>
  `<rect x="${n2(x)}" y="${n2(y)}" width="${n2(wd)}" height="${n2(h)}" rx="${n2(rx)}" fill="${F(c)}"${rotA(r, x + wd / 2, y + h / 2)} ${a}/>`;
const L = (d, n = 5) => `<path d="${d}" fill="none" stroke-width="${w(n)}"/>`;
const NS = 'stroke="none"';

// مجموعة مع إزاحة وتكبير؛ سماكة الخط تبقى ثابتة بصرياً
function G(x, y, s, fn, flip = false, rot = 0) {
  const prev = st.s;
  st.s = prev * s;
  const sw = w(7);
  const inner = fn();
  st.s = prev;
  return `<g transform="translate(${n2(x)} ${n2(y)})${rot ? ` rotate(${rot})` : ''} scale(${flip ? -s : s} ${s})" stroke-width="${sw}">${inner}</g>`;
}

// مسار ناعم مغلق يمر بالنقاط (Catmull-Rom)
function smooth(pts, closed = true, t = 1) {
  const n = pts.length;
  const p = i => (closed ? pts[(i + n) % n] : pts[Math.max(0, Math.min(n - 1, i))]);
  let d = `M${n2(pts[0][0])} ${n2(pts[0][1])}`;
  const last = closed ? n : n - 1;
  for (let i = 0; i < last; i++) {
    const p0 = p(i - 1), p1 = p(i), p2 = p(i + 1), p3 = p(i + 2);
    const c1 = [p1[0] + ((p2[0] - p0[0]) / 6) * t, p1[1] + ((p2[1] - p0[1]) / 6) * t];
    const c2 = [p2[0] - ((p3[0] - p1[0]) / 6) * t, p2[1] - ((p3[1] - p1[1]) / 6) * t];
    d += ` C${n2(c1[0])} ${n2(c1[1])} ${n2(c2[0])} ${n2(c2[1])} ${n2(p2[0])} ${n2(p2[1])}`;
  }
  return closed ? d + 'Z' : d;
}

// حافة متموجة (لبدة الأسد، الغيوم، الأزهار)
function scallop(cx, cy, r, n, amp, rot = 0, ry = null) {
  ry = ry ?? r;
  const k = ry / r;
  let d = '';
  for (let i = 0; i <= n; i++) {
    const a = rot + (i * 2 * Math.PI) / n;
    const x = cx + r * Math.cos(a), y = cy + r * k * Math.sin(a);
    if (i === 0) d = `M${n2(x)} ${n2(y)}`;
    else {
      const am = a - Math.PI / n;
      const qx = cx + (r + 2 * amp) * Math.cos(am), qy = cy + (r + 2 * amp) * k * Math.sin(am);
      d += ` Q${n2(qx)} ${n2(qy)} ${n2(x)} ${n2(y)}`;
    }
  }
  return d + 'Z';
}

// مولّد أرقام شبه عشوائية ثابت (نفس النتيجة كل مرة)
function rng(seed) {
  let s = seed >>> 0;
  return () => ((s = (s * 1664525 + 1013904223) >>> 0) / 4294967296);
}
function blobPath(cx, cy, r, seed = 1, n = 7, v = 0.25) {
  const rnd = rng(seed);
  const pts = [];
  for (let i = 0; i < n; i++) {
    const a = (i / n) * Math.PI * 2 + rnd() * 0.4;
    const rr = r * (1 - v / 2 + rnd() * v);
    pts.push([cx + rr * Math.cos(a), cy + rr * Math.sin(a)]);
  }
  return smooth(pts);
}
const blob = (cx, cy, r, c, seed, n, v) => P(blobPath(cx, cy, r, seed, n, v), c);

function starPath(cx, cy, R1, r1 = R1 * 0.48, n = 5, rot = -90) {
  const pts = [];
  for (let i = 0; i < n * 2; i++) {
    const a = ((rot + (i * 180) / n) * Math.PI) / 180;
    const rr = i % 2 ? r1 : R1;
    pts.push(`${n2(cx + rr * Math.cos(a))} ${n2(cy + rr * Math.sin(a))}`);
  }
  return 'M' + pts.join(' L') + 'Z';
}

// ---------- الوجه اللطيف (kawaii) ----------
function face(x, y, k = 1, o = {}) {
  const ex = (o.ex ?? 24) * k, er = (o.er ?? 11) * k;
  let s = '';
  for (const sx of [-1, 1]) {
    const cx = x + sx * ex;
    if (o.happy) s += L(`M${cx - er} ${y + er * 0.3} Q${cx} ${y - er * 1.1} ${cx + er} ${y + er * 0.3}`, 6);
    else if (o.wink && sx === 1) s += L(`M${cx - er} ${y} Q${cx} ${y - er} ${cx + er} ${y}`, 6);
    else {
      s += E(cx, y, er * 0.82, er, 'ink', 0, NS);
      s += C(cx + er * 0.28, y - er * 0.38, er * 0.34, 'white!', NS);
      s += C(cx - er * 0.25, y + er * 0.4, er * 0.15, 'white!', NS);
    }
    if (o.blush !== false) {
      const bx = cx + sx * (o.bx ?? 16) * k, by = y + (o.by ?? 20) * k;
      s += E(bx, by, 10 * k, 6 * k, '#ff9db4', 0, `stroke-width="${w(3)}"`);
    }
  }
  const my = y + (o.my ?? 14) * k;
  const m = o.mouth ?? 'smile';
  if (m === 'smile') s += L(`M${x - 8 * k} ${my} Q${x} ${my + 9 * k} ${x + 8 * k} ${my}`, 5);
  else if (m === 'w') s += L(`M${x - 12 * k} ${my} Q${x - 6 * k} ${my + 9 * k} ${x} ${my} Q${x + 6 * k} ${my + 9 * k} ${x + 12 * k} ${my}`, 5);
  else if (m === 'open')
    s += P(`M${x - 11 * k} ${my} Q${x} ${my + 2 * k} ${x + 11 * k} ${my} Q${x + 9 * k} ${my + 16 * k} ${x} ${my + 16 * k} Q${x - 9 * k} ${my + 16 * k} ${x - 11 * k} ${my}Z`, '#ff7a8a', `stroke-width="${w(5)}"`);
  return s;
}

// ---------- عناصر الخلفية ----------
const BG = {
  sun(x, y, r = 60) {
    let rays = '';
    for (let i = 0; i < 12; i++) {
      const a = (i * Math.PI) / 6;
      rays += L(`M${x + (r + 14) * Math.cos(a)} ${y + (r + 14) * Math.sin(a)} L${x + (r + 34) * Math.cos(a)} ${y + (r + 34) * Math.sin(a)}`, 7);
    }
    return rays + C(x, y, r, '#ffd23f') + face(x, y + 2, r / 60, { mouth: 'smile', ex: 20, er: 7, bx: 12, by: 16 });
  },
  cloud(x, y, s = 1, c = '#ffffff') {
    return G(x, y, s, () => P('M-72 26 C-100 26 -100 -12 -68 -14 C-66 -48 -22 -54 -8 -28 C6 -60 58 -54 58 -16 C90 -20 96 26 64 26 Z', c));
  },
  star: (x, y, r = 18, c = '#ffd23f', rot = -90) => P(starPath(x, y, r, r * 0.5, 5, rot), c, `stroke-width="${w(5)}"`),
  sparkle: (x, y, r = 14) =>
    P(`M${x} ${y - r} Q${x + r * 0.18} ${y - r * 0.18} ${x + r} ${y} Q${x + r * 0.18} ${y + r * 0.18} ${x} ${y + r} Q${x - r * 0.18} ${y + r * 0.18} ${x - r} ${y} Q${x - r * 0.18} ${y - r * 0.18} ${x} ${y - r}Z`, '#ffe680', `stroke-width="${w(4)}"`),
  heart(x, y, s = 1, c = '#ff6b8b') {
    return G(x, y, s, () => P('M0 12 C-30 -8 -26 -34 -10 -34 C-4 -34 0 -28 0 -24 C0 -28 4 -34 10 -34 C26 -34 30 -8 0 12Z', c, `stroke-width="${w(5)}"`));
  },
  flower(x, y, s = 1, c = '#ff8fab', stem = true) {
    return G(x, y, s, () => {
      let o = '';
      if (stem) o += L('M0 0 Q4 50 0 90', 6) + P('M2 60 Q30 40 44 52 Q28 72 2 62Z', '#7bd389', `stroke-width="${w(5)}"`);
      for (let i = 0; i < 5; i++) {
        const a = (i * 72 - 90) * (Math.PI / 180);
        o += C(22 * Math.cos(a), 22 * Math.sin(a), 16, c, `stroke-width="${w(5)}"`);
      }
      return o + C(0, 0, 13, '#ffd23f', `stroke-width="${w(5)}"`);
    });
  },
  tulip(x, y, s = 1, c = '#ff6b6b') {
    return G(x, y, s, () =>
      L('M0 0 L0 80', 6) + P('M0 50 Q-30 30 -34 44 Q-24 68 0 64Z', '#7bd389', `stroke-width="${w(5)}"`) +
      P('M-22 -36 L-12 -18 L0 -38 L12 -18 L22 -36 Q28 0 0 4 Q-28 0 -22 -36Z', c, `stroke-width="${w(5)}"`));
  },
  grass(x, y, s = 1) {
    return G(x, y, s, () => P('M-18 0 L-14 -22 L-7 -6 L0 -30 L7 -6 L14 -22 L18 0Z', '#7bd389', `stroke-width="${w(5)}"`));
  },
  hills(y, c1 = '#a8e6a1', c2 = '#7bd389') {
    return P(`M-20 ${y + 30} Q180 ${y - 50} 420 ${y + 10} T880 ${y - 10} L880 1120 L-20 1120Z`, c1) +
      P(`M-20 ${y + 90} Q260 ${y + 40} 520 ${y + 90} T880 ${y + 70} L880 1120 L-20 1120Z`, c2);
  },
  ground(y, c = '#a8e6a1') {
    return P(`M-20 ${y} Q220 ${y - 30} 425 ${y} T880 ${y} L880 1120 L-20 1120Z`, c);
  },
  tree(x, y, s = 1) {
    return G(x, y, s, () =>
      P('M-16 0 L-12 -110 L12 -110 L16 0Z', '#c98b5a') + P(scallop(0, -160, 70, 9, 12), '#7bd389') +
      C(-25, -170, 7, '#ff6b6b', `stroke-width="${w(4)}"`) + C(22, -140, 7, '#ff6b6b', `stroke-width="${w(4)}"`) + C(10, -190, 7, '#ff6b6b', `stroke-width="${w(4)}"`));
  },
  palm(x, y, s = 1, flip = false) {
    return G(x, y, s, () => {
      let o = P('M-12 0 Q-2 -120 30 -230 L48 -226 Q16 -120 14 0Z', '#c98b5a');
      for (let i = 1; i < 8; i++) o += L(`M${-8 + i * 4.5} ${-i * 30} l18 3`, 4);
      const leaves = [[-110, -10], [-60, -60], [10, -55], [80, -20], [120, 30]];
      for (const [lx, ly] of leaves) o += P(`M40 -230 Q${40 + lx * 0.5} ${-280 + ly} ${40 + lx} ${-215 + ly * 0.4} Q${40 + lx * 0.45} ${-240 + ly * 0.5} 40 -230Z`, '#7bd389');
      return o + C(30, -222, 11, '#a0673f') + C(50, -218, 11, '#a0673f');
    }, flip);
  },
  mushroom(x, y, s = 1, c = '#ff6b6b') {
    return G(x, y, s, () =>
      P('M-14 0 Q-18 -30 -12 -40 L12 -40 Q18 -30 14 0Z', '#fff3d6') + P('M-46 -38 Q-44 -90 0 -92 Q44 -90 46 -38Z', c) +
      C(-20, -62, 8, '#fff', `stroke-width="${w(4)}"`) + C(12, -74, 6, '#fff', `stroke-width="${w(4)}"`) + C(24, -52, 6, '#fff', `stroke-width="${w(4)}"`));
  },
  bubble(x, y, r = 14) {
    return C(x, y, r, '#cdeffd', `stroke-width="${w(4.5)}"`) + L(`M${x - r * 0.55} ${y - r * 0.1} Q${x - r * 0.5} ${y - r * 0.55} ${x - r * 0.1} ${y - r * 0.6}`, 3.5);
  },
  seaweed(x, y, h = 160, c = '#62c370') {
    const pts = [];
    for (let i = 0; i <= 6; i++) pts.push([x + (i % 2 ? 16 : -10), y - (i * h) / 6]);
    const back = [];
    for (let i = 6; i >= 0; i--) back.push([x + (i % 2 ? 40 : 14) - (i === 6 ? 12 : 0), y - (i * h) / 6]);
    return P(smooth(pts.concat(back), true, 0.9), c);
  },
  waves(y, c = '#9fdcf5') {
    let d = `M-20 ${y}`;
    for (let x = -20; x < 880; x += 80) d += ` q20 -26 40 0 q20 26 40 0`;
    return P(d + ` L880 1120 L-20 1120Z`, c);
  },
  rainbow(x, y, r = 200) {
    const cols = ['#ff6b6b', '#ffa94d', '#ffd23f', '#7bd389', '#74c0fc', '#b197fc'];
    let o = '';
    const band = 22;
    cols.forEach((c, i) => {
      const R1 = r - i * band, r1 = R1 - band;
      o += P(`M${x - R1} ${y} A${R1} ${R1} 0 0 1 ${x + R1} ${y} L${x + r1} ${y} A${r1} ${r1} 0 0 0 ${x - r1} ${y}Z`, c, `stroke-width="${w(5)}"`);
    });
    return o;
  },
  snowflake(x, y, r = 16) {
    let o = '';
    for (let i = 0; i < 3; i++) {
      const a = (i * Math.PI) / 3;
      o += L(`M${x - r * Math.cos(a)} ${y - r * Math.sin(a)} L${x + r * Math.cos(a)} ${y + r * Math.sin(a)}`, 4);
    }
    return o;
  },
  moon(x, y, r = 50) {
    return P(`M${x} ${y - r} A${r} ${r} 0 1 0 ${x + r * 0.9} ${y + r * 0.45} A${r * 0.78} ${r * 0.78} 0 1 1 ${x} ${y - r}Z`, '#ffe680');
  },
  leaf(x, y, s = 1, rot = 0, c = '#7bd389') {
    return G(x, y, s, () => P('M0 0 Q20 -26 0 -56 Q-20 -26 0 0Z', c, `stroke-width="${w(5)}"`) + L('M0 -4 L0 -44', 3.5), false, rot);
  },
  fence(y, x1 = -20, x2 = 880) {
    let o = R(x1, y - 60, x2 - x1, 16, 6, '#e8b98a') + R(x1, y - 25, x2 - x1, 16, 6, '#e8b98a');
    for (let x = x1 + 10; x < x2; x += 70) o += P(`M${x} ${y + 20} L${x} ${y - 85} L${x + 18} ${y - 105} L${x + 36} ${y - 85} L${x + 36} ${y + 20}Z`, '#f2cfa5');
    return o;
  },
  pebble: (x, y, r = 18, c = '#d0d4da') => E(x, y, r, r * 0.6, c, 0, `stroke-width="${w(5)}"`),
  coral(x, y, s = 1, c = '#ff8fab') {
    return G(x, y, s, () => P('M-10 0 L-10 -40 Q-40 -50 -40 -80 Q-40 -96 -28 -96 Q-18 -96 -18 -80 Q-18 -64 -8 -62 L-8 -110 Q-8 -126 4 -126 Q16 -126 16 -110 L16 -70 Q30 -68 30 -90 Q30 -104 42 -104 Q54 -104 54 -88 Q54 -50 16 -44 L16 0Z', c));
  },
  bee(x, y, s = 1) {
    return G(x, y, s, () =>
      E(-8, -20, 13, 18, '#e3f6ff', -25, `stroke-width="${w(4.5)}"`) + E(10, -20, 13, 18, '#e3f6ff', 25, `stroke-width="${w(4.5)}"`) +
      E(0, 0, 26, 19, '#ffd23f', 0, `stroke-width="${w(5)}"`) + L('M-6 -17 Q-10 0 -6 17', 6) + L('M8 -16 Q4 0 8 16', 6) +
      C(18, -3, 3.5, 'ink', NS));
  },
  butterfly(x, y, s = 1, c = '#b197fc') {
    return G(x, y, s, () =>
      P('M0 0 Q-30 -40 -40 -20 Q-46 0 0 0Z', c, `stroke-width="${w(4.5)}"`) + P('M0 0 Q30 -40 40 -20 Q46 0 0 0Z', c, `stroke-width="${w(4.5)}"`) +
      P('M0 0 Q-26 26 -14 30 Q-4 30 0 0Z', c, `stroke-width="${w(4.5)}"`) + P('M0 0 Q26 26 14 30 Q4 30 0 0Z', c, `stroke-width="${w(4.5)}"`) +
      E(0, 4, 4, 16, 'ink', 0, NS) + L('M0 -10 Q-4 -24 -10 -28 M0 -10 Q4 -24 10 -28', 3));
  },
  dots(list, r = 5) {
    return list.map(([x, y]) => C(x, y, r, '#ffd23f', `stroke-width="${w(3.5)}"`)).join('');
  },
};

module.exports = { INK, st, setMode, F, w, C, E, P, R, L, NS, G, smooth, scallop, blob, blobPath, starPath, face, BG, rng };
