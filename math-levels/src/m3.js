// «أحسب بثقة» — المستوى الثالث: أضرب وأقسم
// المرجع: دليل IES 2021 (تعليم صريح، تمثيلات، طلاقة موقوتة، مسائل بالأشرطة)، والتدرّج المحسوس ← المصوّر ← المجرّد،
// وتعليم حقائق الضرب بترتيب الاستراتيجيّات (٢، ٥، ١٠ ← ٤ ← ٩ ← ٣، ٦ ← ٧، ٨) واشتقاقها من حقائق معروفة
const path = require('path');
const { makeKit, M, hd, shuffle, sec, pic } = require('./mcore');
const { eq, svg, numberLine, objects, array, groups, barMul, timesChart, openLine } = M;
const ROOT = path.resolve(__dirname, '..');
const LV = 3;
const GOALS = ['أفهم الضرب جمعاً لمجموعات متساوية', 'أكتب الضرب من المصفوفة بطريقتين', 'أعدّ بالقفز لأضرب على خطّ الأعداد', 'أعرف حقائق ×٢ و×١٠ بسرعة', 'أعرف حقائق ×٥ وأربطها بـ×١٠', 'أضاعف المضاعف لأجد ×٤',
  'أستعمل حيل ×٩', 'أجد ×٣ و×٦ من حقائق أعرفها', 'أفكّك ×٧ و×٨ إلى حقائق سهلة', 'أفهم القسمة توزيعاً وتجميعاً', 'أقسم بالتفكير في الضرب', 'أحلّ مسائل الضرب والقسمة بالأشرطة'];
const K = makeKit(LV, GOALS);
const { P, H, tagU, box, big, E, parent, grid, rows } = K;
const rnd = (() => { let s = 41; return (a, b) => { s = (s * 16807) % 2147483647; return a + (s % (b - a + 1)); }; })();
const X = '×', D = '÷';
const ar = (r, c, o = {}, w = '100%', h = '100%') => `<div style="width:${w};height:${h}">${array(r, c, o)}</div>`;
const gr = (g, n, w = '100%', h = '100%', o = {}) => `<div style="width:${w};height:${h}">${groups(g, n, o)}</div>`;
const mul = (a, b, pt = 20) => E(pt, a, X, b, '=', '_');

// صفحات قالبيّة لحقائق جدول معيّن
function factsTable(u, k, n, trick) {
  return P(`${H(`حقائقُ ×${hd(n)}`, tagU(u, 2))}
    <div style="font-size:12pt">${trick}</div>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:2.4mm;flex:1;min-height:0">${Array.from({ length: 10 }, (_, i) => i + 1).map(m => `<div class="cell" style="gap:3mm">${E(21, m, X, n, '=', '_')}</div>`).join('')}</div>`);
}
const drillFor = (u, ns, title) => K.drill(title, tagU(u, 3), Array.from({ length: 27 }, () => { const n = ns[rnd(0, ns.length - 1)]; return rnd(0, 1) ? [rnd(1, 10), X, n] : [n, X, rnd(1, 10)]; }));

const UNITS = [
  { t: 'المجموعات المتساوية', pages: u => [
    P(`${H('مجموعاتٌ متساوية', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.85"><b>هيّا نلعب:</b> نضع ٣ صحون، وفي كلّ صحن ٤ تمرات. كم تمرة؟ ٤ + ٤ + ٤ = ١٢. نقول: ٣ مجموعات من ٤، ونكتب ٣ × ٤ = ١٢.</div>
      ${rows([[3, 4], [2, 5], [4, 3], [5, 2], [3, 6]].map(([g, n]) => `<div style="flex:1;height:22mm">${groups(g, n)}</div><span style="font-size:13pt;font-weight:700;line-height:2;white-space:nowrap">${box(9, 8)} مجموعات من ${box(9, 8)}<br>${eq('_', '+', '_', '+', '…', '=', '_')}</span>`))}`),
    P(`${H('أرسمُ المجموعات', tagU(u, 1))}<div style="font-size:12pt">أرسم النقاط في الدوائر، ثمّ أكتب الجمع والضرب.</div>
      ${rows([[3, 2], [4, 5], [2, 6], [5, 3], [3, 5]].map(([g, n]) => `<span style="font-size:13pt;font-weight:800;white-space:nowrap">${hd(g)} مجموعات من ${hd(n)}</span><div style="flex:1;height:22mm">${groups(g, n, { blankDots: true })}</div>${E(16, g, X, n, '=', '_')}`))}`),
    P(`${H('من الجمع إلى الضرب', tagU(u, 2))}${sec(1, 'أكتبُ جملة ضرب', grid(1, [[3, 4], [5, 2], [2, 7], [4, 5], [6, 3], [3, 3]].map(([g, n]) => `<span style="font-size:18pt;white-space:nowrap">${eq(...Array.from({ length: g }, () => [n, '+']).flat().slice(0, -1), '=', '_', X, '_')}</span>`), 15))}
      ${sec(2, 'أكتبُ جملة جمع', grid(2, [[4, 2], [3, 5], [2, 9], [5, 4]].map(([g, n]) => `<span style="font-size:17pt">${eq(g, X, n)} = </span><span style="flex:1;border-bottom:.5mm solid #111;height:10mm"></span>`), 20), 'grow')}`),
    K.fluency('كم المجموع؟ أقول بسرعة', tagU(u, 3), Array.from({ length: 12 }, () => { const g = rnd(2, 5), n = rnd(2, 5); return gr(g, n, '100%', '80%'); }), 3),
    K.wordProblems('مسائل المجموعات', tagU(u, 4), [['في كلّ علبة ٤ أقلام، وعندي ٣ علب. كم قلماً عندي؟', barMul(3, 4)], ['في كلّ سيّارة ٥ ركّاب، وهناك ٢ سيّارة. كم راكباً؟', barMul(2, 5)], ['لكلّ قطّة ٤ أرجل. كم رجلاً لـ ٥ قطط؟', barMul(5, 4)], ['في كلّ صفّ من البستان ٦ نخلات، وفيه ٣ صفوف. كم نخلة؟', barMul(3, 6)]]),
    K.think(u, 'المجموعات المتساوية', { w: [gr(3, 2, '100%', '80%'), gr(2, 3, '100%', '80%'), E(20, 2, '+', 2, '+', 2), gr(3, 3, '100%', '80%')], e: [24, 'apple'], err: [gr(4, 3, '100%', '60%'), 'قال سامي: ٤ × ٣ = ٧'] }),
  ] },
  { t: 'المصفوفات', pages: u => [
    P(`${H('أرتّبُ في صفوف وأعمدة', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.85"><b>هيّا نلعب:</b> نرتّب ١٢ غطاءً في صفوف متساوية: ٣ صفوف في كلّ منها ٤، أو ٤ صفوف في كلّ منها ٣، أو ٢ × ٦… هذا ترتيب اسمه «المصفوفة».</div>
      ${grid(3, [[3, 4], [2, 6], [4, 3], [6, 2], [2, 5], [5, 2]].map(([r, c]) => `${ar(r, c, {}, '60%', '28mm')}<span style="font-size:13pt;font-weight:700">${box(9, 8)} صفوف × ${box(9, 8)} = ${box(11, 8)}</span>`), 'fill')}`),
    P(`${H('أكتبُ جملتين لكلّ مصفوفة', tagU(u, 1))}<div style="font-size:12pt">أعدّ الصفوف ثمّ الأعمدة. ٣ × ٤ و٤ × ٣ لهما الناتج نفسه: هذه خاصيّة الإبدال.</div>
      ${grid(2, [[2, 4], [3, 5], [4, 6], [5, 3], [2, 8], [3, 7]].map(([r, c]) => `${ar(r, c, {}, '48%', '30mm')}<span style="font-size:16pt;line-height:2.1">${eq('_', X, '_', '=', '_')}<br>${eq('_', X, '_', '=', '_')}</span>`), 'fill')}`),
    P(`${H('أرسمُ المصفوفة', tagU(u, 2))}${grid(2, [[2, 3], [4, 4], [3, 6], [5, 2], [2, 7], [3, 3]].map(([r, c]) => `${E(20, r, X, c, '=', '_')}${ar(r, c, { empty: true }, '50%', '28mm')}`), 'fill')}`),
    K.fluency('أقرأ المصفوفة بسرعة', tagU(u, 3), Array.from({ length: 12 }, () => ar(rnd(2, 5), rnd(2, 6), {}, '80%', '80%')), 4, 'أكتب ناتج كلّ مصفوفة بأسرع ما أستطيع: أعدّ الصفوف وأقفز بالأعمدة.'),
    P(`${H('المصفوفات من حولي', tagU(u, 4))}<div style="font-size:12pt">أبحث عن مصفوفات في الصفّ والبيت: علبة بيض، نوافذ، بلاط… أرسمها وأكتب جملتها.</div>
      ${grid(2, Array.from({ length: 4 }, () => `<div style="flex:1;height:100%;display:flex;flex-direction:column;gap:2mm"><div style="flex:1;border:.4mm dashed #111;border-radius:2mm;background:#fff"></div><span style="font-size:13pt;font-weight:700">ما هي؟ ................ ${box(9, 8)} × ${box(9, 8)} = ${box(11, 8)}</span></div>`), 'fill')}
      ${parent('علبة البيض مصفوفة ٢ × ٦! اسألوا طفلكم: كم بيضة؟ وكم في نصف العلبة؟')}`),
    K.think(u, 'المصفوفات', { w: [ar(3, 4, {}, '80%', '80%'), ar(4, 3, {}, '80%', '80%'), ar(2, 6, {}, '80%', '80%'), ar(3, 5, {}, '80%', '80%')], e: [20, 'star'], err: [ar(3, 5, {}, '60%', '60%'), 'قال سامي: ٣ × ٥ = ٨'] }),
  ] },
  { t: 'العدّ بالقفز للضرب', pages: u => [
    P(`${H('أقفزُ قفزات متساوية', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.85"><b>هيّا نلعب:</b> نرسم خطّاً على الأرض، ونقفز ٣ قفزات كلّ منها ٤ خطوات: ٤، ٨، ١٢. ٣ × ٤ = ١٢.</div>
      ${[[3, 4], [4, 5], [5, 2], [2, 6]].map(([g, n]) => sec(0, `${hd(g)} قفزات، كلّ قفزة ${hd(n)}`, `${numberLine(0, Math.max(20, g * n + 2), { every: 2, jumps: Array.from({ length: g }, (_, k) => [k * n, (k + 1) * n]), h: 86 })}<div style="font-size:17pt;text-align:center">${eq(g, X, n, '=', '_')}</div>`).replace('<i>٠</i>', '<i>✦</i>')).join('')}`),
    P(`${H('أرسمُ القفزات وأكتبُ الناتج', tagU(u, 1))}<div style="display:flex;flex-direction:column;gap:3mm;flex:1;justify-content:space-between">${[[4, 3], [3, 5], [6, 2], [5, 4], [2, 9]].map(([g, n]) => `<div class="sec" style="display:flex;align-items:center;gap:3mm">${E(19, g, X, n, '=', '_')}<div style="flex:1">${numberLine(0, 20, { every: 2, h: 76 })}</div></div>`).join('')}</div>`),
    P(`${H('أكملُ العدّ بالقفز', tagU(u, 2))}${rows([2, 3, 4, 5, 10, 6].map(n => `<span style="font-size:13pt;font-weight:800;white-space:nowrap">بالـ${hd(n)}:</span><span style="font-size:18pt">${eq(n, '،', 2 * n, '،', 3 * n, '،', '_', '،', '_', '،', '_', '،', '_')}</span>`))}`),
    K.fluency('أعدّ بالقفز بسرعة', tagU(u, 3), ['بالاثنين حتى ٢٠', 'بالخمسات حتى ٥٠', 'بالعشرات حتى ١٠٠', 'بالثلاثات حتى ٣٠', 'بالأربعات حتى ٤٠', 'بالخمسات إلى الخلف من ٥٠'].map(t => `<span style="font-size:15pt;font-weight:800">${t}</span>`), 2, 'يعدّ التلميذ بصوت مسموع، والمعلّم يسجّل الزمن.'),
    K.wordProblems('مسائل القفز', tagU(u, 4), [['يقفز الأرنب ٣ خطوات كلّ مرّة. أين يصل بعد ٥ قفزات؟', barMul(5, 3)], ['يوفّر حسن ٥ دنانير كلّ يوم. كم يوفّر في ٤ أيّام؟', barMul(4, 5)], ['يقرأ عليّ ٢ صفحة كلّ ليلة. كم صفحة في ٧ ليالٍ؟', barMul(7, 2)], ['يمشي الجدّ ٤ كيلومترات كلّ يوم. كم يمشي في ٦ أيّام؟', barMul(6, 4)]]),
    K.think(u, 'العدّ بالقفز', { w: [E(18, 3, '،', 6, '،', 9), E(18, 5, '،', 10, '،', 15), E(18, 4, '،', 8, '،', 12), E(18, 2, '،', 4, '،', 7)], e: [21, 'ball'], err: [E(22, 4, '،', 8, '،', 12, '،', 14), 'عدّ سامي بالأربعات هكذا.'] }),
  ] },
  { t: 'جدولا ٢ و١٠', pages: u => [
    P(`${H('×٢ = المضاعف، و×١٠ = أضيف صفراً', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.85"><b>هيّا نلعب:</b> ×٢ مثل المرآة: ٢ × ٧ = ٧ + ٧. و×١٠ نعدّ حزم العيدان: ٤ حزم = ٤٠. ماذا تلاحظ في ناتج ×١٠؟</div>
      ${grid(2, [[2, 3], [2, 6], [2, 8], [3, 10], [5, 10], [7, 10]].map(([g, n]) => `${n === 10 ? `<div style="display:flex;gap:1mm;height:26mm;flex:1">${Array.from({ length: g }, () => `<div style="width:5mm;background:#60A5FA;border:.4mm solid #1E3A8A;border-radius:1mm"></div>`).join('')}</div>` : `<div style="flex:1;height:24mm">${groups(g, n)}</div>`}${E(17, g, X, n, '=', '_')}`), 'fill')}`),
    P(`${H('جدولا ٢ و١٠ بالمصفوفات', tagU(u, 1))}${grid(2, [[2, 4], [2, 7], [2, 9], [2, 10]].map(([r, c]) => `${ar(r, c, {}, '60%', '18mm')}${E(17, r, X, c, '=', '_')}`), 32)}
      ${sec(1, 'أكملُ النمط', `<div style="font-size:18pt;line-height:2.3;text-align:center">${eq(2, '،', 4, '،', 6, '،', '_', '،', '_', '،', '_', '،', '_', '،', '_', '،', '_', '،', 20)}<br>${eq(10, '،', 20, '،', 30, '،', '_', '،', '_', '،', '_', '،', '_', '،', '_', '،', '_', '،', 100)}</div>`, 'grow')}`),
    factsTable(u, 2, 2, 'تذكّر: ×٢ = أضاعف العدد. ثمّ أجرّب حقائق ×١٠ في الصفحة التالية.'),
    drillFor(u, [2, 10], 'تمرينُ دقيقة: ×٢ و×١٠'),
    K.wordProblems('مسائل ×٢ و×١٠', tagU(u, 4), [['لكلّ طفل يدان. كم يداً لـ ٨ أطفال؟', barMul(8, 2)], ['في كلّ حزمة ١٠ أقلام. كم قلماً في ٦ حزم؟', barMul(6, 10)], ['ثمن الدفتر ١٠ دنانير. كم ثمن ٤ دفاتر؟', barMul(4, 10)], ['في كلّ حذاء فردتان. كم فردة في ٩ أحذية؟', barMul(9, 2)]]),
    K.think(u, '×٢ و×١٠', { w: [E(22, 2, X, 5), E(22, 10, X, 1), E(22, 5, '+', 5), E(22, 2, X, 6)], e: [20, 'lemon'], err: [E(26, 10, X, 7, '=', 17), 'هذا حلّ سامي.'] }),
  ] },
  { t: 'جدول ٥', pages: u => [
    P(`${H('×٥ = نصف ×١٠', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.85"><b>هيّا نلعب:</b> اليد فيها ٥ أصابع. كم إصبعاً في ٦ أيادٍ؟ نعدّ: ٥، ١٠، ١٥… ونلاحظ أنّ ٥ × ٦ نصف ١٠ × ٦.</div>
      ${grid(2, [3, 4, 6, 7, 8, 9].map(g => `<div style="flex:1;height:24mm">${groups(g, 5, { color: '#16A34A' })}</div>${E(17, g, X, 5, '=', '_')}`), 'fill')}`),
    P(`${H('الساعةُ وجدول ٥', tagU(u, 1))}<div style="font-size:12pt">كلّ رقم في الساعة يعني ٥ دقائق. أكتب كم دقيقة عند كلّ رقم.</div>
      <div style="display:flex;gap:6mm;flex:1;min-height:0;align-items:center"><div style="flex:1;height:100%">${svg('0 0 300 300', `<circle cx="150" cy="150" r="140" fill="#FFF8DC" stroke="#111" stroke-width="5"/>${Array.from({ length: 12 }, (_, i) => { const a = ((i + 1) / 12) * Math.PI * 2 - Math.PI / 2; return `<text x="${150 + 112 * Math.cos(a)}" y="${160 + 112 * Math.sin(a)}" text-anchor="middle" font-family="Cairo" font-weight="800" font-size="26">${hd(i + 1)}</text><rect x="${150 + 78 * Math.cos(a) - 15}" y="${150 + 78 * Math.sin(a) - 11}" width="30" height="22" rx="4" fill="#fff" stroke="#16A34A" stroke-width="2"/>`; }).join('')}<circle cx="150" cy="150" r="6" fill="#111"/><line x1="150" y1="150" x2="150" y2="60" stroke="#111" stroke-width="5"/>`)}</div></div>`),
    P(`${H('×٥ من ×١٠', tagU(u, 2))}<div style="font-size:12pt">أجد ×١٠ أوّلاً، ثمّ آخذ نصفه.</div>${grid(2, [4, 6, 8, 3, 7, 9, 5, 10].map(n => `<span style="font-size:16pt;line-height:2.1">${eq(10, X, n, '=', '_')}<br>${eq(5, X, n, '=', '_')}</span>`), 'fill')}`),
    drillFor(u, [5, 2, 10], 'تمرينُ دقيقة: ×٥ و×٢ و×١٠'),
    K.wordProblems('مسائل ×٥', tagU(u, 4), [['ثمن القلم ٥ دنانير. كم ثمن ٧ أقلام؟', barMul(7, 5)], ['في كلّ زهرة ٥ بتلات. كم بتلة في ٦ زهرات؟', barMul(6, 5)], ['تمشي سارة ٥ دقائق إلى بيت جدّتها. كم دقيقة في ٤ مرّات؟', barMul(4, 5)], ['في الفريق ٥ لاعبين. كم لاعباً في ٨ فرق؟', barMul(8, 5)]]),
    K.think(u, '×٥', { w: [E(22, 5, X, 4), E(22, 5, X, 6), E(22, 5, X, 8), E(22, 5, X, 7)], e: [25, 'star'], err: [E(26, 5, X, 6, '=', 35), 'هذا حلّ سامي.'] }),
  ] },
  { t: 'جدول ٤', pages: u => [
    P(`${H('×٤ = أضاعفُ مرّتين', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.85"><b>هيّا نلعب:</b> للسيّارة ٤ عجلات. لنحسب ٤ × ٦: نضاعف ٦ فتصير ١٢، ثمّ نضاعف ١٢ فتصير ٢٤.</div>
      ${grid(2, [3, 5, 6, 7].map(n => `${ar(4, n, { split: 2 }, '45%', '26mm')}<span style="font-size:15pt;line-height:2.1">${eq(2, X, n, '=', '_')}<br>${eq(4, X, n, '=', '_', '+', '_', '=', '_')}</span>`), 'fill')}`),
    P(`${H('مضاعفُ المضاعف', tagU(u, 1))}<table style="font-size:16pt"><thead><tr style="height:11mm"><th>العدد</th><th>أضاعفه (×٢)</th><th>أضاعفه مرّة أخرى (×٤)</th></tr></thead><tbody>${[3, 4, 5, 6, 7, 8, 9, 10].map(v => `<tr style="height:20mm"><td style="font-weight:900;font-size:22pt">${hd(v)}</td><td></td><td></td></tr>`).join('')}</tbody></table>`),
    factsTable(u, 2, 4, 'أضاعف العدد، ثمّ أضاعف الناتج.'),
    drillFor(u, [4, 2], 'تمرينُ دقيقة: ×٤ و×٢'),
    K.wordProblems('مسائل ×٤', tagU(u, 4), [['للكرسيّ ٤ أرجل. كم رجلاً لـ ٦ كراسٍ؟', barMul(6, 4)], ['في الأسبوع ٤ حصص رياضة. كم حصّة في ٥ أسابيع؟', barMul(5, 4)], ['في كلّ طاولة ٤ تلاميذ، وفي الصفّ ٧ طاولات. كم تلميذاً؟', barMul(7, 4)], ['ثمن الكعكة ٤ دنانير. كم ثمن ٩ كعكات؟', barMul(9, 4)]]),
    K.think(u, '×٤', { w: [E(22, 4, X, 3), E(22, 2, X, 6), E(22, 3, X, 4), E(22, 4, X, 4)], e: [24, 'apple'], err: [E(26, 4, X, 7, '=', 14), 'هذا حلّ سامي. ماذا نسي؟'] }),
  ] },
  { t: 'جدول ٩', pages: u => [
    P(`${H('حيلةُ الأصابع لجدول ٩', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.85"><b>هيّا نلعب:</b> أفتح أصابعي العشرة. لأحسب ٩ × ٤ أثني الإصبع الرابع: يسار المثنيّ ٣ أصابع (عشرات) ويمينه ٦ (آحاد)، فالناتج ٣٦.</div>
      <div style="flex:1;min-height:0">${svg('0 0 1000 420', Array.from({ length: 10 }, (_, i) => { const x = 60 + i * 95 + (i > 4 ? 30 : 0), bent = i === 3; return `<rect x="${x}" y="${bent ? 230 : 60}" width="60" height="${bent ? 90 : 260}" rx="30" fill="${bent ? '#FCA5A5' : i < 3 ? '#93C5FD' : '#FDBA74'}" stroke="#111" stroke-width="4"/><text x="${x + 30}" y="380" text-anchor="middle" font-family="Cairo" font-weight="800" font-size="34">${hd(i + 1)}</text>`; }).join('') + `<text x="180" y="40" text-anchor="middle" font-family="Cairo" font-weight="900" font-size="36" fill="#1E40AF">٣ عشرات</text><text x="700" y="40" text-anchor="middle" font-family="Cairo" font-weight="900" font-size="36" fill="#C2410C">٦ آحاد</text>`)}</div>
      <div style="font-size:12.5pt;text-align:center;font-weight:700">ملاحظة: الأصابع مرسومة كما يراها التلميذ أمامه، والإصبع الأوّل على اليسار.</div>`),
    P(`${H('أنماطُ جدول ٩', tagU(u, 1))}<div style="font-size:12pt">٩ × العدد = ١٠ × العدد ناقص العدد. وأرقام الناتج مجموعها ٩!</div>
      ${grid(2, [3, 4, 6, 7, 8, 9].map(n => `<span style="font-size:15pt;line-height:2.1">${eq(10, X, n, '=', '_')}<br>${eq(9, X, n, '=', '_', '−', n, '=', '_')}</span>`), 'fill')}`),
    factsTable(u, 2, 9, 'أستعمل حيلة الأصابع أو: ١٠ × العدد ثمّ أطرح العدد.'),
    drillFor(u, [9, 5, 10], 'تمرينُ دقيقة: ×٩ مع ما تعلّمته'),
    K.wordProblems('مسائل ×٩', tagU(u, 4), [['في كلّ علبة ٩ حلويات. كم حلوى في ٣ علب؟', barMul(3, 9)], ['في كلّ صفّ ٩ مقاعد، وفي القاعة ٥ صفوف. كم مقعداً؟', barMul(5, 9)], ['يقرأ حسن ٩ صفحات يوميّاً. كم يقرأ في ٧ أيّام؟', barMul(7, 9)], ['ثمن التذكرة ٩ دنانير. كم ثمن ٦ تذاكر؟', barMul(6, 9)]]),
    K.think(u, '×٩', { w: [E(22, 9, X, 2), E(22, 9, X, 5), E(22, 10, X, 9), E(22, 9, X, 4)], e: [27, 'ball'], err: [E(26, 9, X, 6, '=', 56), 'هذا حلّ سامي.'] }),
  ] },
  { t: 'جدولا ٣ و٦', pages: u => [
    P(`${H('×٣ = ×٢ وزيادة مجموعة', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.85"><b>هيّا نلعب:</b> للمثلّث ٣ أضلاع. ٣ × ٧: أعرف ٢ × ٧ = ١٤، وأضيف ٧ فيصير ٢١. و×٦ هو ضعف ×٣!</div>
      ${grid(2, [4, 6, 7, 8].map(n => `${ar(3, n, { split: 2 }, '45%', '22mm')}<span style="font-size:15pt;line-height:2.1">${eq(2, X, n, '+', n, '=', '_')}<br>${eq(3, X, n, '=', '_')}</span>`), 'fill')}`),
    P(`${H('×٦ = ضعفُ ×٣، أو ×٥ وزيادة', tagU(u, 1))}${grid(2, [4, 6, 7, 8].map(n => `${ar(6, n, { split: 5 }, '45%', '32mm')}<span style="font-size:15pt;line-height:2.1">${eq(5, X, n, '+', n, '=', '_')}<br>${eq(6, X, n, '=', '_')}</span>`), 'fill')}`),
    P(`${H('حقائقُ ×٣ و×٦', tagU(u, 2))}<div style="display:grid;grid-template-columns:1fr 1fr;gap:2.4mm;flex:1;min-height:0">${Array.from({ length: 10 }, (_, i) => i + 1).flatMap(m => [`<div class="cell">${E(20, m, X, 3, '=', '_')}</div>`, `<div class="cell">${E(20, m, X, 6, '=', '_')}</div>`]).join('')}</div>`),
    drillFor(u, [3, 6, 2, 5], 'تمرينُ دقيقة: ×٣ و×٦'),
    K.wordProblems('مسائل ×٣ و×٦', tagU(u, 4), [['في الأسبوع ٦ أيّام دراسة. كم يوماً في ٤ أسابيع؟', barMul(4, 6)], ['لكلّ مثلّث ٣ أضلاع. كم ضلعاً لـ ٨ مثلّثات؟', barMul(8, 3)], ['في كلّ صندوق ٦ عصائر. كم عصيراً في ٧ صناديق؟', barMul(7, 6)], ['تأكل الأسرة ٣ أرغفة في كلّ وجبة. كم رغيفاً في ٩ وجبات؟', barMul(9, 3)]]),
    K.think(u, '×٣ و×٦', { w: [E(22, 3, X, 6), E(22, 6, X, 3), E(22, 2, X, 9), E(22, 6, X, 4)], e: [26, 'lemon'], err: [E(26, 6, X, 7, '=', 36), 'هذا حلّ سامي.'] }),
  ] },
  { t: 'جدولا ٧ و٨', pages: u => [
    P(`${H('أفكّكُ لأضرب ×٧', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.85"><b>هيّا نلعب:</b> لا نحفظ ٧ × ٦ وحدها! نقطع المصفوفة: ٥ × ٦ = ٣٠، و٢ × ٦ = ١٢، فالمجموع ٤٢.</div>
      ${grid(2, [6, 7, 8, 9].map(n => `${ar(7, n, { split: 5 }, '45%', '34mm')}<span style="font-size:14pt;line-height:2.1">${eq(5, X, n, '=', '_')}<br>${eq(2, X, n, '=', '_')}<br>${eq(7, X, n, '=', '_')}</span>`), 'fill')}`),
    P(`${H('×٨ = أضاعفُ ثلاث مرّات', tagU(u, 1))}<div style="font-size:12pt">٨ × ٧: أضاعف ٧ ← ١٤ ← ٢٨ ← ٥٦. أو: ٤ × ٧ ثمّ أضاعف.</div>
      <table style="font-size:16pt"><thead><tr style="height:11mm"><th>العدد</th><th>×٢</th><th>×٤</th><th>×٨</th></tr></thead><tbody>${[3, 4, 5, 6, 7, 8, 9].map(v => `<tr style="height:21mm"><td style="font-weight:900;font-size:22pt">${hd(v)}</td><td></td><td></td><td></td></tr>`).join('')}</tbody></table>`),
    P(`${H('الحقائقُ الأخيرة', tagU(u, 2))}<div style="font-size:12pt">بقيت حقائق قليلة فقط لم تتعلّمها! ألوّن في جدول الضرب ما أعرفه، وأحلّ الباقي.</div>
      <div style="display:flex;gap:4mm;flex:1;min-height:0"><div style="flex:1.2">${timesChart({ known: [1, 2, 3, 4, 5, 6, 9, 10] })}</div>
      <div style="flex:1;display:grid;grid-template-columns:1fr;gap:2mm">${[[7, 7], [7, 8], [8, 8], [8, 7], [6, 7], [6, 8], [7, 9], [8, 9]].map(([a, b]) => `<div class="cell">${E(19, a, X, b, '=', '_')}</div>`).join('')}</div></div>`),
    drillFor(u, [7, 8, 6, 9], 'تمرينُ دقيقة: ×٧ و×٨'),
    K.wordProblems('مسائل ×٧ و×٨', tagU(u, 4), [['في الأسبوع ٧ أيّام. كم يوماً في ٦ أسابيع؟', barMul(6, 7)], ['للعنكبوت ٨ أرجل. كم رجلاً لـ ٥ عناكب؟', barMul(5, 8)], ['يدّخر عليّ ٧ دنانير كلّ أسبوع. كم يدّخر في ٨ أسابيع؟', barMul(8, 7)], ['في كلّ صفّ ٨ تلاميذ، وفي القاعة ٧ صفوف. كم تلميذاً؟', barMul(7, 8)]]),
    K.think(u, '×٧ و×٨', { w: [E(22, 7, X, 8), E(22, 8, X, 7), E(22, 56, '÷', 7), E(22, 7, X, 7)], e: [28, 'star'], err: [E(26, 7, X, 8, '=', 54), 'هذا حلّ سامي.'] }),
  ] },
  { t: 'القسمة: توزيع وتجميع', pages: u => [
    P(`${H('أوزّعُ بالتساوي', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.85"><b>هيّا نلعب:</b> نوزّع ١٢ تمرة على ٣ أطفال بالتساوي: واحدة لكلّ طفل، ثمّ واحدة، حتى تنتهي. كم لكلّ طفل؟ ١٢ ÷ ٣ = ٤.</div>
      ${rows([[12, 3], [10, 2], [15, 5], [8, 4], [18, 3]].map(([t, g]) => `<span style="font-size:13pt;font-weight:800;white-space:nowrap">أوزّع ${hd(t)} على ${hd(g)}</span><div style="flex:1;height:22mm">${groups(g, 0, { blankDots: true })}</div>${E(16, t, D, g, '=', '_')}`))}`),
    P(`${H('أجمّعُ في مجموعات', tagU(u, 1))}<div style="font-size:12pt">معي ١٥ قلماً، وأضع كلّ ٥ في علبة. كم علبة أحتاج؟ أحيط كلّ مجموعة بدائرة.</div>
      ${rows([[15, 5, 'star'], [12, 4, 'apple'], [18, 6, 'ball'], [14, 2, 'lemon'], [20, 5, 'star']].map(([t, n, im]) => `<div style="flex:1;height:20mm">${objects(t, im, 10)}</div><span style="font-size:12pt;font-weight:800;white-space:nowrap">كلّ ${hd(n)} معاً</span>${E(16, t, D, n, '=', '_')}`))}`),
    P(`${H('أقسمُ بالمصفوفة', tagU(u, 2))}<div style="font-size:12pt">المصفوفة تساعدني في القسمة: ٢٠ نقطة في ٤ صفوف، فكم في كلّ صفّ؟</div>${grid(2, [[4, 5], [3, 6], [2, 7], [5, 3], [6, 4], [3, 8]].map(([r, c]) => `${ar(r, c, {}, '50%', '26mm')}${E(17, r * c, D, r, '=', '_')}`), 'fill')}`),
    K.fluency('كم لكلّ واحد؟', tagU(u, 3), Array.from({ length: 12 }, () => { const g = rnd(2, 5), n = rnd(2, 5); return `<div style="display:flex;flex-direction:column;align-items:center;gap:1mm;width:100%">${ar(g, n, {}, '70%', '18mm')}${E(15, g * n, D, g, '=', '_')}</div>`; }), 3),
    K.wordProblems('مسائل التوزيع', tagU(u, 4), [['وزّعت المعلّمة ٢٤ قلماً على ٤ مجموعات بالتساوي. كم قلماً لكلّ مجموعة؟', barMul(4, 6, { unknown: 'part' }).replace('>?<', `>${hd(24)}<`)], ['عندي ١٨ بيضة، وأضع كلّ ٦ في علبة. كم علبة أحتاج؟', barMul(3, 6).replace('>?<', `>${hd(18)}<`)], ['قسّم الأب ٣٠ ديناراً على ٥ أبناء بالتساوي. كم لكلّ ابن؟', barMul(5, 6, { unknown: 'part' }).replace('>?<', `>${hd(30)}<`)], ['في الحافلة ٢٠ تلميذاً، يجلس كلّ ٢ في مقعد. كم مقعداً؟', barMul(10, 2, { showN: true }).replace('>?<', `>${hd(20)}<`)]]),
    K.think(u, 'القسمة', { w: [E(22, 12, D, 3), E(22, 12, D, 4), E(22, 3, X, 4), E(22, 12, D, 2)], e: [24, 'apple'], err: [E(26, 15, D, 3, '=', 12), 'هذا حلّ سامي.'] }),
  ] },
  { t: 'القسمة والضرب عائلة واحدة', pages: u => [
    P(`${H('عائلةُ الضرب والقسمة', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.85"><b>هيّا نلعب:</b> المصفوفة الواحدة تعطيني أربع جمل: جملتي ضرب وجملتي قسمة.</div>
      ${grid(2, [[3, 4], [2, 6], [4, 5], [3, 7]].map(([r, c]) => `${ar(r, c, {}, '45%', '24mm')}<span style="font-size:14pt;line-height:1.9">${eq(r, X, c, '=', '_')}<br>${eq(c, X, r, '=', '_')}<br>${eq(r * c, D, r, '=', '_')}<br>${eq(r * c, D, c, '=', '_')}</span>`), 'fill')}`),
    P(`${H('أقسمُ بالتفكير في الضرب', tagU(u, 1))}<div style="font-size:12pt">٣٥ ÷ ٥ = ؟ أسأل: ٥ × كم = ٣٥؟</div>${grid(2, [[35, 5], [24, 4], [42, 6], [27, 9], [56, 8], [30, 3], [49, 7], [40, 10]].map(([a, b]) => `<span style="font-size:16pt;line-height:2.1">${eq(a, D, b, '=', '_')}<br>${eq(b, X, '_', '=', a)}</span>`), 'fill')}`),
    P(`${H('مثلّثاتُ الحقائق', tagU(u, 2))}<div style="font-size:12pt">العدد في الأعلى هو الناتج. أغطّي عدداً وأجده من الآخرين، وأكتب الجمل الأربع.</div>
      ${grid(3, [[24, 4, 6], [36, 9, 4], [30, 5, 6], [21, 3, 7], [48, 8, 6], [45, 9, 5]].map(([p, a, b], i) => `<div style="width:100%;height:100%">${svg('0 0 200 170', `<path d="M100 8 L192 160 H8Z" fill="#F5F3FF" stroke="#4C1D95" stroke-width="5" stroke-linejoin="round"/><line x1="40" y1="110" x2="160" y2="110" stroke="#4C1D95" stroke-width="3"/><text x="100" y="92" text-anchor="middle" font-family="Cairo" font-weight="900" font-size="36">${i % 3 === 0 ? '?' : hd(p)}</text><text x="${i % 3 === 1 ? 65 : 65}" y="148" text-anchor="middle" font-family="Cairo" font-weight="800" font-size="30">${i % 3 === 1 ? '?' : hd(a)}</text><text x="135" y="148" text-anchor="middle" font-family="Cairo" font-weight="800" font-size="30">${i % 3 === 2 ? '?' : hd(b)}</text><text x="100" y="148" text-anchor="middle" font-family="Cairo" font-weight="800" font-size="22">${X}</text>`)}</div>`), 'fill')}`),
    K.drill('تمرينُ دقيقة: القسمة', tagU(u, 3), Array.from({ length: 27 }, () => { const b = rnd(2, 10), q = rnd(1, 10); return [b * q, D, b]; })),
    K.wordProblems('مسائل الضرب والقسمة', tagU(u, 4), [['في كلّ صفّ ٦ كراسٍ، وفي القاعة ٤٢ كرسيّاً. كم صفّاً؟', barMul(7, 6, { showN: true }).replace('>?<', `>${hd(42)}<`)], ['اشترت أمّي ٤ علب، في كلّ علبة ٨ قطع بسكويت. كم قطعة؟', barMul(4, 8)], ['وزّع المدرّب ٣٦ كرة على ٤ فرق بالتساوي. كم كرة لكلّ فريق؟', barMul(4, 9, { unknown: 'part' }).replace('>?<', `>${hd(36)}<`)], ['يحتاج كلّ طفل ٣ أوراق. كم ورقة لـ ٩ أطفال؟', barMul(9, 3)]]),
    K.think(u, 'عائلة الحقائق', { w: [E(20, 4, X, 6, '=', 24), E(20, 24, D, 6, '=', 4), E(20, 6, X, 4, '=', 24), E(20, 24, D, 3, '=', 6)], e: [30, 'ball'], err: [E(26, 42, D, 6, '=', 6), 'هذا حلّ سامي.'] }),
  ] },
  { t: 'مسائل الضرب والقسمة', pages: u => [
    P(`${H('أيُّ عمليّة؟', tagU(u, 0))}<div class="sec" style="font-size:12.5pt;line-height:1.85"><b>هيّا نلعب:</b> نمثّل المسألة بالأغطية أوّلاً: هل نضع مجموعات متساوية معاً (ضرب)، أم نقسّم شيئاً بالتساوي (قسمة)، أم نضمّ (جمع)، أم نأخذ (طرح)؟</div>
      ${grid(2, ['في كلّ كيس ٥ برتقالات، وعندنا ٤ أكياس.', 'عندي ٢٠ برتقالة أضعها في ٤ أكياس بالتساوي.', 'عندي ٢٠ برتقالة، أكلنا منها ٤.', 'عندي ٢٠ برتقالة، واشترينا ٤.', 'في الصفّ ٥ صفوف، في كلّ صفّ ٦ تلاميذ.', 'عندي ٣٠ تلميذاً في ٥ صفوف متساوية.'].map(t => `<span style="font-size:13pt;font-weight:700;line-height:1.7;flex:1">${t}</span><span style="display:flex;gap:1.5mm;font-size:20pt;font-weight:900">${['+', '−', X, D].map(o => `<span style="width:10mm;height:10mm;border:.5mm solid #111;border-radius:50%;display:inline-flex;align-items:center;justify-content:center">${o}</span>`).join('')}</span>`), 'fill')}`),
    K.wordProblems('مسائلُ الأشرطة', tagU(u, 1), [['في البستان ٨ صفوف، في كلّ صفّ ٧ نخلات. كم نخلة؟', barMul(8, 7)], ['وزّع الفلّاح ٤٥ رمّانة على ٥ صناديق بالتساوي. كم في كلّ صندوق؟', barMul(5, 9, { unknown: 'part' }).replace('>?<', `>${hd(45)}<`)], ['ثمن الكتاب ٩ دنانير. كم ثمن ٦ كتب؟', barMul(6, 9)], ['في كلّ مجموعة ٤ تلاميذ، وفي الصفّ ٢٨ تلميذاً. كم مجموعة؟', barMul(7, 4).replace('>?<', `>${hd(28)}<`)]]),
    K.wordProblems('مسائلُ من خطوتين', tagU(u, 2), [['اشترى أبي ٣ علب، في كلّ علبة ٦ أقلام، ثمّ أعطاني ٥. كم بقي معه؟', barMul(3, 6)], ['في الحفل ٤ طاولات، على كلّ طاولة ٨ صحون، وجاءت ٧ صحون أخرى. كم صحناً؟', barMul(4, 8)], ['معي ٥٠ ديناراً، اشتريت ٤ دفاتر ثمن كلّ دفتر ٩. كم بقي؟', barMul(4, 9)], ['وزّعنا ٢٤ تفّاحة على ٦ أطفال، ثمّ أعطينا كلّ طفل تفّاحة أخرى. كم مع كلّ طفل؟', barMul(6, 4, { unknown: 'part' }).replace('>?<', `>${hd(24)}<`)]]),
    K.drill('تمرينُ دقيقة: كلّ الحقائق', tagU(u, 3), Array.from({ length: 27 }, () => { const a = rnd(2, 10), b = rnd(2, 10); return rnd(0, 2) ? [a, X, b] : [a * b, D, a]; })),
    P(`${H('أؤلّفُ مسألتي', tagU(u, 4))}<div style="font-size:12pt">أكتب مسألة من حياتي لكلّ جملة، وأرسم شريطها، ثمّ أعطيها لصديقي ليحلّها.</div>
      ${rows([[4, X, 5], [24, D, 6], [3, X, 9]].map(p => `${E(20, ...p, '=', '_')}<div style="flex:1;display:flex;flex-direction:column;gap:2mm;height:90%"><div style="border-bottom:.5mm solid #111;flex:1"></div><div style="border-bottom:.5mm solid #111;flex:1"></div><div style="border:.4mm dashed #111;border-radius:2mm;flex:1.4;background:#fff"></div></div>`))}`),
    K.think(u, 'المسائل', { w: [E(18, 4, X, 6), E(18, 24, D, 4), E(18, 6, '+', 4), E(18, 24, D, 6)], e: [30, 'star'], e2: null, err: [`<span style="font-size:12pt;font-weight:700;line-height:1.7">«في كلّ علبة ٦ أقلام، وعندي ٤ علب»<br>حلّ سامي:</span>${E(24, 6, '+', 4, '=', 10)}`, 'هل اختار سامي العمليّة الصحيحة؟'] }),
  ] },
];

function review(k, title) {
  const facts = [[2, 5, 10], [2, 5, 10, 4, 9], [2, 3, 4, 5, 6, 9, 10], [2, 3, 4, 5, 6, 7, 8, 9, 10]][k - 1];
  const items = [
    ...Array.from({ length: 3 }, () => ar(rnd(2, 4), rnd(2, 6), {}, '60%', '70%') + box()),
    ...Array.from({ length: 6 }, () => { const n = facts[rnd(0, facts.length - 1)]; return E(19, rnd(2, 10), X, n, '=', '_'); }),
    ...Array.from({ length: k > 2 ? 6 : 3 }, () => { const n = facts[rnd(0, facts.length - 1)], q = rnd(2, 9); return E(19, n * q, D, n, '=', '_'); }),
  ];
  return P(`${H(`مراجعة: ${title}`, `مراجعة ${hd(k)}`)}
  ${grid(3, items.slice(0, 15), 'fill')}
  <div class="sec" style="display:flex;justify-content:space-around;font-size:13pt;font-weight:700;padding:2.5mm"><span>الصحيح: ..... من ${hd(Math.min(items.length, 15))}</span><span>أتقنتُ؟ نعم ☐ لا ☐</span><span>توقيع المعلّم: .........</span></div>`);
}

const PIC = [
  ['قلب', ['..11..11..', '.12211221.', '1222222221', '1222222221', '.12222221.', '..122221..', '...1221...', '....11....'], [['١٠', 'أسود'], ['٢٠', 'أحمر'], ['غيره', 'أبيض']], (c, i) => c === 1 ? ['٢ × ٥', '٥ × ٢', '١٠ × ١'][i % 3] : c === 2 ? ['٢ × ١٠', '٤ × ٥', '١٠ × ٢', '٥ × ٤'][i % 4] : ['٢ × ٣', '٥ × ٣', '٢ × ٧'][i % 3]],
  ['سمكة', ['..........', '..1111...1', '.122221.11', '1232222211', '1222222211', '.122221.11', '..1111...1', '..........'], [['٣٦', 'أسود'], ['١٦', 'برتقاليّ'], ['٩', 'أبيض'], ['غيره', 'أزرق']], (c, i) => c === 1 ? ['٤ × ٩', '٩ × ٤'][i % 2] : c === 2 ? ['٤ × ٤', '٢ × ٨', '٨ × ٢'][i % 3] : c === 3 ? ['٩ × ١', '١ × ٩'][i % 2] : ['٥ × ٥', '٢ × ٩', '١٠ × ٤'][i % 3]],
  ['شجرة', ['...1111...', '..122221..', '.12222221.', '.12222221.', '..122221..', '....33....', '....33....', '..111111..'], [['١٨', 'أسود'], ['٢٤', 'أخضر'], ['١٢', 'بنّي'], ['غيره', 'أبيض']], (c, i) => c === 1 ? ['٣ × ٦', '٦ × ٣', '٢ × ٩'][i % 3] : c === 2 ? ['٦ × ٤', '٤ × ٦', '٣ × ٨'][i % 3] : c === 3 ? ['٣ × ٤', '٦ × ٢'][i % 2] : ['٣ × ٣', '٦ × ٥', '٢ × ٥'][i % 3]],
  ['بيت', ['....11....', '...1221...', '..122221..', '.12222221.', '1111111111', '1333333331', '1344334431', '1344334431'], [['٥٦', 'أسود'], ['٤٢', 'أحمر'], ['٢٨', 'أصفر'], ['٦٣', 'أزرق'], ['غيره', 'أبيض']], (c, i) => c === 1 ? ['٧ × ٨', '٨ × ٧'][i % 2] : c === 2 ? ['٦ × ٧', '٧ × ٦'][i % 2] : c === 3 ? ['٤ × ٧', '٧ × ٤'][i % 2] : c === 4 ? ['٧ × ٩', '٩ × ٧'][i % 2] : ['٧ × ٧', '٨ × ٨'][i % 2]],
];

function diag(title, tag) {
  return [P(`${H(title, tag)}
    ${sec(1, 'أكتبُ جملة الضرب', grid(1, [[3, 4], [2, 5], [4, 3]].map(([g, n], i) => `<div style="flex:1;height:24mm;min-width:0">${i === 1 ? array(g, n) : groups(g, n)}</div><span style="font-size:16pt;flex:none">${eq('_', X, '_', '=', '_')}</span>`), 26))}
    ${sec(2, 'أعدّ بالقفز', grid(2, [[5, 5], [3, 3]].map(([s, d]) => E(18, s, '،', s + d, '،', '_', '،', '_', '،', '_')), 18))}
    ${sec(3, 'حقائق الضرب', grid(4, [[2, 7], [5, 6], [10, 4], [4, 6], [9, 3], [3, 7], [6, 8], [7, 9]].map(([a, b]) => E(18, a, X, b, '=', '_')), 17), 'grow')}`),
  P(`${H(title, tag)}
    ${sec(4, 'حقائق القسمة', grid(4, [[12, 3], [20, 5], [18, 2], [32, 4], [27, 9], [42, 6], [56, 7], [64, 8]].map(([a, b]) => E(18, a, D, b, '=', '_')), 17))}
    ${sec(5, 'عائلة الحقائق', `<div style="display:flex;gap:6mm;align-items:center">${ar(4, 6, {}, '40%', '26mm')}<div style="flex:1;display:grid;grid-template-columns:1fr 1fr;gap:2mm">${[0, 1, 2, 3].map(() => `<div style="display:flex;gap:1.5mm;align-items:center">${box(10, 9)}<b>○</b>${box(10, 9)}<b>=</b>${box(10, 9)}</div>`).join('')}</div></div>`)}
    ${sec(6, 'مسألتان', `<div style="font-size:13pt;font-weight:700;line-height:2.3">في كلّ علبة ${hd(6)} أقلام، وعندي ${hd(5)} علب. كم قلماً؟ ${box(16, 10)}<br>وزّعنا ${hd(28)} تمرة على ${hd(4)} أطفال بالتساوي. كم لكلّ طفل؟ ${box(16, 10)}</div>`, 'grow')}
    <div class="sec" style="display:flex;justify-content:space-around;font-size:13pt;font-weight:700;padding:2.5mm"><span>المجموع: ..... من ${hd(30)}</span><span>التاريخ: ..../..../........</span></div>`)];
}

function chartPage() {
  return P(`${H('جدولُ الضرب: أكتشفُ وألوّن', 'أداة')}
  <div style="font-size:12pt">كلّما أتقنتُ جدولاً ألوّن صفّه وعموده. ماذا ألاحظ؟ ٣ × ٤ و٤ × ٣ في مكانين، فما أحتاج لحفظه أقلّ ممّا أظنّ!</div>
  <div style="flex:1;min-height:0">${timesChart({ hideAll: true })}</div>`);
}

function bingo() {
  const nums = shuffle([4, 6, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 24, 25, 27, 28, 30, 32, 35, 36, 40, 42, 45, 48, 49, 54, 56, 63, 64, 72, 81], 5);
  const card = k => `<div style="display:grid;grid-template-columns:repeat(4,1fr);grid-auto-rows:1fr;gap:1.5mm;height:100%">${nums.slice(k * 7, k * 7 + 16).concat(nums).slice(0, 16).map(v => `<div class="cell" style="font-size:20pt;font-weight:900">${hd(v)}</div>`).join('')}</div>`;
  return P(`${H('لعبة «بنغو الضرب»', 'لعبة')}
  <div class="sec" style="font-size:12pt;line-height:1.8"><b>طريقة اللعب:</b> يقرأ المعلّم مسألة ضرب (مثلاً ٦ × ٧). من يجد الناتج في بطاقته يضع عليه غطاءً. أوّل من يكمل صفّاً أو عموداً يقول «بنغو!» ويشرح كيف حسب.</div>
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:5mm;flex:1;min-height:0">${[0, 1].map(k => `<div class="sec" style="display:flex;flex-direction:column"><div class="t"><i>${hd(k + 1)}</i><span>بطاقة اللاعب ${hd(k + 1)}</span></div><div style="flex:1">${card(k)}</div></div>`).join('')}</div>`);
}

async function build(out) {
  K.reset();
  const pages = [K.title('المستوى الثالث', 'أضرب وأقسم', `<div style="display:flex;gap:4mm;height:100%;align-items:center"><div style="flex:1;height:100%">${array(3, 6, { split: 2 })}</div><div style="flex:1.3">${barMul(4, 5)}</div></div>`),
    ...K.parentPages('الضرب والقسمة بالفهم: المجموعات المتساوية، والمصفوفات، وحقائق الضرب بالحيل والاستراتيجيّات، والقسمة توزيعاً وعكساً للضرب، والمسائل', ['عدّ الأرجل والعجلات والأصابع بالقفز.', 'علبة البيض مصفوفة: كم بيضة؟', 'توزيع الحلوى على الإخوة بالتساوي.', 'سؤال يوميّ من حقيقة ضرب واحدة: «كيف عرفتها؟»'], ['حقائق دقيقة', 'ركن الأهل', 'حيلة جديدة', 'مسألة من البيت']),
    K.guide('يعالج هذا المستوى أكبر شكوى عند المعلّمين والأهل: <b>«لا يحفظ جدول الضرب»</b>. السبب غالباً أنّ التلميذ يحفظ ١٠٠ حقيقة منفصلة دون فهم. هنا يفهم الضرب أوّلاً (مجموعات ومصفوفات)، ثمّ يتعلّم الحقائق <b>بترتيب الاستراتيجيّات</b> لا بترتيب الأرقام: ٢ و٥ و١٠، ثمّ ٤ (مضاعف المضاعف)، ثمّ ٩ (حيلة)، ثمّ ٣ و٦، ثمّ ٧ و٨ بالتفكيك. المرجع: دليل IES للمتعثّرين (٢٠٢١).',
      [['ابدأ بالتشخيص', 'من لا يفهم «المجموعات المتساوية» يبدأ من الوحدة ١ مهما كان صفّه.'], ['ستّ مراحل لكلّ وحدة', 'محسوس ← مصوّر ← مجرّد ← طلاقة ← تطبيق ← تحدّي التفكير.'], ['المصفوفة أداة أساسيّة', 'تشرح الإبدال (٣×٤ = ٤×٣) والتفكيك (٧×٦ = ٥×٦ + ٢×٦) والقسمة.'], ['لا تحفيظ بلا فهم', 'إذا نسي التلميذ حقيقة، يشتقّها من حقيقة يعرفها بدل أن يخمّن.'], ['دقيقة طلاقة', 'بعد الفهم تأتي السرعة. نقارن التلميذ بنفسه فقط.'], ['القسمة عكس الضرب', 'نعلّمها مع الضرب في عائلة واحدة لا كعمليّة منفصلة غامضة.']],
      'أغطية قناني أو حبوب، صحون صغيرة للتوزيع، علبة بيض فارغة، أوراق مربّعات لرسم المصفوفات.'),
    ...K.numberTalks([E(26, 6, X, 4), E(26, 9, X, 7), `<div style="width:44mm;height:28mm">${array(4, 7, { split: 2 })}</div>`, E(26, 8, X, 6), E(26, 42, D, 6), E(24, 5, X, 14), E(26, 7, X, 7), E(24, 25, X, 4), E(26, 63, D, 9)]),
    ...diag('الاختبار التشخيصي', 'قبل البدء'), K.tracker(UNITS.map(u => u.t)),
    K.adventureMap(['المجموعات', 'المصفوفات', 'العدّ بالقفز', '×٢ و×١٠', '×٥', '×٤', '×٩', '×٣ و×٦', '×٧ و×٨', 'التوزيع', 'عائلة الحقائق', 'المسائل']), chartPage()];
  const RV = { 2: 'الوحدات ١–٣', 5: 'الوحدات ١–٦', 8: 'الوحدات ١–٩', 11: 'الوحدات ١–١٢' };
  UNITS.forEach((u, i) => {
    pages.push(...u.pages(i + 1));
    if (RV[i]) { const k = Object.keys(RV).indexOf(String(i)) + 1; pages.push(review(k, RV[i]), K.colorByAnswer(...PIC[k - 1])); }
  });
  pages.push(bingo(), ...diag('الاختبار البعدي', 'نهاية المستوى'));
  let pad = 0;
  const MIX = [['تمرينٌ شامل: الضرب', () => [rnd(2, 10), X, rnd(2, 10)]], ['تمرينٌ شامل: القسمة', () => { const b = rnd(2, 10), q = rnd(2, 10); return [b * q, D, b]; }]];
  while ((pages.length + 1) % 4) { const [t, f] = MIX[pad++ % 2]; pages.push(K.drill(t, 'طلاقة', Array.from({ length: 27 }, f))); }
  pages.push(K.certificate('المستوى الثالث', 'لإتقانه الضرب والقسمة بالفهم', `<div style="display:flex;gap:6mm;height:100%;justify-content:center"><div style="width:50mm">${array(3, 6, { split: 2 })}</div><div style="width:60mm">${barMul(3, 6)}</div></div>`));
  await K.render(pages, out);
  return pages.length;
}
module.exports = { build };
if (require.main === module) build(path.join(ROOT, 'output/math3-interior.pdf')).then(c => console.log('pages', c));
