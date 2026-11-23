// أغلفة «Read English with Confidence» — محرّك الأغلفة نفسه
const path = require('path');
const { renderCovers } = require('../../arabic-reading-levels/src/cover');
const COMMON = {
  title: 'Read English', titlePt: 64, titleTop: 206, series: 'علاج الضعف في الإنكليزيّة · English for struggling readers',
  chips: ['Phonics', 'Letters', 'Sounds', 'Blending', 'Handwriting', 'Colouring', 'Games'],
  badge: ['Research-based', 'Systematic Phonics', 'الصوتيّات المنهجيّة', 'Hear · Say · Write · Read'],
  fine: 'أقرأ الإنكليزيّة بثقة · للتلاميذ المتلكّئين في الإنكليزيّة · تعليمات إنكليزيّة مع ترجمة عربيّة',
  names: ['Level 1', 'Level 2', 'Level 3', 'Level 4'],
};
const LEVELS = [{
  ...COMMON, n: 1, pages: 96, name: 'Level 1 · المستوى الأول', sub: 'Letters & Sounds · أصوات الحروف', thumbs: [9, 7, 17],
  blurb: 'يتعلّم طفلك أصوات الحروف الإنكليزيّة الستّة والعشرين بالصورة والصوت والكتابة، ويقرأ أوّل كلماته بالدمج، مع صفحات خاصّة لأصوات تصعب على الطفل العربيّ (p/b و v/f و b d p q).',
  tiles: ['٢٦ حرفاً بالصوت والصورة', 'ترتيب s a t p i n', 'تتبّع الكتابة بالسطور', 'دمج الكلمات بالنقاط', 'p/b و v/f و b/d', 'تحدّي التفكير', 'ألعاب وتلوين', 'تشخيص وشهادة'],
  sky: ['#1e1b4b', '#4338ca', '#ec4899', '#fde68a'], sun: '#fff5f7', accent: '#f472b6', panel: '#1a1440',
  glyphs: [['A', 640, 820, 270], ['b', 1080, 690, 300], ['c', 1520, 820, 270], ['s', 820, 1120, 200], ['t', 1340, 1120, 200]],
  land: 'taq', hero: 'OWL', heroAt: [1080, 1530, 0.82], night: true,
}];
if (require.main === module) renderCovers(LEVELS.filter(L => !process.argv[2] || process.argv[2].split(',').includes(String(L.n))), path.resolve(__dirname, '../output'), 'english');
module.exports = { LEVELS };
