const { INK, setMode, F } = require('./lib');
let uid = 0;
const FONT = 'Fredoka';

function titleSVG(text, mode, y = 178, size = 92) {
  const fill = mode === 'line' ? '#ffffff' : '#ffffff';
  const stroke = mode === 'line' ? INK : '#2b2d42';
  return `<text x="425" y="${y}" text-anchor="middle" font-family="${FONT}" font-weight="700" font-size="${size}" letter-spacing="6"
    fill="${fill}" stroke="${stroke}" stroke-width="${mode === 'line' ? 6 : 10}" stroke-linejoin="round" paint-order="stroke">${text}</text>`;
}

// صفحة تلوين واحدة (850×1100 وحدة = 8.5×11 إنش)
function pageSVG(a, mode = 'line', opts = {}) {
  setMode(mode);
  const id = `c${uid++}`;
  const bg = a.bg(), main = a.main();
  const frame = opts.frame !== false;
  const sky = mode === 'color' ? `<rect x="0" y="0" width="850" height="1100" fill="${a.sky || '#dff3ff'}"/>` : '';
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 850 1100" width="100%" height="100%">
<defs><clipPath id="${id}"><rect x="60" y="60" width="730" height="980" rx="40"/></clipPath></defs>
<g fill="none" stroke="${INK}" stroke-width="7" stroke-linejoin="round" stroke-linecap="round">
<g clip-path="url(#${id})">${sky}${bg}${main}</g>
${frame ? `<rect x="60" y="60" width="730" height="980" rx="40" fill="none" stroke-width="8"/>` : ''}
${opts.title === false ? '' : titleSVG(a.name, mode)}
</g></svg>`;
}

// الرسم وحده بلا إطار أو خلفية (للغلاف)
function artOnly(a, mode = 'color') {
  setMode(mode);
  return `<g fill="none" stroke="${INK}" stroke-width="7" stroke-linejoin="round" stroke-linecap="round">${a.main()}</g>`;
}

module.exports = { pageSVG, artOnly, titleSVG, FONT };
