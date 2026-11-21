// معاينة سريعة: يرسم كل الحيوانات في شبكة PNG واحدة
const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');
const { pageSVG } = require('./page');
const animals = require('./animals');

(async () => {
  const mode = process.argv[2] || 'line';
  const only = process.argv[3] ? process.argv[3].split(',').map(Number) : null;
  const list = animals.map((a, i) => [a, i]).filter(([, i]) => !only || only.includes(i));
  const font = path.resolve(__dirname, '../node_modules/@fontsource/fredoka/files/fredoka-latin-700-normal.woff2');
  const html = `<html><head><style>@font-face{font-family:Fredoka;font-weight:700;src:url(file://${font})}
  body{margin:0;display:grid;grid-template-columns:repeat(3,425px);gap:6px;background:#888}div{width:425px;height:550px;background:#fff}</style></head>
  <body>${list.map(([a]) => `<div>${pageSVG(a, mode)}</div>`).join('')}</body></html>`;
  const out = path.resolve(__dirname, '../build/preview');
  fs.mkdirSync(out, { recursive: true });
  fs.writeFileSync(out + '/p.html', html);
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: 1290, height: 600 } });
  await p.goto('file://' + out + '/p.html');
  await p.evaluate(() => document.fonts.ready);
  await p.screenshot({ path: `${out}/${mode}.png`, fullPage: true });
  await b.close();
})();
