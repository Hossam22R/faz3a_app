// عدّل هذه القيم قبل البناء النهائي (خصوصاً اسم المؤلف)
module.exports = {
  titleLine1: 'HAPPY ANIMALS',
  titleLine2: 'COLORING BOOK',
  subtitle: '30 Cute Animals for Kids Ages 3-8',
  coverSubtitle: 'Big & Easy Pages for Kids Ages 3-8',
  author: 'Your Name',
  // سماكة الورق الأبيض لطباعة أبيض وأسود في KDP (إنش لكل صفحة)
  paperInPerPage: 0.002252,
  copyright: [
    'Happy Animals Coloring Book',
    `Copyright © ${new Date().getFullYear()} Your Name. All rights reserved.`,
    'No part of this book may be reproduced without written permission',
    'from the publisher, except for personal, non-commercial use.',
    'Coloring pages may be copied for the buyer’s own family or classroom.',
  ],
  backBlurb: [
    'Lions, pandas, unicorns, dinosaurs and more!',
    '30 adorable animals with bold, thick lines',
    'that are perfect for little hands.',
  ],
  backBullets: ['Single-sided pages', 'Large 8.5 x 11 in', 'Fun certificate inside'],
};
