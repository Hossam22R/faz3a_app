// عُدّة مشتركة لمستويات «أحسب بثقة» (٢–٤): نفس نظام التصميم المعتمد في المستوى الأول
const R = '../../arabic-reading-levels/src/';
const { hd, shuffle, page, sec, renderPDF } = require(R + 'common');
const { pic } = require(R + 'pics');
const X = require(R + 'extra');
const MT = require('./mtheme');
const M = require('./mlib');
const { eq, svg, face, scatter, tenFrame, dots, bond } = M;

function makeKit(LV, GOALS) {
  let n = 0;
  const toSami = h => h.replace(/<div style="font-size:1(?:2|1\.5)pt">(.*?)<\/div>/g, (_, t) => MT.sami(t))
    .replace(/<div class="sec" style="font-size:12\.5pt;line-height:1\.8(?:5)?">(.*?)<\/div>/g, (_, t) => MT.sami(t));
  const K = {};
  K.reset = () => (n = 0);
  K.P = inner => page(toSami(inner), { n: ++n, level: LV, series: 'سلسلة أحسب بثقة' });
  K.H = (t, tag) => {
    const m = /^U(\d+)\|S(\d+)$/.exec(tag);
    if (m) return MT.mheader(t, { unit: +m[1], stage: +m[2], goal: GOALS[+m[1] - 1] });
    return MT.mheader(t, { tag, review: tag.startsWith('مراجعة') });
  };
  K.tagU = (u, k) => `U${u}|S${k}`;
  K.box = (w = 13, h = 12) => `<span style="display:inline-block;width:${w}mm;height:${h}mm;border:.5mm solid #111;border-radius:2mm;flex:none;background:#fff"></span>`;
  K.big = (t, pt = 26) => `<span style="font-weight:800;font-size:${pt}pt;line-height:1">${t}</span>`;
  K.E = (pt, ...parts) => `<span style="font-size:${pt}pt">${eq(...parts)}</span>`;
  K.parent = t => `<div class="parent"><b>ركن الأهل:</b><span>${t}</span></div>`;
  K.timer = (label = 'صحيحة في دقيقة') => `<div class="row" style="font-size:11pt;font-weight:700">${[1, 2, 3].map(k => `<div class="cell" style="height:11mm">المحاولة ${hd(k)}: ..... ${label}</div>`).join('')}</div>`;
  K.grid = (cols, items, h, gap = 2.6) => h === 'fill'
    ? `<div style="display:grid;grid-template-columns:repeat(${cols},minmax(0,1fr));grid-auto-rows:1fr;gap:${gap}mm;flex:1;min-height:0">${items.map(it => `<div class="cell" style="padding:1.5mm;gap:2mm;min-height:0;min-width:0;overflow:hidden">${it}</div>`).join('')}</div>`
    : `<div style="display:grid;grid-template-columns:repeat(${cols},minmax(0,1fr));gap:${gap}mm">${items.map(it => `<div class="cell" style="height:${h}mm;padding:1.5mm;gap:2mm;min-width:0">${it}</div>`).join('')}</div>`;
  K.rows = (items, h = 'fill') => `<div style="display:flex;flex-direction:column;gap:3mm;${h === 'fill' ? 'flex:1;min-height:0' : ''}">${items.map(it => `<div class="cell" style="${h === 'fill' ? 'flex:1' : `height:${h}mm;flex:none`};gap:4mm;padding:0 5mm;min-height:0">${it}</div>`).join('')}</div>`;

  K.drill = (title, tag, list, pt = 21) => K.P(`${K.H(title, tag)}
    <div style="font-size:11.5pt">دقيقة واحدة: أحلّ أكبر عدد من المسائل، ثمّ أصحّح مع المعلّم وأحاول أن أتحسّن.</div>
    <div style="display:grid;grid-template-columns:repeat(3,minmax(0,1fr));grid-auto-rows:1fr;gap:2.2mm 4mm;flex:1;min-height:0">${list.map(([a, op, b]) => `<div class="cell" style="font-size:${pt}pt;justify-content:center">${eq(a, op, b, '=', '_')}</div>`).join('')}</div>
    ${K.timer()}`);
  K.fluency = (title, tag, items, cols = 6, note = 'يقرأ التلميذ بأسرع ما يستطيع لمدّة دقيقة واحدة، والمعلّم يعدّ الإجابات الصحيحة.') => K.P(`${K.H(title, tag)}
    <div style="font-size:11.5pt">${note}</div>${K.grid(cols, items, 'fill', 2.2)}${K.timer()}`);

  // نماذج الأشرطة (الجزء الأوّل على اليمين)
  const T = (x, y, t) => `<text x="${x}" y="${y}" text-anchor="middle" font-family="Cairo" font-weight="800" font-size="24">${t}</text>`;
  K.barPartWhole = (a, b, whole, unknown = 'whole') => {
    const W = 300, wa = (W * a) / whole, xa = 10 + W - wa;
    const lab = (k, v) => (unknown === k ? '?' : hd(v));
    return svg('0 0 320 110', `<rect x="10" y="10" width="${W}" height="34" rx="4" fill="#FFE08A" stroke="#111" stroke-width="3"/>${T(10 + W / 2, 35, lab('whole', whole))}
      <rect x="${xa}" y="56" width="${wa}" height="34" rx="4" fill="#C9F2D0" stroke="#111" stroke-width="3"/><rect x="10" y="56" width="${W - wa}" height="34" rx="4" fill="#CDEBFF" stroke="#111" stroke-width="3"/>
      ${T(xa + wa / 2, 81, lab('a', a))}${T(10 + (W - wa) / 2, 81, lab('b', b))}`);
  };
  K.barCompare = (big, small, unknown = 'diff') => {
    const W = 300, ws = (W * small) / big;
    return svg('0 0 320 110', `<rect x="10" y="10" width="${W}" height="34" rx="4" fill="#FFE08A" stroke="#111" stroke-width="3"/>${T(10 + W / 2, 35, unknown === 'big' ? '?' : hd(big))}
      <rect x="${10 + W - ws}" y="56" width="${ws}" height="34" rx="4" fill="#CDEBFF" stroke="#111" stroke-width="3"/>${T(10 + W - ws / 2, 81, unknown === 'small' ? '?' : hd(small))}
      <rect x="10" y="56" width="${W - ws}" height="34" rx="4" fill="#fff" stroke="#111" stroke-width="3" stroke-dasharray="6 5"/>${T(10 + (W - ws) / 2, 81, unknown === 'diff' ? '?' : hd(big - small))}`);
  };
  K.wordProblems = (title, tag, probs) => K.P(`${K.H(title, tag)}
    <div style="font-size:11.5pt">أقرأ المسألة، وأنظر إلى الشريط: أين المجهول؟ ثمّ أكتب الجملة العدديّة والجواب.</div>
    <div style="display:flex;flex-direction:column;gap:3mm;flex:1;min-height:0">${probs.map(([t, bar], i) => `<div class="sec" style="flex:1;display:flex;gap:4mm;align-items:center;padding:3mm 4mm">
      <div style="flex:1.35;font-size:13pt;font-weight:700;line-height:1.8"><b>${hd(i + 1)}.</b> ${t}</div>
      <div style="flex:1;height:28mm">${bar}</div>
      <div style="display:flex;flex-direction:column;align-items:center;gap:1.5mm;font-size:10.5pt;font-weight:700">الجملة العدديّة<span style="width:38mm;height:10mm;border:.5mm solid #111;border-radius:2mm;background:#fff"></span>الجواب ${K.box(16, 10)}</div></div>`).join('')}</div>`);

  // تحدّي التفكير
  K.think = (u, unitTitle, t) => K.P(`${K.H(`تحدّي التفكير: ${unitTitle}`, K.tagU(u, 5))}
    ${sec(1, 'أيّها لا ينتمي؟', `<div class="row" style="height:34mm">${t.w.map(x => `<div class="cell" style="padding:1.5mm">${x}</div>`).join('')}</div><div style="font-size:11pt;margin-top:2mm">أضع دائرة حول واحد وأشرح لماذا: ...........................................................</div>`, '', 'لا توجد إجابة واحدة!')}
    <div class="row" style="flex:1;min-height:0">
      ${sec(2, t.e2 ? t.e2[0] : 'أقدّرُ ثمّ أتحقّق', t.e2 ? t.e2[1] : `<div style="height:50mm">${scatter(t.e[0], t.e[1], u + 5)}</div><div class="row" style="font-size:12pt;font-weight:700;margin-top:2mm"><div class="cell" style="height:12mm;gap:2mm">تقديري ${K.box(12, 9)}</div><div class="cell" style="height:12mm;gap:2mm">العدد ${K.box(12, 9)}</div></div>`, 'grow')}
      ${sec(3, 'أكتشفُ خطأ سامي', `<div class="cell" style="height:42mm;flex-direction:column;gap:2mm;padding:2mm"><span style="font-size:12.5pt;font-weight:700">${t.err[1]}</span>${t.err[0]}</div><div style="font-size:11.5pt;margin-top:2mm;line-height:2">صحيح ☐ خطأ ☐ &nbsp; الصواب: ${K.box(18, 9)}</div>`, 'grow')}
    </div>
    ${sec(4, 'كيف أشعرُ بعد هذه الوحدة؟', `<div class="row">${[[2, 'فهمتُ وأستطيع أن أشرح'], [1, 'فهمتُ وأحتاج تدريباً'], [0, 'أحتاج مساعدة']].map(([m, l]) => `<div class="cell" style="height:23mm;gap:3mm"><div style="width:15mm;height:15mm">${face(m)}</div><span style="font-size:11pt;font-weight:700">${l}</span></div>`).join('')}</div>`)}`);

  K.adventureMap = stations => {
    const pts = stations.map((_, i) => { const row = Math.floor(i / 3), col = i % 3, c = row % 2 ? 2 - col : col; return [830 - c * 330, 110 + row * 235]; });
    const path = 'M' + pts.map(p => p.join(' ')).join(' L') + ` L${pts[pts.length - 1][0]} 1000`;
    return K.P(`${K.H('خريطةُ مغامرتي', 'نجاح')}
    <div style="font-size:12pt">كلّما أنهيتُ محطّة ألوّنُها وأرسم فيها نجمة. في نهاية الطريق تنتظرني شهادة الإتقان!</div>
    <div style="flex:1;min-height:0">${svg('0 0 1000 1130', `<path d="${path}" fill="none" stroke="#111" stroke-width="10" stroke-dasharray="4 22" stroke-linecap="round"/>
      ${pts.map(([x, y], i) => `<circle cx="${x}" cy="${y}" r="62" fill="#fff" stroke="${MT.UNIT_COLORS[i]}" stroke-width="9"/><text x="${x}" y="${y + 15}" text-anchor="middle" font-family="Cairo" font-weight="900" font-size="44">${hd(i + 1)}</text>
        <text x="${x}" y="${y + 100}" text-anchor="middle" font-family="Cairo" font-weight="800" font-size="30">${stations[i]}</text>`).join('')}
      <g transform="translate(${pts[pts.length - 1][0]} 1040)"><path d="M-55 -60 H55 V-20 Q55 30 0 34 Q-55 30 -55 -20Z" fill="#FFD43B" stroke="#111" stroke-width="6"/><path d="M-55 -45 Q-95 -45 -85 -10 Q-75 10 -50 8 M55 -45 Q95 -45 85 -10 Q75 10 50 8" fill="none" stroke="#111" stroke-width="6"/><rect x="-14" y="32" width="28" height="22" fill="#FFD43B" stroke="#111" stroke-width="5"/><rect x="-45" y="52" width="90" height="22" rx="4" fill="#8B5A2B" stroke="#111" stroke-width="5"/><text x="0" y="-12" text-anchor="middle" font-family="Cairo" font-weight="900" font-size="24">الشهادة</text></g>`)}</div>`);
  };

  K.numberTalks = images => [K.P(`${K.H('حوار الأعداد: خمس دقائق كلّ يوم', 'للمعلّم')}
    <div class="sec" style="font-size:12.5pt;line-height:1.85">روتين قصير يبني الحساب الذهنيّ: أعرض مسألة، يفكّر التلاميذ بصمت، ثمّ يشرح كلّ واحد <b>كيف</b> حلّ. المهمّ هو الطريقة لا السرعة، ونسجّل الطرق المختلفة على السبّورة.</div>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:3.5mm">${[['أعرض', 'أكتب المسألة على السبّورة أو أعرض صورة من الصفحة التالية.'], ['أفكّر بصمت', 'يضع التلميذ إبهامه على صدره عندما يجد الجواب، ويبحث عن طريقة ثانية.'], ['أشارك', 'يقول عدّة تلاميذ أجوبتهم دون حكم، ثمّ يشرحون طرقهم.'], ['أسجّل', 'أرسم الطرق على خطّ أعداد مفتوح أو بالقطع: «أكملتُ العشرة»، «جمعتُ العشرات أوّلاً».'], ['أشجّع', 'أمدح الطريقة والشرح، وأقبل الخطأ فرصةً للتعلّم.'], ['أكرّر', 'خمس دقائق يوميّاً في بداية الحصّة تكفي.']].map(([t, d], k) => `<div class="sec" style="padding:3mm 4.5mm"><div class="t"><i>${hd(k + 1)}</i><span>${t}</span></div><div style="font-size:11.5pt;line-height:1.7">${d}</div></div>`).join('')}</div>
    ${sec(7, 'أسئلة الحوار', `<div style="font-size:12.5pt;line-height:2">● كيف فكّرت؟ ● من حلّها بطريقة أخرى؟ ● أيّ الطرق أسهل لك؟ لماذا؟ ● كيف نتأكّد؟</div>`, 'grow')}`),
  K.P(`${K.H('مسائل حوار الأعداد', 'للمعلّم')}${K.grid(3, images, 'fill', 4)}`)];

  K.parentPages = (topic, tips, tasks) => [K.P(`${K.H('رسالة إلى الأهل الكرام', 'للأهل')}
    <div class="sec" style="font-size:13pt;line-height:1.95">أولياء الأمور الكرام، تحيّة طيّبة.<br>يتعلّم طفلكم في هذا الكتاب <b>${topic}</b>. الرياضيات تُبنى درجةً درجة، وعشر دقائق يوميّاً من اللعب بالأعداد تصنع فرقاً كبيراً.</div>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:4mm">
      ${sec(1, 'ألعاب بيتيّة', `<div style="font-size:12pt;line-height:1.9">${tips.map(t => `● ${t}`).join('<br>')}</div>`)}
      ${sec(2, 'عبارات تشجيع', `<div style="font-size:12pt;line-height:1.9">● «طريقتك ذكيّة، اشرحها لي».<br>● «أخطأت؟ ممتاز، نتعلّم من الخطأ».<br>● «أنت أسرع من الأمس!»<br>● «هيّا نحسب معاً».</div>`)}
      ${sec(3, 'ما نتجنّبه', `<div style="font-size:12pt;line-height:1.9">● قول «أنا أيضاً كنت ضعيفاً في الرياضيات».<br>● الحفظ دون فهم.<br>● حلّ الواجب عن الطفل.<br>● المقارنة بالآخرين.</div>`)}
      ${sec(4, 'علامات التقدّم', `<div style="font-size:12pt;line-height:1.9">● يشرح طريقته بثقة.<br>● يحسب ذهنيّاً دون أصابع.<br>● يكتشف خطأه بنفسه.<br>● يحبّ التحدّي.</div>`)}
    </div>`),
  K.P(`${K.H('خطّة البيت الأسبوعيّة', 'للأهل')}
    <table style="font-size:11pt"><thead><tr style="height:11mm"><th style="width:24mm">اليوم</th>${tasks.map(t => `<th>${t}</th>`).join('')}<th style="width:28mm">توقيع وليّ الأمر</th></tr></thead>
    <tbody>${['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'].map(d => `<tr style="height:15mm"><td style="font-weight:700">${d}</td>${tasks.map(() => '<td style="font-size:16pt">☐</td>').join('')}<td></td></tr>`).join('')}</tbody></table>
    ${sec(1, 'ملاحظات الأهل للمعلّم', `${X.lineBox(11)}${X.lineBox(11)}${X.lineBox(11)}`, 'grow')}`)];

  K.guide = (intro, steps, materials) => K.P(`${K.H('كيف تستعمل هذا الكتاب؟', 'دليل المعلّم')}
    <div class="sec" style="font-size:12pt;line-height:1.75">${intro}</div>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:3.5mm">${steps.map(([t, d], i) => `<div class="sec" style="padding:3mm 4.5mm"><div class="t"><i>${hd(i + 1)}</i><span>${t}</span></div><div style="font-size:11pt;line-height:1.65">${d}</div></div>`).join('')}</div>
    ${sec(steps.length + 1, 'موادّ بسيطة نحتاجها', `<div style="font-size:11.5pt;line-height:1.8">${materials}</div>`)}
    <div class="parent" style="font-size:11pt"><b>ملاحظة:</b><span>تُكتب الجمل العدديّة وخطّ الأعداد من اليمين إلى اليسار كما في كتابتنا العربيّة.</span></div>`);

  K.tracker = units => K.P(`${K.H('جدول متابعة التقدّم', 'للمعلّم')}
    <table style="font-size:11pt"><thead><tr style="height:11mm"><th style="width:56mm">الوحدة</th><th>محسوس</th><th>مصوّر</th><th>مجرّد</th><th>الطلاقة (صحيحة/دقيقة)</th><th style="width:22mm">التاريخ</th></tr></thead>
    <tbody>${units.map((u, i) => `<tr style="height:16.5mm"><td style="font-weight:700">${hd(i + 1)}. ${u}</td><td></td><td></td><td></td><td></td><td></td></tr>`).join('')}</tbody></table>`);

  K.certificate = (lvName, text, visual) => K.P(`<div style="border:1.4mm double #B45309;border-radius:9mm;flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:7mm;text-align:center;padding:12mm;background:radial-gradient(circle at 50% 30%,#FFF8DC,#fff 60%)">
    <div style="height:40mm;width:40mm">${pic('star', 'pic', true)}</div>
    <div style="font-size:42pt;font-weight:900;color:#B45309">شهادةُ إتقان</div>
    <div style="font-size:20pt;font-weight:700">${lvName} من سلسلة «أحسب بثقة»</div>
    <div style="font-size:16pt;line-height:2.2">تُمنح هذه الشهادة للتلميذ/ة<br>.......................................................................<br>${text}</div>
    <div style="display:flex;gap:30mm;font-size:14pt;margin-top:6mm"><span>المعلّم/ة: ..................</span><span>التاريخ: ..../..../........</span></div>
    <div style="width:140mm;height:34mm">${visual}</div></div>`);

  K.title = (lvName, sub, visual) => K.P(`<div style="border:1.2mm solid #1E3A8A;border-radius:9mm;flex:1;display:flex;flex-direction:column;align-items:center;padding:12mm 10mm;gap:5mm;text-align:center;background:linear-gradient(180deg,#EEF2FB,#fff 40%)">
    <div style="font-size:14pt;font-weight:700;border:.6mm solid #1E3A8A;border-radius:5mm;padding:1mm 6mm;color:#1E3A8A">سلسلة علاج الضعف في الرياضيات</div>
    <div style="font-size:66pt;font-weight:900;line-height:1.15;color:#0f172a">أحسب بثقة</div>
    <div style="font-size:22pt;font-weight:900;background:#1E3A8A;color:#fff;border-radius:6mm;padding:2mm 10mm">${lvName}</div>
    <div style="font-size:18pt;font-weight:700;line-height:1.5">${sub}</div>
    <div style="width:56mm;height:46mm">${pic('monkey', 'pic', true)}</div>
    <div style="width:150mm;height:36mm">${visual}</div>
    <div style="margin-top:auto;width:100%;font-size:15pt;line-height:2.4;text-align:right">اسم التلميذ: ............................................................<br>الصف والشعبة: ......................... المدرسة: ..................................</div></div>`);

  const SW = { 'أسود': '#111', 'أحمر': '#E63946', 'أصفر': '#FFD43B', 'أزرق': '#3B82F6', 'أخضر': '#22C55E', 'بنّي': '#8B5A2B', 'برتقاليّ': '#F97316', 'أبيض': '#fff', 'رماديّ': '#9CA3AF' };
  // لوّن حسب ناتج العمليّة: كلّ مربّع فيه مسألة، وناتجها يحدّد لونه
  K.colorByAnswer = (name, rows, legend, makeQ) => {
    const cells = rows.flatMap((r, y) => [...r].map((c, x) => ({ c, x, y })));
    const W = rows[0].length, Hh = rows.length, s = 84, t = 70;
    const o = cells.map(({ c, x, y }, i) => `<rect x="${(W - 1 - x) * s}" y="${y * t}" width="${s}" height="${t}" fill="#fff" stroke="#475569" stroke-width="1.6"/><text x="${(W - 1 - x) * s + s / 2}" y="${y * t + 44}" text-anchor="middle" font-family="Cairo" font-weight="700" font-size="20" direction="rtl">${makeQ(c === '.' ? 0 : +c, i)}</text>`).join('');
    return K.P(`${K.H(`ألوّنُ حسب الناتج: ${name}`, 'تلوين')}
      <div class="sec" style="display:flex;flex-wrap:wrap;gap:3mm 6mm;justify-content:center;font-size:13pt;font-weight:800">${legend.map(([v, c]) => `<span style="display:inline-flex;align-items:center;gap:2mm"><span style="width:9mm;height:9mm;border-radius:2mm;border:.4mm solid #111;background:${SW[c] || '#fff'}"></span>الناتج ${v} = ${c}</span>`).join('')}</div>
      ${MT.sami('أحلّ المسألة في كلّ مربّع، ثمّ ألوّنه بلون ناتجها، فتظهر صورة مخفيّة!')}
      <div style="flex:1;min-height:0">${svg(`-4 -4 ${W * s + 8} ${Hh * t + 8}`, o)}</div>`);
  };

  K.render = (pages, out) => renderPDF(pages, out, { css: MT.CSS });
  return K;
}

module.exports = { makeKit, M, MT, hd, shuffle, sec, pic };
