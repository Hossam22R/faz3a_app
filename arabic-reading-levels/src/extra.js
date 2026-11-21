// صفحات مشتركة إضافية: قرآن، إملاء، تخطيط، تلوين، دمج، الأهل، لوحة النجاح، ملحق المعلّم
const { hd, shuffle, header, sec, inkSVG } = require('./common');
const { pic } = require('./pics');
const Q = require('quran-json/dist/quran.json');

const NK = (t, pt, extra = '') => `<span class="nk" style="font-size:${pt}pt;${extra}">${t}</span>`;
const lineBox = (h = 13) => `<div style="border-bottom:.5mm solid #111;height:${h}mm"></div>`;
const surah = n => Q[n - 1];
const ayahMark = n => `<span class="qr" style="font-size:.9em">۝${hd(n)}</span>`;

// نص قرآني موثّق (الرسم العثماني من quran-json)
function quranText(n, from = 1, to = null, pt = 26) {
  const s = surah(n);
  const vs = s.verses.filter(v => v.id >= from && (!to || v.id <= to));
  return `<div class="qr" style="font-size:${pt}pt;line-height:2.25;text-align:justify;text-align-last:center">${vs.map(v => `${v.text} ${ayahMark(v.id)}`).join(' ')}</div>`;
}
const BASMALA = 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ';
function surahFrame(n, from, to, pt) {
  const s = surah(n);
  const range = from || to ? ` (الآيات ${hd(from || 1)}–${hd(to || s.verses.length)})` : '';
  return `<div style="border:1mm double #111;border-radius:6mm;padding:3mm 6mm 4mm;position:relative">
    <div style="text-align:center;margin-bottom:1mm"><span style="border:.6mm solid #111;border-radius:10mm;padding:.5mm 10mm;font-weight:800;font-size:15pt;background:#fff">سورة ${s.name}${range}</span></div>
    ${n !== 1 && n !== 9 && (from || 1) === 1 ? `<div class="qr" style="text-align:center;font-size:${pt - 4}pt;line-height:2">${BASMALA}</div>` : ''}
    ${quranText(n, from, to, pt)}</div>`;
}

// كلمات قرآنية تحتوي حرفاً معيّناً (من جزء عمّ والفاتحة)
const JUZ = [1, ...Array.from({ length: 37 }, (_, i) => 78 + i)];
function quranWords(letters, count = 12, seed = 1) {
  const set = new Set();
  const base = w => w.replace(/[ً-ٰٟۖ-ۭ]/g, '');
  for (const n of JUZ) for (const v of surah(n).verses) for (const w of v.text.split(' ')) {
    const b = base(w);
    if (b.length >= 2 && b.length <= 5 && letters.some(l => b.includes(l)) && !/[۝]/.test(w)) set.add(w);
  }
  return shuffle([...set], seed).slice(0, count);
}

function quranWordsPage(P, level, tag, letters, names, seed) {
  const ws = quranWords(letters, 12, seed);
  return P(`${header('من كلمات القرآن الكريم', tag, level)}
  ${sec(1, `أستمعُ إلى المعلّم، وأضعُ دائرةً حول ${names}`, `<div style="display:grid;grid-template-columns:repeat(3,1fr);gap:3mm">${ws.map(w => `<div class="cell" style="height:27mm"><span class="qr" style="font-size:30pt;line-height:normal">${w}</span></div>`).join('')}</div>`, '', 'كلمات من سورة الفاتحة وجزء عمّ')}
  ${sec(2, 'أُردّدُ مع المعلّم ثلاث مرّات', `<div class="row" style="font-size:14pt;font-weight:700"><div class="cell" style="height:14mm">المرّة الأولى ☐</div><div class="cell" style="height:14mm">المرّة الثانية ☐</div><div class="cell" style="height:14mm">المرّة الثالثة ☐</div></div>`)}
  <div class="sec grow" style="display:flex;flex-direction:column"><div class="t"><i>${hd(3)}</i><span>أكتبُ كلمةً قرآنيّةً أحببتُها وألوّنُ الإطار</span></div>
    <div style="flex:1;border:1.2mm dashed #111;border-radius:8mm;margin:1mm 6mm 2mm"></div></div>`);
}

function quranSurahPage(P, level, tag, n, task, from, to) {
  const s = surah(n);
  const len = s.verses.filter(v => v.id >= (from || 1) && (!to || v.id <= to)).reduce((a, v) => a + v.text.length, 0);
  const pt = len > 520 ? 17 : len > 380 ? 19 : len > 280 ? 21 : len > 200 ? 24 : 27;
  return P(`${header(`القرآن الكريم: سورة ${s.name}`, tag, level)}
  ${surahFrame(n, from, to, pt)}
  ${sec(1, 'أقرأُ مع المعلّم ثلاث مرّات', `<div class="row" style="font-size:13pt;font-weight:700">${[1, 2, 3].map(k => `<div class="cell" style="height:12mm">القراءة ${hd(k)} ☐</div>`).join('')}</div>`)}
  ${sec(2, task, `<div class="row">${[0, 1, 2].map(() => '<div class="cell" style="height:17mm"></div>').join('')}</div>`)}
  <div class="sec grow" style="display:flex;flex-direction:column"><div class="t"><i>${hd(3)}</i><span>أكتبُ الآية الأولى بخطٍّ جميل</span></div><div style="flex:1"></div>${lineBox(10)}</div>`);
}

// الإملاء: صفحة التلميذ فارغة، والنصّ يُجمع في ملحق المعلّم
const DICT = [];
function dictationPage(P, level, tag, title, items, opts = {}) {
  const { boxes = 8, lines = 4 } = opts;
  DICT.push({ level, tag, title, items });
  return P(`${header(`إملاء: ${title}`, tag, level)}
  ${boxes ? sec(1, 'أكتبُ ما يُمليه المعلّم', `<div style="display:grid;grid-template-columns:repeat(4,1fr);gap:3mm">${Array.from({ length: boxes }, (_, i) => `<div class="cell" style="height:24mm;align-items:flex-start;justify-content:flex-start;padding:1mm 2mm;font-size:9pt">${hd(i + 1)}</div>`).join('')}</div>`, '', 'نصّ الإملاء في ملحق المعلّم آخر الكتاب') : ''}
  ${sec(boxes ? 2 : 1, boxes ? 'أكتبُ الكلمات والجمل' : 'أكتبُ الجُمَلَ التي أسمعُها', `<div style="display:flex;flex-direction:column;gap:1mm">${Array.from({ length: lines }, (_, i) => `<div style="display:flex;align-items:flex-end;gap:2mm"><b style="font-size:10pt">${hd(i + 1)}</b><div style="flex:1">${lineBox(14)}</div></div>`).join('')}</div>`, 'grow')}
  <div class="sec" style="display:flex;justify-content:space-around;align-items:center;font-size:13pt;font-weight:700;padding:2.5mm">
    <span>أصحّحُ مع المعلّم: صحيح ...... من ...... </span><span style="font-size:20pt;letter-spacing:2mm">☆☆☆</span></div>`);
}
function appendixPages(P, level) {
  const items = DICT.filter(d => d.level === level);
  const pages = [];
  const per = level === 1 ? 9 : 6;
  for (let i = 0; i < items.length; i += per) {
    const chunk = items.slice(i, i + per);
    pages.push(P(`${header('ملحق المعلّم: نصوص الإملاء', 'للمعلّم', level)}
    <div style="font-size:11pt">يُملي المعلّم بصوت واضح وبطء، ويكرّر كلّ كلمة مرّتين. لا يرى التلميذ هذه الصفحة.</div>
    <div style="display:flex;flex-direction:column;gap:2.5mm">${chunk.map(d => `<div class="sec" style="padding:2mm 4mm"><b style="font-size:11pt">${d.tag} · ${d.title}</b><div style="margin-top:1mm">${d.items.map(t => NK(t, 14)).join('<span style="margin:0 3mm">◆</span>')}</div></div>`).join('')}</div>`));
  }
  return pages;
}

// التخطيط: كتابة فوق الرمادي ثمّ وحدي
function tracingPage(P, level, tag, title, rows, opts = {}) {
  const pt = opts.pt || 30;
  return P(`${header(`أخطُّ: ${title}`, tag, level)}
  <div style="font-size:11.5pt">أكتبُ فوقَ الخطّ الرماديّ ببطء، ثمّ أكتبُ وحدي في المكان الفارغ.</div>
  <div style="display:flex;flex-direction:column;gap:2.4mm;flex:1">${rows.map(r => `<div class="cell" style="flex:1;justify-content:flex-start;gap:6mm;padding:0 5mm;background:repeating-linear-gradient(to bottom,transparent 0,transparent 62%,#bbb 62%,#bbb calc(62% + .3mm),transparent calc(62% + .3mm))">
      ${[0, 1].map(() => NK(r, pt, 'color:#b4b4b4')).join('')}<span style="flex:1"></span></div>`).join('')}</div>`);
}

// التلوين: نصّ مفرّغ كبير + صورة
function coloringPage(P, level, tag, title, text, img, caption) {
  const big = `<div style="position:relative;height:100%;padding:4mm 14mm">${inkSVG(text, { stroke: 4, pad: 0.05 })}${[[7, 15], [93, 15], [7, 85], [93, 85]].map(([a, b]) => `<span style="position:absolute;left:${a}%;top:${b}%;font-size:22pt;transform:translate(-50%,-50%)">✦</span>`).join('')}</div>`;
  return P(`${header(`ألوّن: ${title}`, tag, level)}
  <div class="sec" style="height:92mm;padding:2mm">${big}</div>
  <div class="sec grow" style="display:flex;flex-direction:column;align-items:center;padding:4mm;min-height:0"><div style="flex:1;width:100%;min-height:0">${pic(img)}</div>${caption ? NK(caption, 28) : ''}</div>`);
}

// الدمج والتقطيع
function mergePage(P, level, tag, title, words) {
  const chunks = w => {
    const out = [];
    let i = 0;
    while (i < w.length) {
      let j = i + 1;
      while (j < w.length && /[ً-ْٰ]/.test(w[j])) j++;
      out.push(w.slice(i, j));
      i = j;
    }
    return out;
  };
  const merge = words.slice(0, 5), split = words.slice(5, 9);
  return P(`${header(`أدمجُ وأُقطّع: ${title}`, tag, level)}
  ${sec(1, 'أدمجُ الحروفَ لأكوّنَ كلمة ثمّ أقرؤها', `<div style="display:flex;flex-direction:column;gap:2.6mm">${merge.map(w => `<div class="cell" style="height:23mm;gap:2mm;padding:0 4mm">${chunks(w).map(c => `<span style="border:.4mm dashed #111;border-radius:2mm;padding:0 2.5mm">${NK(c, 22)}</span>`).join('<b>+</b>')}<b>=</b><span style="flex:1;border-bottom:.5mm solid #111;height:12mm"></span></div>`).join('')}</div>`)}
  ${sec(2, 'أُقطّعُ الكلمةَ إلى حروفها', `<div style="display:grid;grid-template-columns:1fr 1fr;gap:3mm">${split.map(w => `<div class="cell" style="height:23mm;gap:2mm;padding:0 3mm">${NK(w, 22)}<b>=</b>${chunks(w).map(() => '<span style="width:11mm;height:13mm;border:.4mm solid #111;border-radius:2mm"></span>').join('')}</div>`).join('')}</div>`, 'grow')}`);
}

// الأهل
function parentPages(P, level, lvTitle, homeTasks) {
  return [
    P(`${header('رسالة إلى الأهل الكرام', 'للأهل', level)}
    <div class="sec" style="font-size:13pt;line-height:1.95">أولياء الأمور الكرام، تحيّة طيّبة.<br>يتعلّم طفلكم في هذا الكتاب: <b>${lvTitle}</b>. نجاح طفلكم يحتاج إلى تعاون البيت والمدرسة، وعشر دقائق يوميّاً معكم تصنع فرقاً كبيراً.</div>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:4mm">
      ${sec(1, 'كيف أساعد طفلي؟', `<div style="font-size:12pt;line-height:1.9">● خصّصوا وقتاً ثابتاً كلّ يوم.<br>● اقرؤوا معه بصوت واضح، ثمّ دعوه يقرأ.<br>● نفّذوا نشاط «ركن الأهل» في كلّ درس.<br>● اربطوا الحروف بأشياء في البيت والشارع.<br>● راجعوا معه آيات القرآن القصيرة.</div>`)}
      ${sec(2, 'عبارات تشجيع', `<div style="font-size:12pt;line-height:1.9">● «أحسنت، أنا فخور بك!»<br>● «لاحظتُ أنّك تحسّنت اليوم».<br>● «حاول مرّة أخرى، أنت تقدر».<br>● «قراءتك أصبحت أوضح».<br>● «هيّا نقرأ معاً».</div>`)}
      ${sec(3, 'ما نتجنّبه', `<div style="font-size:12pt;line-height:1.9">● المقارنة بالإخوة أو الزملاء.<br>● الصراخ أو العقاب عند الخطأ.<br>● الجلسات الطويلة المتعبة.<br>● القراءة عن الطفل بدل تشجيعه.</div>`)}
      ${sec(4, 'علامات التقدّم', `<div style="font-size:12pt;line-height:1.9">● يقرأ بثقة أكبر وتردّد أقلّ.<br>● يصحّح خطأه بنفسه.<br>● يطلب القراءة دون إلحاح.<br>● تتحسّن درجاته في الإملاء.</div>`)}
    </div>
    <div class="parent" style="font-size:12pt"><b>تواصل:</b><span>نرجو كتابة ملاحظاتكم للمعلّم في جدول البيت الأسبوعي في الصفحة التالية.</span></div>`),
    P(`${header('خطّة البيت الأسبوعيّة', 'للأهل', level)}
    <table style="font-size:11pt"><thead><tr style="height:11mm;background:#eee"><th style="width:24mm">اليوم</th>${homeTasks.map(t => `<th>${t}</th>`).join('')}<th style="width:28mm">توقيع وليّ الأمر</th></tr></thead>
    <tbody>${['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'].map(d => `<tr style="height:15mm"><td style="font-weight:700">${d}</td>${homeTasks.map(() => '<td style="font-size:16pt">☐</td>').join('')}<td></td></tr>`).join('')}</tbody></table>
    ${sec(1, 'ملاحظات الأهل للمعلّم', `${lineBox(11)}${lineBox(11)}${lineBox(11)}`, 'grow')}
    <div style="font-size:10.5pt;text-align:center">تُصوَّر هذه الصفحة أو تُنسخ لكلّ أسبوع.</div>`),
  ];
}

// لوحة النجاح
function successChart(P, level, items, cols = 4) {
  return P(`${header('لوحةُ نجاحي', 'نجاح', level)}
  <div style="font-size:12.5pt;text-align:center">كلّما أتقنتُ درساً ألوّنُ نجمتَه، وعند امتلاء اللوحة أحصل على شهادة الإتقان!</div>
  <div style="display:grid;grid-template-columns:repeat(${cols},1fr);grid-auto-rows:1fr;gap:2.4mm;flex:1">${items.map(t => `<div class="cell" style="flex-direction:column;gap:0">
    <svg viewBox="-60 -60 120 120" style="width:15mm;height:15mm"><path d="M0 -50 L14 -16 L50 -15 L22 8 L31 44 L0 23 L-31 44 L-22 8 L-50 -15 L-14 -16Z" fill="#fff" stroke="#111" stroke-width="5" stroke-linejoin="round"/></svg>
    <span style="font-size:10pt;font-weight:700;line-height:1.3;padding:0 1mm">${t}</span></div>`).join('')}</div>`);
}

module.exports = { NK, lineBox, quranWordsPage, quranSurahPage, surahFrame, dictationPage, appendixPages, tracingPage, coloringPage, mergePage, parentPages, successChart, DICT, surah };
