// Read English with Confidence — Level 1: Letters & Sounds
// المرجع: الصوتيّات المنهجيّة (NRP 2000، Rose Review 2006): الصوت قبل الاسم، ترتيب SATPIN للبدء بالدمج مبكّراً،
// تتبّع الحرف، والصوت الأوّل، ومعالجة صعوبات المتعلّم العربيّ (p/b، v/f، الحركات القصيرة، b/d/p/q)
const path = require('path');
const { makeKit, hd, shuffle, pic, M, VC, CC, VOW } = require('./ekit');
const R = '../../arabic-reading-levels/src/';
const { sec, inkSVG } = require(R + 'common');
const ROOT = path.resolve(__dirname, '..');
const LV = 1;

// الحروف بترتيب SATPIN
const LET = [
  ['s', 'sun', 'sun', 'سسس… مثل صوت «س» والأفعى تصفر', ['sun', 'snake']],
  ['a', 'apple', 'apple', 'صوت قصير مثل الفتحة في «أَب»: a', ['apple']],
  ['t', 'turtle', 'turtle', 'مثل «ت» بنفخة هواء خفيفة', ['turtle', 'tree']],
  ['p', 'panda', 'panda', 'صوت جديد! مثل «ب» لكن بلا صوت، بنفخة هواء: ضع يدك أمام فمك وأحسّ بالهواء', ['panda', 'pen', 'penguin']],
  ['i', 'igloo', 'igloo', 'صوت قصير مثل الكسرة في «إِبل»: i', ['igloo']],
  ['n', 'nest', 'nest', 'مثل «ن»: نننن', ['nest']],
  ['m', 'monkey', 'monkey', 'مثل «م» والشفتان مطبقتان: مممم', ['monkey', 'moon', 'milk']],
  ['d', 'dog', 'dog', 'مثل «د»', ['dog', 'duck', 'door']],
  ['g', 'grapes', 'grapes', 'مثل «گ» العراقيّة في «گلاص»', ['grapes']],
  ['o', 'octopus', 'octopus', 'صوت قصير مفتوح بين الفتحة والضمّة: o', ['octopus']],
  ['c', 'cat', 'cat', 'مثل «ك»', ['cat', 'cow', 'camel']],
  ['k', 'kite', 'kite', 'مثل «ك» أيضاً! c و k لهما الصوت نفسه', ['kite']],
  ['e', 'elephant', 'elephant', 'صوت قصير مثل «إِ» مفتوحة قليلاً: e', ['elephant']],
  ['u', 'umbrella', 'umbrella', 'صوت قصير من الحلق مثل «أَ» قصيرة جدّاً: u', ['umbrella']],
  ['r', 'rabbit', 'rabbit', 'مثل «ر» خفيفة جدّاً بلا ترديد اللسان', ['rabbit']],
  ['h', 'house', 'house', 'مثل «هـ»: نفَس خفيف', ['house', 'hand']],
  ['b', 'ball', 'ball', 'مثل «ب» تماماً', ['ball', 'banana', 'bee', 'book', 'bear']],
  ['f', 'fish', 'fish', 'مثل «ف»', ['fish', 'fox', 'frog']],
  ['l', 'lion', 'lion', 'مثل «ل»', ['lion', 'lemon']],
  ['j', 'jug', 'jug', 'مثل «ج» في «جمل»', ['jug']],
  ['v', 'van', 'van', 'صوت جديد! مثل «ف» مع اهتزاز الحلق (ڤ): ضع يدك على حلقك وأحسّ بالاهتزاز', ['van']],
  ['w', 'whale', 'whale', 'مثل «و» والشفتان مدوّرتان', ['whale']],
  ['x', 'fox', 'fox', 'صوتان معاً «كس»، ويأتي غالباً في آخر الكلمة: fox، box', ['fox']],
  ['y', 'yoyo', 'yo-yo', 'مثل «ي» في «يد»', ['yoyo']],
  ['z', 'zip', 'zip', 'مثل «ز»: زززز كالنحلة', ['zip']],
  ['q', 'duck', 'quack!', 'يأتي مع u دائماً: qu = «كو» مثل صوت البطّة quack', []],
].map(([l, img, word, tip, words]) => ({ l, img, word, tip, words }));
const GROUPS = [['s', 'a', 't', 'p'], ['i', 'n', 'm', 'd'], ['g', 'o', 'c', 'k'], ['e', 'u', 'r', 'h'], ['b', 'f', 'l', 'j'], ['v', 'w', 'x', 'y', 'z', 'q']];
const BLEND = [
  ['at', 'sat', 'pat', 'tap', 'sap', 'taps'],
  ['pin', 'tin', 'sit', 'pan', 'man', 'mat', 'dip', 'sad', 'nap', 'dad'],
  ['cat', 'dog', 'pot', 'top', 'cap', 'kid', 'dig', 'got', 'can', 'kit'],
  ['sun', 'hen', 'red', 'run', 'hat', 'hot', 'mum', 'rat', 'cup', 'hug'],
  ['bus', 'bed', 'fan', 'log', 'jam', 'lip', 'bag', 'big', 'fun', 'jet'],
  ['van', 'fox', 'box', 'six', 'web', 'wet', 'yes', 'zip', 'yum', 'quiz'],
];
const PICW = { cat: 'cat', dog: 'dog', sun: 'sun', van: 'van', fox: 'fox', zip: 'zip' };
const POOL = { apple: 'a', ball: 'b', banana: 'b', bee: 'b', book: 'b', bear: 'b', cat: 'c', cow: 'c', camel: 'c', dog: 'd', duck: 'd', door: 'd', elephant: 'e', fish: 'f', fox: 'f', frog: 'f', grapes: 'g', house: 'h', hand: 'h', igloo: 'i', jug: 'j', kite: 'k', lion: 'l', lemon: 'l', monkey: 'm', moon: 'm', milk: 'm', nest: 'n', octopus: 'o', panda: 'p', pen: 'p', penguin: 'p', rabbit: 'r', sun: 's', snake: 's', turtle: 't', tree: 't', umbrella: 'u', van: 'v', whale: 'w', yoyo: 'y', zip: 'z' };
const GOALS = GROUPS.map(g => [`say the sounds ${g.join(' ')}`, 'أقول أصوات هذه الحروف وأكتبها']);
const K = makeKit(LV, GOALS);
const { P, H, sami, box, cw, sb, hw, grid, timer, faces } = K;
const byL = l => LET.find(x => x.l === l);
const unitOf = l => GROUPS.findIndex(g => g.includes(l)) + 1;
const big = (t, pt, c) => `<span class="en" style="font-weight:700;font-size:${pt}pt;line-height:1;color:${c}">${t}</span>`;
const col = l => (VOW.includes(l) ? VC : CC);
const imgC = (k, h = '100%') => `<div style="width:100%;height:${h}">${pic(k, 'pic', true)}</div>`;
const imgL = (k, h = '100%') => `<div style="width:100%;height:${h}">${pic(k)}</div>`;
const rnd = (() => { let s = 71; return (a, b) => { s = (s * 16807) % 2147483647; return a + (s % (b - a + 1)); }; })();

// ---------- صفحتا كلّ حرف ----------
function meet(L) {
  const u = unitOf(L.l);
  const kw = L.l === 'q' ? cw('quack', 30, 0) : L.l === 'x' ? cw('fox', 30, 2) : cw(L.word.replace('-', ''), 30, 0);
  return P(`${H(`Meet ${L.l.toUpperCase()} ${L.l}`, `أتعرّف الحرف ${L.l}`, { unit: u, stage: 0 })}
  <div class="row" style="height:72mm">
    <div class="cell" style="flex:0 0 74mm;flex-direction:column;gap:1mm;border-width:1mm;border-color:${col(L.l)};background:linear-gradient(180deg,#fff,${VOW.includes(L.l) ? '#FFF1F2' : '#EEF4FF'})">
      <div style="display:flex;align-items:baseline;gap:6mm">${big(L.l.toUpperCase(), 92, col(L.l))}${big(L.l, 104, col(L.l))}</div>
      <span style="font-family:Fredoka;font-weight:700;font-size:20pt;color:#0f172a">/${L.l === 'q' ? 'kw' : L.l === 'x' ? 'ks' : L.l}/</span></div>
    <div class="cell" style="flex-direction:column;padding:3mm;gap:2mm">${imgC(L.img, '48mm')}${kw}</div>
  </div>
  ${sami('Say the <b>sound</b>, not the name!', `قل الصوت لا الاسم: ${L.tip}`)}
  ${sec(1, K.T('Trace and write', 'أتتبّع وأكتب'), `<div style="display:flex;flex-direction:column;justify-content:space-around;height:100%">${hw(`${L.l.toUpperCase()}   ${L.l.toUpperCase()}   ${L.l.toUpperCase()}`)}${hw(`${L.l}   ${L.l}   ${L.l}   ${L.l}   ${L.l}`)}${hw(L.l === 'q' ? 'quack' : L.l === 'x' ? 'fox' : L.word.replace('-', ''), { ls: 4 })}${hw('')}</div>`, 'grow')}
  ${K.parentBox(`اطلبوا من طفلكم أن يجد في البيت شيئين يبدأ اسمهما بصوت ${L.l}، وأن يكتب الحرف بإصبعه على ظهر يدكم.`)}`);
}

function practice(L) {
  const u = unitOf(L.l);
  const yes = L.l === 'x' || L.l === 'q' ? [] : L.words.slice(0, 3);
  const others = shuffle(Object.keys(POOL).filter(k => POOL[k] !== L.l && !(L.l === 'c' && POOL[k] === 'k') && !(L.l === 'k' && POOL[k] === 'c')), L.l.charCodeAt(0)).slice(0, 6 - yes.length);
  const pics = shuffle([...yes, ...others], L.l.charCodeAt(0) + 3);
  const letters = shuffle([...Array(7).fill(L.l), ...shuffle('satpinmdgockeurhbfljvwxyz'.split('').filter(c => c !== L.l), u).slice(0, 13)], L.l.charCodeAt(0));
  return P(`${H(`Practise ${L.l}`, `أتدرّب على الحرف ${L.l}`, { unit: u, stage: 1 })}
  ${L.l === 'x' || L.l === 'q'
    ? sec(1, K.T(L.l === 'x' ? 'x is at the end! Read and circle x' : 'q and u are friends! Read and circle qu', L.l === 'x' ? 'x في آخر الكلمة: أقرأ وأضع دائرة حول x' : 'q مع u دائماً: أضع دائرة حول qu'), grid(3, (L.l === 'x' ? ['fox', 'box', 'six', 'mix', 'wax', 'fix'] : ['quack', 'quiz', 'quit', 'quick', 'queen', 'quilt']).map(w => cw(w, 30)), 22))
    : sec(1, K.T(`Circle the pictures that start with /${L.l}/`, `أضع دائرة حول الصور التي تبدأ بصوت ${L.l}`), grid(3, pics.map(k => imgC(k, '24mm')), 30))}
  ${sec(2, K.T(`Find and colour every ${L.l}`, `أجد كلّ حرف ${L.l} وألوّنه`), `<div style="display:grid;grid-template-columns:repeat(10,1fr);gap:2mm">${letters.map(c => `<div style="aspect-ratio:1;border:.5mm solid #475569;border-radius:50%;display:flex;align-items:center;justify-content:center;background:#fff">${big(c, 20, '#111')}</div>`).join('')}</div>`)}
  <div class="row" style="flex:1;min-height:0">
    ${sec(3, K.T('Colour the letter', 'ألوّن الحرف'), `<div style="height:100%;min-height:0;padding:1mm 6mm">${inkSVG(L.l, { stroke: 6, pad: 0.06, font: 'Andika', weight: 700 })}</div>`, 'grow')}
    ${sec(4, K.T(`Draw something with /${L.l}/`, `أرسم شيئاً فيه صوت ${L.l}`), '<div style="height:100%;border:.4mm dashed #94a3b8;border-radius:3mm;background:#fff"></div>', 'grow')}
  </div>`);
}

// ---------- صفحات المجموعة ----------
function blendPage(k) {
  const g = GROUPS[k], u = k + 1, ws = BLEND[k];
  return P(`${H('Blend and read!', 'أدمج الأصوات وأقرأ', { unit: u, stage: 2 })}
  ${sami('Touch each dot and say the sound. Then say them fast: c-a-t → cat!', 'ألمس كلّ نقطة وأقول صوتها، ثمّ أقولها بسرعة معاً فتصير كلمة.')}
  ${grid(2, ws.map(w => `<div style="display:flex;align-items:center;gap:5mm;width:100%;justify-content:space-between;padding:0 3mm">${sb(w, 46)}${PICW[w] ? `<div style="width:30mm;height:28mm">${pic(PICW[w], 'pic', true)}</div>` : ''}<span style="display:flex;gap:1mm;font-size:16pt">☐☐☐</span></div>`), 'fill')}`);
}

function writeWords(k) {
  const u = k + 1, ws = BLEND[k].slice(0, 6);
  return P(`${H('Sound it out and write', 'أقطّع الكلمة وأكتبها', { unit: u, stage: 2 })}
  ${sami('Listen to the word. Say each sound and write one letter in each box.', 'أسمع الكلمة من المعلّم، أقول أصواتها، وأكتب حرفاً في كلّ مربّع.')}
  ${grid(2, ws.map((w, i) => `<div style="display:flex;align-items:center;gap:4mm;width:100%;justify-content:center">${PICW[w] ? `<div style="width:30mm;height:28mm">${pic(PICW[w], 'pic', true)}</div>` : `<span style="font-family:Fredoka;font-size:18pt;font-weight:700;color:#64748b">${i + 1}</span>`}<span style="display:flex;gap:2mm">${[...w].map(() => box(19, 21)).join('')}</span></div>`), 'fill')}`);
}

function review(k) {
  const g = GROUPS[k], u = k + 1, learned = GROUPS.slice(0, k + 1).flat();
  const up = shuffle(g, k + 2), lo = shuffle(g, k + 9);
  return [P(`${H(`Review: ${g.join(' ')}`, `مراجعة الأصوات ${g.join(' ')}`, { review: true, tag: 'Review' })}
  ${sec(1, K.T('Match big and small letters', 'أصل الحرف الكبير بالصغير'), `<div style="display:grid;grid-template-columns:24mm 1fr 24mm;row-gap:2.5mm">${up.map((c, i) => `<div class="cell" style="height:17mm">${big(c.toUpperCase(), 30, col(c))}</div><div style="display:flex;justify-content:space-between;align-items:center;padding:0 3mm"><b>●</b><b>●</b></div><div class="cell" style="height:17mm">${big(lo[i], 30, col(lo[i]))}</div>`).join('')}</div>`)}
  ${sec(2, K.T('Say the sounds fast (1 minute)', 'أقول الأصوات بسرعة'), `<div style="display:grid;grid-template-columns:repeat(8,1fr);gap:2mm">${Array.from({ length: 24 }, () => { const c = learned[rnd(0, learned.length - 1)]; return `<div class="cell" style="height:14mm">${big(rnd(0, 3) ? c : c.toUpperCase(), 24, '#111')}</div>`; }).join('')}</div>`, 'grow')}
  ${timer()}`)];
}

const TH = [
  { w: ['sun', 'snake', 'turtle', 'sun'].map((k, i) => i === 3 ? 'apple' : k), err: ['panda', 'b'] },
  { w: ['monkey', 'moon', 'milk', 'nest'], err: ['dog', 't'] },
  { w: ['cat', 'kite', 'cow', 'octopus'], err: ['grapes', 'j'] },
  { w: ['rabbit', 'house', 'hand', 'umbrella'].map((k, i) => i === 0 ? 'house' : k).slice(0, 3).concat(['rabbit']), err: ['elephant', 'a'] },
  { w: ['ball', 'banana', 'bee', 'fish'], err: ['panda', 'b'] },
  { w: ['van', 'fox', 'fish', 'frog'], err: ['van', 'f'] },
];
function think(k) {
  const u = k + 1, t = TH[k];
  return P(`${H('Think it through!', 'تحدّي التفكير', { unit: u, stage: 5 })}
  ${sec(1, K.T('Which one doesn’t belong?', 'أيّها لا ينتمي؟'), `<div class="row" style="height:34mm">${t.w.map(x => `<div class="cell" style="padding:1.5mm">${imgC(x, '30mm')}</div>`).join('')}</div><div style="font-size:11pt;margin-top:2mm;font-family:Fredoka">Why? <span class="ar-i">لماذا؟</span> ..............................................</div>`)}
  <div class="row" style="flex:1;min-height:0">
    ${sec(2, K.T('Sound detective', 'محقّق الأصوات'), `<div style="font-size:11.5pt;font-family:Fredoka;line-height:1.5">The teacher says a word. Write the first letter.<span class="ar">يقول المعلّم كلمة، وأكتب أوّل حرف فيها.</span></div><div style="display:grid;grid-template-columns:repeat(3,1fr);gap:2mm;margin-top:2mm">${Array.from({ length: 6 }, () => `<div class="cell" style="height:17mm"></div>`).join('')}</div>`, 'grow')}
    ${sec(3, K.T('Spot Sami’s mistake', 'أكتشف خطأ سامي'), `<div class="cell" style="height:46mm;flex-direction:column;gap:2mm;padding:2mm">${imgC(t.err[0], '26mm')}<span style="font-family:Fredoka;font-size:13pt;font-weight:600">Sami says: it starts with <b style="color:${CC};font-size:18pt">${t.err[1]}</b></span></div><div style="font-size:11.5pt;margin-top:2mm;font-family:Fredoka">Right ☐ Wrong ☐ &nbsp; It starts with ${box(14, 10)}</div>`, 'grow')}
  </div>
  ${sec(4, K.T('How do I feel?', 'كيف أشعر؟'), faces())}`);
}

// صفحات خاصّة لصعوبات المتعلّم العربيّ
function confusePB() {
  const items = shuffle(['p', 'b', 'p', 'b', 'p', 'b', 'p', 'b', 'p', 'b', 'p', 'b'], 4);
  return P(`${H('p or b? Listen carefully!', 'p أم b؟ أسمع جيّداً', { unit: 5, stage: 1 })}
  ${sami('Put your hand in front of your mouth. p = puff of air! b = no air.', 'أضع يدي أمام فمي: p تخرج نفخة هواء، و b لا تخرج هواء.')}
  ${sec(1, K.T('Circle p or b for each picture', 'أضع دائرة حول الصوت الأوّل لكلّ صورة'), grid(3, ['panda', 'ball', 'pen', 'banana', 'penguin', 'bee'].map(k => `${imgC(k, '24mm')}<span style="display:flex;gap:6mm">${big('p', 26, CC)}${big('b', 26, CC)}</span>`), 38))}
  ${sec(2, K.T('The teacher says a word: write p or b', 'يقول المعلّم كلمة: أكتب p أو b'), `<div style="display:grid;grid-template-columns:repeat(6,1fr);gap:2mm">${items.map((_, i) => `<div class="cell" style="height:18mm;flex-direction:column"><span style="font-size:9pt;font-family:Fredoka">${i + 1}</span></div>`).join('')}</div>`, 'grow')}`);
}
function confuseVF() {
  return P(`${H('v or f? Feel your throat!', 'v أم f؟ ألمس حلقي', { unit: 6, stage: 1 })}
  ${sami('Touch your throat. v = buzzz (shaking). f = fff (no shaking).', 'ألمس حلقي: v يهتزّ الحلق، و f لا يهتزّ.')}
  ${sec(1, K.T('Circle v or f', 'أضع دائرة حول v أو f'), grid(3, ['van', 'fish', 'fox', 'frog', 'van', 'fish'].map(k => `${imgC(k, '26mm')}<span style="display:flex;gap:6mm">${big('v', 26, CC)}${big('f', 26, CC)}</span>`), 40))}
  ${sec(2, K.T('Read the words', 'أقرأ الكلمات'), grid(4, ['van', 'fan', 'vet', 'fit', 'fox', 'vat', 'fun', 'vex'].map(w => sb(w, 24)), 24), 'grow')}`);
}
function bdpq() {
  const row = shuffle('bdpqbdpqbdpqbdpqbdpq'.split(''), 3);
  return P(`${H('b d p q — don’t mix them up!', 'b d p q: لا أخلط بينها', { unit: 6, stage: 1 })}
  <div class="row" style="height:58mm">
    <div class="cell" style="flex-direction:column;gap:2mm;padding:3mm">${M.svg('0 0 300 170', `<rect x="20" y="10" width="260" height="150" rx="20" fill="#FFF8DC" stroke="#111" stroke-width="3"/><text x="90" y="125" text-anchor="middle" font-family="Andika" font-weight="700" font-size="120" fill="${CC}">b</text><text x="210" y="125" text-anchor="middle" font-family="Andika" font-weight="700" font-size="120" fill="${CC}">d</text><path d="M60 155 Q150 185 240 155" fill="none" stroke="#111" stroke-width="4"/>`)}<span style="font-family:Fredoka;font-size:13pt;font-weight:700">b-e-d makes a bed!<span class="ar">كلمة bed تشبه السرير: b في أوّلها و d في آخرها</span></span></div>
    <div class="cell" style="flex-direction:column;gap:2mm;padding:3mm"><div style="display:flex;gap:10mm">${big('b', 70, CC)}${big('d', 70, VC)}</div><span style="font-family:Fredoka;font-size:12pt;font-weight:600;line-height:1.5">b: the bat comes first, then the ball<span class="ar">b: العصا أوّلاً ثمّ الكرة. d: الكرة أوّلاً ثمّ العصا</span></span></div>
  </div>
  ${sec(1, K.T('Colour b blue, d red, p green, q yellow', 'ألوّن b أزرق، d أحمر، p أخضر، q أصفر'), `<div style="display:grid;grid-template-columns:repeat(10,1fr);gap:2mm">${row.map(c => `<div style="aspect-ratio:1;border:.5mm solid #475569;border-radius:3mm;display:flex;align-items:center;justify-content:center;background:#fff">${big(c, 26, '#111')}</div>`).join('')}</div>`)}
  ${sec(2, K.T('Write the missing letter: b or d?', 'أكتب الحرف الناقص: b أم d؟'), grid(3, ['_og', '_us', '_ad', 'be_', '_ig', '_ot'].map((w, i) => `<span style="display:flex;align-items:center;gap:1mm">${[...w].map(c => c === '_' ? box(12, 13) : big(c, 28, VOW.includes(c) ? VC : CC)).join('')}</span>${i === 0 ? `<div style="width:16mm;height:14mm">${pic('dog', 'pic', true)}</div>` : ''}`), 22), 'grow')}`);
}

function alphabetChart() {
  const ord = 'abcdefghijklmnopqrstuvwxyz'.split('');
  return P(`${H('My Alphabet', 'حروفي الإنكليزيّة', { tag: 'ABC' })}
  ${grid(5, ord.map(l => { const L = byL(l); return `<div style="display:flex;align-items:center;justify-content:space-between;width:100%;padding:0 1mm"><span>${big(l.toUpperCase(), 20, col(l))}${big(l, 22, col(l))}</span><div style="width:14mm;height:13mm">${pic(L.img, 'pic', true)}</div></div><span class="en" style="font-size:10pt;font-weight:700">${L.word}</span>`; }).concat([`<span style="font-family:Fredoka;font-size:11pt;font-weight:700;text-align:center;line-height:1.4">a e i o u<br><span style="color:${VC}">vowels</span><span class="ar" style="font-size:8.5pt">الحروف الحمراء: الحركات</span></span>`, `<span style="font-family:Fredoka;font-size:11pt;font-weight:700;text-align:center;line-height:1.4">b c d…<br><span style="color:${CC}">consonants</span><span class="ar" style="font-size:8.5pt">الحروف الزرقاء</span></span>`, `<div style="width:24mm;height:24mm">${pic('monkey', 'pic', true)}</div>`, `<span style="font-family:Fredoka;font-size:13pt;font-weight:700;text-align:center">26<br>letters</span>`]), 'fill', 2)}`);
}

function abcOrder() {
  const ord = 'abcdefghijklmnopqrstuvwxyz'.split('');
  const hide = new Set(shuffle(ord, 5).slice(0, 11));
  return P(`${H('ABC order', 'الترتيب الأبجديّ', { tag: 'ABC' })}
  ${sami('Sing the alphabet song and fill in the missing letters!', 'أغنّي أغنية الحروف، وأكتب الحروف الناقصة على طريق القطار.')}
  <div style="display:grid;grid-template-columns:repeat(6,1fr);gap:3mm;flex:1;min-height:0;align-content:space-evenly">${ord.map((l, i) => `<div style="aspect-ratio:1.1;border:.7mm solid ${['#EF4444', '#F97316', '#F59E0B', '#22C55E', '#3B82F6', '#8B5CF6'][i % 6]};border-radius:5mm;display:flex;align-items:center;justify-content:center;background:#fff;position:relative">${hide.has(l) ? '' : big(l, 30, col(l))}<span style="position:absolute;bottom:-2.6mm;left:20%;width:4mm;height:4mm;border-radius:50%;background:#334155"></span><span style="position:absolute;bottom:-2.6mm;right:20%;width:4mm;height:4mm;border-radius:50%;background:#334155"></span></div>`).join('')}</div>`);
}

function colorByLetter(name, rows, legend, map) {
  const SW = { 'أسود': '#111', 'أحمر': '#E63946', 'أصفر': '#FFD43B', 'أزرق': '#3B82F6', 'أخضر': '#22C55E', 'بنّي': '#8B5A2B', 'برتقاليّ': '#F97316', 'أبيض': '#fff' };
  const EN = { 'أسود': 'black', 'أحمر': 'red', 'أصفر': 'yellow', 'أزرق': 'blue', 'أخضر': 'green', 'بنّي': 'brown', 'برتقاليّ': 'orange', 'أبيض': 'white' };
  const W = rows[0].length, Hh = rows.length, s = 84, t = 72;
  const o = rows.flatMap((r, y) => [...r].map((c, x) => `<rect x="${x * s}" y="${y * t}" width="${s}" height="${t}" fill="#fff" stroke="#475569" stroke-width="1.6"/><text x="${x * s + s / 2}" y="${y * t + 48}" text-anchor="middle" font-family="Andika" font-weight="700" font-size="34">${map[c][(x + y) % map[c].length]}</text>`)).join('');
  return P(`${H(`Colour by letter: ${name}`, 'ألوّن حسب الحرف', { tag: 'Colour' })}
  <div class="sec" style="display:flex;flex-wrap:wrap;gap:3mm 6mm;justify-content:center;font-family:Fredoka;font-size:14pt;font-weight:700">${legend.map(([k, c]) => `<span style="display:inline-flex;align-items:center;gap:2mm"><span style="width:9mm;height:9mm;border-radius:2mm;border:.4mm solid #111;background:${SW[c]}"></span>${map[k].join(' ')} = ${EN[c]}</span>`).join('')}</div>
  ${sami('Say the sound in each box, then colour it!', 'أقول صوت الحرف في كلّ مربّع، ثمّ ألوّنه بلونه.')}
  <div style="flex:1;min-height:0">${M.svg(`-4 -4 ${W * s + 8} ${Hh * t + 8}`, o)}</div>`);
}
const HEART = ['..11..11..', '.12211221.', '1222222221', '1222222221', '.12222221.', '..122221..', '...1221...', '....11....'];
const FISHP = ['..........', '..1111...1', '.122221.11', '1232222211', '1222222211', '.122221.11', '..1111...1', '..........'];
const TREE = ['...1111...', '..122221..', '.12222221.', '.12222221.', '..122221..', '....33....', '....33....', '..111111..'];

function diag(title, tag) {
  const L12 = ['s', 'a', 't', 'p', 'i', 'm', 'd', 'o', 'c', 'e', 'b', 'f'];
  return [P(`${H(title, 'اختبار', { tag })}
    ${sec(1, K.T('Say the sound (teacher ticks)', 'أقول صوت الحرف (يضع المعلّم ✓)'), `<div style="display:grid;grid-template-columns:repeat(6,1fr);gap:2mm">${shuffle(L12, 3).map(c => `<div class="cell" style="height:20mm;flex-direction:column;gap:1mm">${big(c, 30, '#111')}<span style="width:5mm;height:5mm;border:.4mm solid #111;border-radius:1mm"></span></div>`).join('')}</div>`)}
    ${sec(2, K.T('Write the first letter', 'أكتب الحرف الأوّل للصورة'), grid(4, ['sun', 'dog', 'fish', 'monkey'].map(k => `${imgC(k, '20mm')}${box(14, 12)}`), 36))}
    ${sec(3, K.T('Write the letters you hear', 'أكتب الحروف التي أسمعها'), `<div class="row">${Array.from({ length: 6 }, () => '<div class="cell" style="height:18mm"></div>').join('')}</div>`, 'grow')}`),
  P(`${H(title, 'اختبار', { tag })}
    ${sec(4, K.T('Match big and small', 'أصل الكبير بالصغير'), `<div style="display:grid;grid-template-columns:24mm 1fr 24mm;row-gap:2.5mm">${['A', 'B', 'D', 'G'].map((c, i) => `<div class="cell" style="height:16mm">${big(c, 28, '#111')}</div><div style="display:flex;justify-content:space-between;align-items:center;padding:0 3mm"><b>●</b><b>●</b></div><div class="cell" style="height:16mm">${big(['d', 'g', 'a', 'b'][i], 28, '#111')}</div>`).join('')}</div>`)}
    ${sec(5, K.T('Read the words', 'أقرأ الكلمات'), grid(4, ['sat', 'pin', 'dog', 'cup'].map(w => sb(w, 24)), 26))}
    ${sec(6, K.T('Write the word', 'أكتب الكلمة'), grid(2, ['cat', 'sun'].map(k => `${imgC(k, '20mm')}<span style="display:flex;gap:1.5mm">${box(13, 13)}${box(13, 13)}${box(13, 13)}</span>`), 30), 'grow')}
    <div class="sec" style="display:flex;justify-content:space-around;font-family:Fredoka;font-size:13pt;font-weight:700;padding:2.5mm"><span>Score: ..... / 30</span><span>Date: ..../..../........</span></div>`)];
}

function front() {
  const pages = [];
  pages.push(P(`<div style="border:1.2mm solid #1E3A8A;border-radius:9mm;flex:1;display:flex;flex-direction:column;align-items:center;padding:12mm 10mm;gap:4mm;text-align:center;background:linear-gradient(180deg,#EEF2FB,#fff 40%)">
    <div style="font-family:Fredoka;font-size:14pt;font-weight:600;border:.6mm solid #1E3A8A;border-radius:5mm;padding:1mm 6mm;color:#1E3A8A">English for struggling readers <span class="ar-i">· علاج الضعف في الإنكليزيّة</span></div>
    <div style="font-family:Fredoka;font-size:50pt;font-weight:700;line-height:1.1;color:#0f172a">Read English<br>with Confidence</div>
    <div style="font-family:Cairo;font-size:20pt;font-weight:900;color:#1E3A8A">أقرأ الإنكليزيّة بثقة</div>
    <div style="font-family:Fredoka;font-size:22pt;font-weight:700;background:#1E3A8A;color:#fff;border-radius:6mm;padding:1mm 10mm">Level 1 · Letters &amp; Sounds</div>
    <div style="display:flex;gap:6mm;align-items:center;height:44mm"><div style="width:48mm;height:44mm">${pic('monkey', 'pic', true)}</div><div style="font-size:50pt">${cw('abc', 54)}</div></div>
    <div style="margin-top:auto;width:100%;font-family:Fredoka;font-size:14pt;line-height:2.3;text-align:left">Name: ......................................................... <span class="ar-i">الاسم</span><br>Class: ........................ School: ........................................</div></div>`));
  pages.push(P(`${H('A letter to parents', 'رسالة إلى الأهل الكرام', { tag: 'Parents' })}
    <div class="sec" style="direction:rtl;font-size:13pt;line-height:1.95">أولياء الأمور الكرام، تحيّة طيّبة.<br>يتعلّم طفلكم في هذا الكتاب <b>أصوات الحروف الإنكليزيّة الستّة والعشرين</b> وكتابتها، وأوّل كلمات يقرؤها بنفسه. نعلّم <b>الصوت</b> قبل اسم الحرف، لأنّ الطفل يقرأ بالأصوات: c-a-t ← cat.</div>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:4mm;direction:rtl">
      ${sec(1, 'كيف أساعد طفلي؟', `<div style="font-size:12pt;line-height:1.9">● قولوا الصوت لا الاسم: «سسس» لا «إس».<br>● لعبة «أرى شيئاً يبدأ بـ…».<br>● نفّذوا «ركن الأهل» في كلّ درس.<br>● اقرؤوا الكلمات القصيرة معاً بالإصبع.</div>`)}
      ${sec(2, 'أصوات تحتاج انتباهاً', `<div style="font-size:12pt;line-height:1.9">● <b dir="ltr">p</b> نفخة هواء، و <b dir="ltr">b</b> بلا هواء.<br>● <b dir="ltr">v</b> يهتزّ الحلق، و <b dir="ltr">f</b> لا يهتزّ.<br>● الحركات القصيرة <b dir="ltr">a e i o u</b>.<br>● <b dir="ltr">b</b> و <b dir="ltr">d</b> متشابهان.</div>`)}
      ${sec(3, 'ما نتجنّبه', `<div style="font-size:12pt;line-height:1.9">● الحفظ دون قراءة حقيقيّة.<br>● ترجمة كلّ كلمة إلى العربيّة.<br>● الصراخ عند الخطأ.<br>● الجلسات الطويلة.</div>`)}
      ${sec(4, 'علامات التقدّم', `<div style="font-size:12pt;line-height:1.9">● يقول صوت الحرف بسرعة.<br>● يسمع الصوت الأوّل في الكلمة.<br>● يدمج ثلاثة أصوات في كلمة.<br>● يكتب الحرف بالاتّجاه الصحيح.</div>`)}
    </div>`));
  pages.push(P(`${H('How to use this book', 'كيف تستعمل هذا الكتاب؟', { tag: 'Teacher' })}
    <div class="sec" style="direction:rtl;font-size:12pt;line-height:1.75">يعالج هذا المستوى أهمّ فجوة عند الطفل العربيّ المتلكّئ في الإنكليزيّة: <b>ربط الحرف بصوته</b>. المرجع: <b>الصوتيّات المنهجيّة</b> التي توصي بها المراجعات الكبرى (NRP 2000، Rose 2006). نبدأ بترتيب <b dir="ltr">s a t p i n</b> لأنّه يتيح قراءة كلمات حقيقيّة بعد أربعة حروف فقط.</div>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:3.5mm;direction:rtl">${[['ابدأ بالتشخيص', 'حدّد الحروف التي لا يعرف التلميذ أصواتها.'], ['صفحتان لكلّ حرف', 'أتعرّف (الصوت والصورة والتتبّع) ← أتدرّب (الصوت الأوّل، البحث، التلوين).'], ['الدمج مبكّراً', 'بعد كلّ مجموعة صفحة «أدمج وأقرأ» بأزرار صوتيّة: نقطة تحت كلّ صوت.'], ['ترميز الألوان', 'الحركات بالأحمر والصوامت بالأزرق في كلّ الكتاب.'], ['صعوبات العربيّ', 'صفحات خاصّة: p/b، v/f، b d p q.'], ['الطلاقة والتفكير', 'دقيقة أصوات في المراجعة، وتحدّي تفكير لكلّ مجموعة.']].map(([t, d], i) => `<div class="sec" style="padding:3mm 4.5mm"><div class="t"><i>${hd(i + 1)}</i><span>${t}</span></div><div style="font-size:11pt;line-height:1.65">${d}</div></div>`).join('')}</div>
    <div class="parent" style="direction:rtl;font-size:11pt"><b>ملاحظة:</b><span>المحتوى الإنكليزيّ يُقرأ من اليسار إلى اليمين، والترجمة العربيّة تحت كلّ تعليمة لمساعدة الطفل والأهل.</span></div>`));
  pages.push(...diag('Starting check', 'Start'));
  pages.push(P(`${H('My progress', 'جدول متابعة التقدّم', { tag: 'Teacher' })}
    <table style="font-size:11pt;font-family:Fredoka"><thead><tr style="height:11mm"><th style="width:20mm">Letter</th><th>Says sound</th><th>First sound</th><th>Writes</th><th style="width:20mm">Letter</th><th>Says sound</th><th>First sound</th><th>Writes</th></tr></thead>
    <tbody>${Array.from({ length: 13 }, (_, i) => { const a = LET[i].l, b = LET[i + 13].l; return `<tr style="height:15.5mm"><td>${big(a, 20, col(a))}</td><td></td><td></td><td></td><td>${big(b, 20, col(b))}</td><td></td><td></td><td></td></tr>`; }).join('')}</tbody></table>`));
  pages.push(alphabetChart());
  return pages;
}

function game() {
  const cells = Array.from({ length: 30 }, (_, i) => i);
  const letters = shuffle(('satpinmdgockeurhbfljvwxyz').split(''), 2);
  const rows = [0, 1, 2, 3, 4].map(r => { const s = cells.slice(r * 6, r * 6 + 6); return r % 2 ? s.reverse() : s; });
  return P(`${H('Sound race!', 'لعبة سباق الأصوات', { tag: 'Game' })}
  <div class="sec" style="font-family:Fredoka;font-size:12pt;line-height:1.7">Roll the dice and move. Say the sound on your square and a word that starts with it!<span class="ar">أرمي حجر النرد وأتقدّم، ثمّ أقول صوت الحرف وكلمة تبدأ به. من يصل إلى النجمة أوّلاً يفوز!</span></div>
  <div style="display:grid;grid-template-columns:repeat(6,1fr);grid-auto-rows:1fr;gap:2mm;flex:1">${rows.flat().map(i => `<div class="cell" style="flex-direction:column;background:${['#FEE2E2', '#FFEDD5', '#FEF9C3', '#DCFCE7', '#DBEAFE', '#EDE9FE'][i % 6]}">${i === 29 ? `<div style="width:60%;height:60%">${pic('star', 'pic', true)}</div>` : i === 0 ? '<b style="font-family:Fredoka;font-size:16pt">START</b>' : big(letters[i % letters.length], 30, col(letters[i % letters.length]))}</div>`).join('')}</div>`);
}

async function build(out) {
  K.reset();
  const pages = [...front(), K.P(`${H('My adventure map', 'خريطة مغامرتي', { tag: 'Map' })}${sami('Colour a station each time you finish a group!', 'ألوّن محطّة كلّما أنهيت مجموعة حروف.')}<div style="flex:1;min-height:0">${M.svg('0 0 1000 1100', (() => { const pts = GROUPS.map((_, i) => [i % 2 ? 720 : 280, 120 + i * 160]); return `<path d="M${pts.map(p => p.join(' ')).join(' L')} L500 1060" fill="none" stroke="#111" stroke-width="10" stroke-dasharray="4 22" stroke-linecap="round"/>` + pts.map(([x, y], i) => `<circle cx="${x}" cy="${y}" r="70" fill="#fff" stroke="${MTC[i]}" stroke-width="10"/><text x="${x}" y="${y + 18}" text-anchor="middle" font-family="Andika" font-weight="700" font-size="44">${GROUPS[i].slice(0, 4).join(' ')}</text>`).join('') + `<text x="500" y="1080" text-anchor="middle" font-family="Fredoka" font-weight="700" font-size="44">★ Certificate</text>`; })())}</div>`)];
  GROUPS.forEach((g, k) => {
    for (const l of g) pages.push(meet(byL(l)), practice(byL(l)));
    if (k === 4) pages.push(confusePB());
    if (k === 5) pages.push(confuseVF(), bdpq());
    pages.push(blendPage(k), writeWords(k), ...review(k), think(k));
    if (k === 1) pages.push(colorByLetter('heart', HEART, [['1', 'أسود'], ['2', 'أحمر'], ['.', 'أبيض']], { 1: ['s', 't'], 2: ['a', 'i'], '.': ['m', 'n'] }));
    if (k === 3) pages.push(colorByLetter('fish', FISHP, [['1', 'أسود'], ['2', 'برتقاليّ'], ['3', 'أبيض'], ['.', 'أزرق']], { 1: ['d', 'g'], 2: ['o', 'e'], 3: ['h'], '.': ['c', 'k'] }));
    if (k === 5) pages.push(colorByLetter('tree', TREE, [['1', 'أسود'], ['2', 'أخضر'], ['3', 'بنّي'], ['.', 'أبيض']], { 1: ['b', 'l'], 2: ['f', 'v'], 3: ['j'], '.': ['w', 'z'] }));
  });
  pages.push(abcOrder(), game(), ...diag('Final check', 'Finish'));
  let pd = 0;
  while ((pages.length + 1) % 4) pages.push(K.P(`${H('Sound speed check', 'اختبار سرعة الأصوات', { tag: 'Speed', stage: 3 })}${sami('Say the sound of each letter as fast as you can. Beat your score!', 'أقول صوت كلّ حرف بأسرع ما أستطيع، وأحاول أن أتفوّق على نفسي.')}${grid(6, shuffle('abcdefghijklmnopqrstuvwxyzsatpinmd'.split(''), 11 + pd++).map(c => big(rnd(0, 3) ? c : c.toUpperCase(), 34, '#111')))}${timer()}`));
  pages.push(K.P(`<div style="border:1.4mm double #B45309;border-radius:9mm;flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:6mm;text-align:center;padding:12mm;background:radial-gradient(circle at 50% 30%,#FFF8DC,#fff 60%)">
    <div style="height:38mm;width:38mm">${pic('star', 'pic', true)}</div>
    <div style="font-family:Fredoka;font-size:44pt;font-weight:700;color:#B45309">Certificate</div><div style="font-family:Cairo;font-size:18pt;font-weight:900;color:#B45309">شهادة إتقان</div>
    <div style="font-family:Fredoka;font-size:18pt;font-weight:600">Read English with Confidence · Level 1</div>
    <div style="font-family:Fredoka;font-size:16pt;line-height:2.1">This is to certify that<br>.......................................................................<br>knows all 26 letter sounds! <span class="ar">لإتقانه أصوات الحروف الإنكليزيّة الستّة والعشرين</span></div>
    <div style="display:flex;gap:30mm;font-family:Fredoka;font-size:14pt;margin-top:4mm"><span>Teacher: ..................</span><span>Date: ..../..../........</span></div>
    <div>${cw('abc', 40)}</div></div>`));
  await K.render(pages, out);
  return pages.length;
}
const MTC = ['#EF4444', '#F97316', '#F59E0B', '#22C55E', '#3B82F6', '#8B5CF6'];
module.exports = { build };
if (require.main === module) build(path.join(ROOT, 'output/english1-interior.pdf')).then(c => console.log('pages', c));
