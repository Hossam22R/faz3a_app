// المستوى الأول: أتعرّف الحروف وأقرؤها بالحركات القصيرة
const path = require('path');
const { hd, H, hl, shuffle, page, header, sec, renderPDF, ROOT, inkSVG } = require('./common');
const { pic } = require('./pics');
const X = require('./extra');
const LV = 1;

// [الحرف، اسمه، الكلمة المفتاحية، الصورة، [أول، وسط، آخر]، يتصل بما بعده؟]
const L = [
  ['أ', 'الألف', 'أَسَدٌ', 'lion', ['أَخَذَ', 'سَأَلَ', 'قَرَأَ'], false],
  ['ب', 'الباء', 'بَطَّةٌ', 'duck', ['بَلَحٌ', 'جَبَلٌ', 'ذَهَبٌ'], true],
  ['ت', 'التاء', 'تُفَّاحَةٌ', 'apple', ['تَعِبَ', 'كَتَبَ', 'نَبَتَ'], true],
  ['ث', 'الثاء', 'ثَعْلَبٌ', 'fox', ['ثَمَرٌ', 'كَثُرَ', 'حَرَثَ'], true],
  ['ن', 'النون', 'نَحْلَةٌ', 'bee', ['نَزَلَ', 'عِنَبٌ', 'لَبَنٌ'], true],
  ['ي', 'الياء', 'يَدٌ', 'hand', ['يَمَنٌ', 'بَيَاضٌ', 'كُرْسِيٌّ'], true],
  ['ج', 'الجيم', 'جَزَرٌ', 'carrot', ['جَمَلٌ', 'عَجَلَةٌ', 'دَرَجٌ'], true],
  ['ح', 'الحاء', 'حُوتٌ', 'whale', ['حَمَلَ', 'سَحَبَ', 'فَرِحَ'], true],
  ['خ', 'الخاء', 'خَرُوفٌ', 'sheep', ['خَرَجَ', 'أَخَذَ', 'طَبَخَ'], true],
  ['د', 'الدال', 'دُبٌّ', 'bear', ['دَرَسَ', 'هَدَفٌ', 'وَلَدٌ'], false],
  ['ذ', 'الذال', 'ذُرَةٌ', 'corn', ['ذَهَبَ', 'حِذَاءٌ', 'أَخَذَ'], false],
  ['ر', 'الراء', 'رُمَّانَةٌ', 'pomegranate', ['رَسَمَ', 'قَرَأَ', 'قَمَرٌ'], false],
  ['ز', 'الزاي', 'زَرَافَةٌ', 'giraffe', ['زَرَعَ', 'نَزَلَ', 'قَفَزَ'], false],
  ['س', 'السين', 'سَمَكَةٌ', 'fish', ['سَمِعَ', 'رَسَمَ', 'جَلَسَ'], true],
  ['ش', 'الشين', 'شَمْسٌ', 'sun', ['شَرِبَ', 'عَشَرَةٌ', 'عَطِشَ'], true],
  ['ص', 'الصاد', 'صَدَفَةٌ', 'shell', ['صَبَرَ', 'بَصَلٌ', 'قَفَصٌ'], true],
  ['ض', 'الضاد', 'ضِفْدَعٌ', 'frog', ['ضَحِكَ', 'حَضَرَ', 'مَرِضَ'], true],
  ['ط', 'الطاء', 'طَبْلٌ', 'drum', ['طَلَبَ', 'مَطَرٌ', 'سَقَطَ'], true],
  ['ظ', 'الظاء', 'ظَرْفٌ', 'envelope', ['ظَهَرَ', 'نَظَرَ', 'حَفِظَ'], true],
  ['ع', 'العين', 'عِنَبٌ', 'grapes', ['عَمِلَ', 'لَعِبَ', 'زَرَعَ'], true],
  ['غ', 'الغين', 'غَيْمَةٌ', 'cloud', ['غَسَلَ', 'صَغُرَ', 'بَلَغَ'], true],
  ['ف', 'الفاء', 'فِيلٌ', 'elephant', ['فَتَحَ', 'سَفَرٌ', 'وَقَفَ'], true],
  ['ق', 'القاف', 'قِرْدٌ', 'monkey', ['قَلَمٌ', 'بَقَرَةٌ', 'وَرَقٌ'], true],
  ['ك', 'الكاف', 'كَلْبٌ', 'dog', ['كَتَبَ', 'سَكَنَ', 'سَمَكٌ'], true],
  ['ل', 'اللام', 'لَيْمُونَةٌ', 'lemon', ['لَعِبَ', 'جَلَسَ', 'جَمَلٌ'], true],
  ['م', 'الميم', 'مَوْزٌ', 'banana', ['مَطَرٌ', 'سَمَكٌ', 'قَلَمٌ'], true],
  ['ه', 'الهاء', 'هِلَالٌ', 'moon', ['هَرَبَ', 'ذَهَبَ', 'شَبَهٌ'], true],
  ['و', 'الواو', 'وَرْدَةٌ', 'rose', ['وَلَدٌ', 'سَوَادٌ', 'دَلْوٌ'], false],
].map(([ch, name, key, img, words, conn]) => ({ ch, name, key, img, words, conn }));
const FAMILIES = [['أ'], ['ب', 'ت', 'ث', 'ن', 'ي'], ['ج', 'ح', 'خ'], ['د', 'ذ', 'ر', 'ز'], ['س', 'ش', 'ص', 'ض'], ['ط', 'ظ', 'ع', 'غ'], ['ف', 'ق', 'ك', 'ل', 'م', 'ه', 'و']];
const byCh = c => L.find(x => x.ch === c);
const syl = (ch, h) => (ch === 'أ' ? { fatha: 'أَ', damma: 'أُ', kasra: 'إِ' }[h] : ch + H[h]);
const HN = { fatha: 'فَتْحَة', damma: 'ضَمَّة', kasra: 'كَسْرَة' };
const HS = ['fatha', 'damma', 'kasra'];
const forms = l => (l.ch === 'أ' ? [['في أوّل الكلمة', 'أ'], ['متّصلاً بما قبله', 'ـأ'], ['منفصلاً', 'ا']] :
  l.conn ? [['في أوّل الكلمة', l.ch + 'ـ'], ['في وسط الكلمة', 'ـ' + l.ch + 'ـ'], ['في آخر الكلمة', 'ـ' + l.ch], ['منفصلاً', l.ch]] :
    [['في أوّل الكلمة', l.ch], ['متّصلاً بما قبله', 'ـ' + l.ch], ['منفصلاً', l.ch]]);
const famOf = c => FAMILIES.find(f => f.includes(c));
const hlSet = c => (c === 'أ' ? ['أ', 'إ', 'ا'] : [c]);

let n = 0;
const P = inner => page(inner, { n: ++n, level: LV });
const S = (t, cls = '') => `<span class="nk ${cls}">${t}</span>`;

function titlePage() {
  const imgs = ['lion', 'duck', 'apple', 'fish', 'sun', 'rose'];
  return P(`
  <div style="border:1.2mm solid #111;border-radius:9mm;flex:1;display:flex;flex-direction:column;align-items:center;padding:12mm 10mm;gap:6mm;text-align:center">
    <div style="font-size:14pt;font-weight:700;border:.6mm solid #111;border-radius:5mm;padding:1mm 6mm">سلسلة علاج الضعف القرائي</div>
    <div style="font-size:66pt;font-weight:900;line-height:1.15">أقرأ بثقة</div>
    <div style="font-size:22pt;font-weight:900;background:#111;color:#fff;border-radius:6mm;padding:2mm 10mm">المستوى الأول</div>
    <div style="font-size:18pt;font-weight:700;line-height:1.5">أتعرّف الحروف وأقرؤها<br>بالحركات القصيرة</div>
    <div style="display:grid;grid-template-columns:repeat(3,38mm);gap:5mm;margin-top:2mm">${imgs.map(i => `<div style="height:34mm">${pic(i)}</div>`).join('')}</div>
    <div style="margin-top:auto;width:100%;font-size:15pt;line-height:2.4;text-align:right">
      اسم التلميذ: ............................................................<br>
      الصف والشعبة: ......................... المدرسة: ..................................
    </div>
  </div>`);
}

function guidePage() {
  const steps = [
    ['ابدأ بالاختبار القبلي', 'في الصفحة التالية. علّم الحروف التي لا يعرفها التلميذ، وابدأ بها.'],
    ['درس قصير كل يوم', 'من ١٥ إلى ٢٠ دقيقة: صفحة «أتعرّف» ثم صفحة «أتدرّب». لا تنتقل قبل الإتقان.'],
    ['اسمع ثم أشِر ثم اقرأ', 'انطق الصوت أمام التلميذ، ودعه يشير إلى الحرف، ثم يقرؤه وحده.'],
    ['عائلات الحروف', 'رُتّبت الحروف المتشابهة في الشكل معاً (ب ت ث ن ي...) ليتعلّم التلميذ التمييز بالنقاط.'],
    ['المراجعة بعد كل عائلة', 'صفحة المراجعة تقيس التقدّم؛ سجّل النتيجة في جدول المتابعة.'],
    ['الاختبار البعدي والشهادة', 'في نهاية الكتاب. عند الإتقان ينتقل التلميذ إلى المستوى الثاني.'],
  ];
  return P(`${header('كيف تستعمل هذا الكتاب؟', 'دليل المعلّم', LV)}
  <div class="sec" style="font-size:12.5pt;line-height:1.75">
    <p style="margin:0 0 2mm">هذا الكتاب مخصّص للتلاميذ الذين يتعثّرون في قراءة الحروف وحركاتها. يتدرّج من الحرف المنفرد إلى المقطع ثم الكلمة، ويُستعمل في حصّة الدعم أو في البيت. <b>المرجع المنهجي:</b> يتبع الكتاب تسلسل «القاعدة النورانيّة» المجرّب في تعليم القراءة (الحرف ← الحركة ← التنوين ← المدّ ← السكون ← الشدّة)، مع التعلّم متعدّد الحواس: أرى، أسمع، أنطق، أكتب، ألوّن. ويضمّ: قرآناً كريماً، وإملاءً، وخطّاً، وتلويناً، ودمجاً للحروف، وقراءات، ولوحة نجاح، وصفحات للأهل.</p>
  </div>
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:4mm">${steps.map(([t, d], i) => `
    <div class="sec" style="padding:3.5mm 4.5mm"><div class="t"><i>${hd(i + 1)}</i><span>${t}</span></div><div style="font-size:11.5pt;line-height:1.7">${d}</div></div>`).join('')}
  </div>
  ${sec(7, 'علامات الإتقان', `<div style="font-size:12pt;line-height:1.9">
    ● يميّز شكل الحرف من بين الحروف المتشابهة.<br>
    ● ينطق الحرف بالفتحة والضمّة والكسرة نطقاً صحيحاً.<br>
    ● يقرأ صفّ المقاطع في صفحة المراجعة بأخطاء لا تزيد على اثنين.<br>
    ● يكتب الحرف بحركاته كتابة واضحة.</div>`)}
  <div class="parent"><b>للأهل:</b><span>في أسفل كل درس «ركن الأهل»: نشاط بيتي قصير يثبّت ما تعلّمه الطفل. التشجيع والصبر أهمّ من السرعة.</span></div>`);
}

function testPage(title, tag, seed) {
  const cells = shuffle(L.map((l, i) => syl(l.ch, HS[(i + seed) % 3])), seed);
  return P(`${header(title, tag, LV)}
  ${sec(1, 'أقرأ المقاطع', `<div style="display:grid;grid-template-columns:repeat(7,1fr);gap:2.6mm">${cells.map(c => `
      <div class="cell" style="flex-direction:column;height:27mm;gap:1mm">${S(c)}<span style="font-size:8pt;border:.4mm solid #111;width:5mm;height:5mm;border-radius:1mm"></span></div>`).join('')}</div>`,
    '', 'يقرأ التلميذ، والمعلّم يضع ✓ في المربّع عند القراءة الصحيحة')}
  ${sec(2, 'أكتب الحرف الذي أسمعه', `<div style="display:grid;grid-template-columns:repeat(6,1fr);gap:3mm">${Array.from({ length: 12 }, () => '<div class="cell" style="height:22mm"></div>').join('')}</div>`, '', 'يُملي المعلّم ١٢ مقطعاً')}
  <div class="sec" style="display:flex;justify-content:space-around;font-size:15pt;font-weight:700;padding:5mm">
    <span>القراءة: ........ من ${hd(28)}</span><span>الكتابة: ........ من ${hd(12)}</span><span>التاريخ: ..../..../........</span>
  </div>`).replace(/<span class="nk ">/g, '<span class="nk" style="font-size:30pt">');
}

function trackerPage() {
  const rows = L.map(l => `<tr><td style="font-size:15pt;font-weight:800;line-height:1">${l.ch}</td><td></td><td></td><td></td><td></td><td></td></tr>`).join('');
  return P(`${header('جدول متابعة التقدّم', 'للمعلّم', LV)}
  <table style="font-size:10.5pt"><thead><tr style="height:10mm;background:#eee">
    <th style="width:14mm">الحرف</th><th>يميّز شكله</th><th>يقرؤه بالحركات</th><th>يكتبه</th><th>يقرأ كلماته</th><th style="width:44mm">ملاحظة</th></tr></thead>
    <tbody>${rows}</tbody></table>`).replace(/<tr><td/g, '<tr style="height:7.7mm"><td');
}

function lessonA(l, idx, learned) {
  const pool = learned.slice(-6);
  const row = shuffle([...HS.map(h => syl(l.ch, h)), ...HS.map(h => syl(l.ch, h)), ...pool.flatMap(c => HS.map(h => syl(c, h)))], idx + 3).slice(0, 10);
  const ensure = HS.map(h => syl(l.ch, h)).filter(s => !row.includes(s));
  ensure.forEach((s, i) => (row[i * 3] = s));
  const fm = forms(l);
  return P(`${header(`حرف ${l.name}`, `الدرس ${hd(idx)}`, LV)}
  <div class="row" style="height:62mm">
    <div class="cell" style="flex:0 0 66mm;flex-direction:column;border-width:.9mm;padding:6mm">${inkSVG(l.ch, { pad: 0.04 })}</div>
    <div class="cell" style="flex-direction:column;padding:3mm;gap:1mm"><div style="height:46mm;width:100%">${pic(l.img)}</div>
      <div class="nk" style="font-size:30pt;line-height:1.4">${hl(l.key, hlSet(l.ch))}</div></div>
  </div>
  ${sec(1, 'أنظرُ وأسمعُ وأقرأُ', `<div class="row">${HS.map(h => `<div class="cell" style="flex-direction:column;height:35mm">${S(syl(l.ch, h), 'big')}<span style="font-size:12pt;font-weight:700">${HN[h]}</span></div>`).join('')}</div>`)}
  ${sec(2, 'أشكالُ الحرفِ في الكلمة', `<div class="row">${fm.map(([t, f]) => `<div class="cell" style="flex-direction:column;height:27mm">${S(f, 'mid')}<span style="font-size:10pt">${t}</span></div>`).join('')}</div>`)}
  ${sec(3, 'أقرأُ المقاطعَ', `<div class="row">${row.map(s => `<div class="cell" style="height:21mm">${S(s, 'sm')}</div>`).join('')}</div>`, '', idx > 1 ? 'مع حروف تعلّمتُها سابقاً' : '')}
  <div class="parent"><b>ركن الأهل:</b><span>انطقوا مع طفلكم «${syl(l.ch, 'fatha')} – ${syl(l.ch, 'damma')} – ${syl(l.ch, 'kasra')}»، واطلبوا منه كلمتين فيهما صوت ${l.name}، ثم يلوّن الصورة.</span></div>`);
}

function lessonB(l, idx) {
  const fam = famOf(l.ch);
  const others = (fam.length > 1 ? fam.filter(c => c !== l.ch) : ['ل', 'ك', 'ت']).concat(['م', 'ر', 'س']).slice(0, 4);
  const items = shuffle([...HS.map(h => syl(l.ch, h)), syl(l.ch, HS[idx % 3]), ...others.flatMap((c, i) => [syl(c, HS[i % 3]), syl(c, HS[(i + 1) % 3])])], idx * 7).slice(0, 12);
  const trace = h => `<div class="row" style="gap:2.4mm">${[0, 1, 2].map(() => `<div class="cell" style="height:18mm">${S(syl(l.ch, h), 'trace sm2')}</div>`).join('')}${[0, 1, 2].map(() => '<div class="cell" style="height:18mm"></div>').join('')}</div>`;
  return P(`${header(`أتدرّبُ على حرف ${l.name}`, `الدرس ${hd(idx)}`, LV)}
  ${sec(1, 'أقرأُ الكلماتِ وأضعُ خطّاً تحتَ الحرف', `<div class="row">${l.words.map((wd, i) => `<div class="cell" style="flex-direction:column;height:27mm"><span class="nk" style="font-size:30pt">${wd}</span><span style="font-size:9.5pt">${['في الأوّل', 'في الوسط', 'في الآخر'][i]}</span></div>`).join('')}</div>`)}
  ${sec(2, `أضعُ دائرةً حولَ المقطعِ الذي فيه حرفُ ${l.name}`, `<div style="display:grid;grid-template-columns:repeat(6,1fr);gap:2.6mm">${items.map(s => `<div class="cell" style="height:21mm">${S(s, 'sm')}</div>`).join('')}</div>`)}
  ${sec(3, 'أكتبُ فوقَ الحرفِ الرماديّ ثمّ أكتبُ وحدي', `<div style="display:flex;flex-direction:column;gap:2.4mm">${HS.map(trace).join('')}</div>`)}
  <div class="sec grow">${`<div class="t"><i>${hd(4)}</i><span>أرسمُ شيئاً فيه حرفُ ${l.name}</span></div>`}</div>`);
}

function reviewPage(fam, k) {
  const sylls = shuffle(fam.flatMap(c => HS.map(h => syl(c, h))), k * 11);
  while (sylls.length < 24) sylls.push(...shuffle(sylls, sylls.length).slice(0, 24 - sylls.length));
  const letters = shuffle(fam, k + 2), imgs = shuffle(fam, k + 5);
  const words = fam.flatMap(c => byCh(c).words.slice(0, 2)).slice(0, 8);
  const showMatch = fam.slice(0, 4);
  const ml = shuffle(showMatch, k + 2), mi = shuffle(showMatch, k + 9);
  return P(`${header(`مراجعة: ${fam.join(' ')}`, `مراجعة ${hd(k)}`, LV)}
  ${sec(1, 'أقرأُ المقاطعَ بسرعة', `<div style="display:grid;grid-template-columns:repeat(8,1fr);gap:2mm">${sylls.slice(0, 24).map(s => `<div class="cell" style="height:13.5mm">${S(s, 'sm')}</div>`).join('')}</div>`, '', 'المعلّم يحسب الأخطاء')}
  ${sec(2, 'أصلُ الحرفَ بصورتِه', `<div style="display:grid;grid-template-columns:28mm 1fr 34mm;row-gap:2.4mm">${ml.map((c, i) => `
     <div class="cell" style="height:16.5mm">${S(c, 'sm')}</div><div style="display:flex;justify-content:space-between;align-items:center;padding:0 3mm"><b style="font-size:14pt">●</b><b style="font-size:14pt">●</b></div><div class="cell" style="height:16.5mm;padding:1mm">${pic(byCh(mi[i]).img)}</div>`).join('')}</div>`)}
  ${sec(3, 'أقرأُ الكلمات', `<div style="display:grid;grid-template-columns:repeat(4,1fr);gap:2.4mm">${words.map(wd => `<div class="cell" style="height:13.5mm"><span class="nk" style="font-size:21pt;line-height:1.5">${wd}</span></div>`).join('')}</div>`)}
  <div class="sec" style="display:flex;justify-content:space-around;font-size:13pt;font-weight:700;padding:2.5mm">
    <span>أخطاء المقاطع: ......</span><span>أتقنتُ؟ نعم ☐ لا ☐</span><span>توقيع المعلّم: ............</span></div>`);
}

function certificatePage() {
  return P(`<div style="border:1.4mm double #111;border-radius:9mm;flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:7mm;text-align:center;padding:12mm">
    <div style="height:42mm;width:42mm">${pic('star')}</div>
    <div style="font-size:42pt;font-weight:900">شهادةُ إتقان</div>
    <div style="font-size:20pt;font-weight:700">المستوى الأول من سلسلة «أقرأ بثقة»</div>
    <div style="font-size:16pt;line-height:2.2">تُمنح هذه الشهادة للتلميذ/ة<br>.......................................................................<br>لإتقانه قراءة الحروف بالحركات القصيرة</div>
    <div style="display:flex;gap:30mm;font-size:14pt;margin-top:6mm"><span>المعلّم/ة: ..................</span><span>التاريخ: ..../..../........</span></div>
    <div class="row" style="width:120mm;height:30mm;margin-top:4mm">${['duck', 'lion', 'bee'].map(i => `<div style="flex:1">${pic(i)}</div>`).join('')}</div>
  </div>`);
}

function lessonC(l, idx) {
  const fm = forms(l).map(f => f[1]).join('   ');
  const rows = [Array(5).fill(l.ch).join('   '), HS.map(h => syl(l.ch, h)).join('   '), fm, l.key];
  const stars = [[8, 12], [92, 12], [8, 86], [92, 86]].map(([x, y]) => `<span style="position:absolute;left:${x}%;top:${y}%;font-size:22pt;transform:translate(-50%,-50%)">✦</span>`).join('');
  const big = `<div style="position:relative;height:100%;padding:6mm 18mm">${inkSVG(l.ch, { stroke: 5, pad: 0.05 })}${stars}</div>`;
  return P(`${header(`أخطُّ وألوّنُ حرف ${l.name}`, `الدرس ${hd(idx)}`, LV)}
  ${sec(1, 'أكتبُ فوقَ الرماديّ ثمّ أكتبُ وحدي', `<div style="display:flex;flex-direction:column;gap:2.2mm">${rows.map(r => `<div class="cell" style="height:21mm;justify-content:space-between;padding:0 4mm">${S(r, 'sm trace')}<span style="width:40%;border-bottom:.5mm solid #111;height:12mm"></span></div>`).join('')}</div>`)}
  <div class="sec grow" style="display:flex;flex-direction:column;min-height:0"><div class="t"><i>${hd(2)}</i><span>ألوّنُ الحرفَ وأزيّنُه بألواني</span></div><div style="flex:1;min-height:0">${big}</div></div>`);
}

async function build(out) {
  n = 0;
  const pages = [titlePage(), ...X.parentPages(P, LV, 'الحروف العربيّة الثمانية والعشرون وقراءتها بالفتحة والضمّة والكسرة', ['أقرأ ١٠ دقائق', 'ركن الأهل', 'أخطّ وألوّن', 'سورة قصيرة']),
    guidePage(), testPage('الاختبار القبلي', 'قبل البدء', 1), trackerPage(), X.successChart(P, LV, L.map(l => `حرف ${l.name}`), 7)];
  const learned = [];
  let idx = 0;
  FAMILIES.forEach((fam, k) => {
    for (const c of fam) {
      const l = byCh(c);
      idx++;
      pages.push(lessonA(l, idx, learned), lessonB(l, idx), lessonC(l, idx));
      learned.push(c);
    }
    if (fam.length > 1) {
      const tag = `مراجعة ${hd(k)}`;
      const words = shuffle(fam.flatMap(c => byCh(c).words), k + 3);
      pages.push(reviewPage(fam, k));
      pages.push(X.mergePage(P, LV, tag, fam.join(' '), [...words, ...words].slice(0, 9)));
      pages.push(X.dictationPage(P, LV, tag, `حروف ${fam.join(' ')}`, [...shuffle(fam.flatMap(c => HS.map(h => syl(c, h))), k).slice(0, 8), ...words.slice(0, 4)], { boxes: 8, lines: 4 }));
      pages.push(X.quranWordsPage(P, LV, tag, fam, `الحروف ( ${fam.join(' ')} )`, k + 1));
    }
  });
  pages.push(X.quranSurahPage(P, LV, 'القرآن', 1, 'أضعُ دائرةً حولَ ثلاثة حروف أعرفها في السورة'));
  pages.push(testPage('الاختبار البعدي', 'نهاية المستوى', 2), ...X.appendixPages(P, LV), certificatePage());
  while (pages.length % 4) pages.splice(pages.length - 1, 0, X.coloringPage(P, LV, 'نشاط', 'حروفي الجميلة', 'أ ب ت', 'lion', 'أَسَدٌ'));
  await renderPDF(pages, out);
  return pages.length;
}

module.exports = { build, L, FAMILIES, byCh };
if (require.main === module) build(path.join(ROOT, 'output/level1-interior.pdf')).then(c => console.log('pages', c));
