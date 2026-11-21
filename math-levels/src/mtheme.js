// نظام التصميم الملوّن لسلسلة «أحسب بثقة»
const R = '../../arabic-reading-levels/src/';
const { hd } = require(R + 'common');
const { pic } = require(R + 'pics');
const { icon } = require('./mlib');

// المراحل: لون + أيقونة + اسم
const STAGES = [
  { n: 'محسوس', c: '#F97316', l: '#FFF1E6', i: 'hand' },
  { n: 'مصوّر', c: '#0EA5A4', l: '#E6FAF9', i: 'eye' },
  { n: 'مجرّد', c: '#2563EB', l: '#EAF1FF', i: 'pencil' },
  { n: 'طلاقة', c: '#DB2777', l: '#FDEAF3', i: 'watch' },
  { n: 'تطبيق', c: '#16A34A', l: '#E8F8EE', i: 'puzzle' },
  { n: 'تفكير', c: '#7C3AED', l: '#F2ECFF', i: 'bulb' },
];
const NEUTRAL = { n: '', c: '#1E3A8A', l: '#EEF2FB', i: 'book' };
const REVIEW = { n: 'مراجعة', c: '#B45309', l: '#FFF6E0', i: 'star' };
const UNIT_COLORS = ['#EF4444', '#F97316', '#F59E0B', '#84CC16', '#10B981', '#14B8A6', '#06B6D4', '#3B82F6', '#6366F1', '#8B5CF6', '#D946EF', '#EC4899'];

const CSS = `
.page{--st:#1E3A8A;--stl:#EEF2FB}
.sec{border:.55mm solid var(--st);background:linear-gradient(180deg,var(--stl) 0,#fff 14mm);border-radius:5mm}
.sec>.t i{background:var(--st)}
.sec>.t{color:#0f172a}
.cell{border-color:#475569;border-width:.45mm;background:#fff}
.parent{border-color:var(--st);background:#FFFBEA}
.foot .pn{background:var(--st);color:#fff;border-color:var(--st)}
table th{background:var(--stl)!important;color:#0f172a}
td,th{border-color:#475569}
.mh{display:flex;align-items:stretch;border-radius:6mm;overflow:hidden;box-shadow:0 .8mm 0 rgba(15,23,42,.18);border:.5mm solid var(--st);min-height:21mm;flex:none}
.mh .ic{flex:0 0 21mm;background:var(--st);display:flex;flex-direction:column;align-items:center;justify-content:center;gap:.5mm;color:#fff;font-weight:800;font-size:8.5pt}
.mh .ic .g{width:10mm;height:10mm}
.mh .mid{flex:1;background:linear-gradient(90deg,#fff 0,var(--stl) 100%);padding:1.6mm 4mm;display:flex;flex-direction:column;justify-content:center}
.mh h1{margin:0;font-size:21pt;font-weight:900;line-height:1.3;color:#0f172a}
.mh .goal{font-size:10.5pt;font-weight:700;color:var(--st);display:flex;align-items:center;gap:1.5mm}
.mh .side{flex:0 0 30mm;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:1.2mm;padding:1.5mm;background:#fff;border-right:.4mm dashed var(--st)}
.mh .unit{font-size:9pt;font-weight:800;color:#334155}
.mh .cra{display:flex;gap:.8mm}
.mh .cra span{font-size:7pt;font-weight:800;padding:.2mm 1.4mm;border-radius:2mm;border:.3mm solid #94a3b8;color:#64748b}
.mh .cra span.on{background:var(--st);border-color:var(--st);color:#fff}
.tab{position:absolute;right:0;width:7.5mm;height:17mm;border-radius:3mm 0 0 3mm;color:#fff;font-weight:900;font-size:12pt;display:flex;align-items:center;justify-content:center;z-index:5;box-shadow:-.4mm .4mm 0 rgba(0,0,0,.2)}
.sami{display:flex;align-items:center;gap:2.5mm;flex:none}
.sami .m{width:15mm;height:15mm;flex:none}
.sami .b{position:relative;background:#FFF8D6;border:.5mm solid #E0B400;border-radius:4mm;padding:1.4mm 4mm;font-size:11.5pt;font-weight:600;line-height:1.6;flex:1}
.sami .b::before{content:'';position:absolute;right:-2.3mm;top:50%;transform:translateY(-50%);border:2.2mm solid transparent;border-left-color:#E0B400;border-right:0}
`;
// ألوان الصفحة حسب المرحلة
const stageCSS = STAGES.map((s, k) => `.page:has(.mh[data-st="${k}"]){--st:${s.c};--stl:${s.l}}`).join('') +
  `.page:has(.mh[data-st="r"]){--st:${REVIEW.c};--stl:${REVIEW.l}}`;

let SAMI = null;
const sami = text => {
  SAMI = SAMI || pic('monkey', 'pic', true);
  return `<div class="sami"><div class="m">${SAMI}</div><div class="b">${text}</div></div>`;
};

// رأس الصفحة: أيقونة المرحلة، العنوان، الهدف، رقم الوحدة وشريط المراحل
function mheader(title, { unit = 0, stage = null, goal = '', tag = '', review = false } = {}) {
  const S = review ? REVIEW : stage === null ? NEUTRAL : STAGES[stage];
  const st = review ? 'r' : stage === null ? 'n' : stage;
  const cra = stage !== null && stage <= 2 ? `<div class="cra">${['محسوس', 'مصوّر', 'مجرّد'].map((t, k) => `<span class="${k === stage ? 'on' : ''}">${t}</span>`).join('')}</div>` : '';
  const tab = unit ? `<div class="tab" style="top:${26 + (unit - 1) * 19.5}mm;background:${UNIT_COLORS[unit - 1]}">${hd(unit)}</div>` : '';
  return `${tab}<div class="mh" data-st="${st}">
    <div class="ic"><div class="g">${icon(S.i)}</div>${S.n || tag}</div>
    <div class="mid"><h1 style="font-size:${title.length > 26 ? 17 : title.length > 19 ? 19 : 21}pt">${title}</h1>${goal ? `<div class="goal"><span style="width:4mm;height:4mm;display:inline-block">${icon('star', 'currentColor')}</span>أستطيع أن ${goal}</div>` : ''}</div>
    <div class="side">${unit ? `<div class="unit">الوحدة ${hd(unit)}</div>` : `<div class="unit">${tag}</div>`}${cra}</div>
  </div>`;
}

module.exports = { CSS: CSS + stageCSS, mheader, sami, STAGES, UNIT_COLORS };
