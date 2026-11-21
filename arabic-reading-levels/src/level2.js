// المستوى الثاني: المدود والسكون والتنوين والشدّة والتاء المربوطة وال
const path = require('path');
const { hd, H, shuffle, page, header, sec, renderPDF, ROOT } = require('./common');
const { pic } = require('./pics');
const LV = 2;
const LET = 'ب ت ث ج ح خ د ذ ر ز س ش ص ض ط ظ ع غ ف ق ك ل م ن ه و ي'.split(' ');
const gen = f => LET.map(f);

const U = [
  {
    title: 'المدّ بالألف', explain: 'إذا جاءت الألف بعد حرف عليه فتحة، نمدّ الصوت مدّاً طويلاً: بَـــا.',
    eq: [['بَ', 'فتحة'], '+', ['ا', 'ألف'], '=', ['بَا', 'مدّ']], hero: ['door', 'بَابٌ'],
    table: gen(c => c + H.fatha + 'ا'),
    words: ['بَابٌ', 'دَارٌ', 'نَارٌ', 'تَاجٌ', 'جَارٌ', 'نَامَ', 'قَالَ', 'سَارَ', 'زَارَ', 'كَانَ', 'صَامَ', 'سَحَابٌ'],
    sentences: ['نَامَ سَامِرٌ.', 'زَارَ جَارٌ دَارَنَا.', 'قَالَ بَاسِمٌ: سَلَامٌ.'],
    choose: [['door', '', 'بَابٌ', 'بَبٌ'], ['book', '', 'كِتَابٌ', 'كِتَبٌ'], ['cloud', '', 'سَحَابٌ', 'سَحَبٌ']],
    compose: [['بَا', 'بٌ', 'بَابٌ'], ['نَا', 'مَ', 'نَامَ'], ['سَا', 'رَ', 'سَارَ'], ['تَا', 'جٌ', 'تَاجٌ']],
    pairs: [['بَ', 'بَا'], ['تَ', 'تَا'], ['سَ', 'سَا'], ['نَ', 'نَا'], ['مَ', 'مَا'], ['رَ', 'رَا']],
    parent: 'العبوا لعبة «الصوت الطويل»: تقولون «بَ» فيقول الطفل «بَـــا».',
  },
  {
    title: 'المدّ بالواو', explain: 'إذا جاءت الواو الساكنة بعد حرف عليه ضمّة، نمدّ الصوت: بُـــو.',
    eq: [['بُ', 'ضمّة'], '+', ['و', 'واو'], '=', ['بُو', 'مدّ']], hero: ['whale', 'حُوتٌ'],
    table: gen(c => c + H.damma + 'و'),
    words: ['نُورٌ', 'سُورٌ', 'حُوتٌ', 'تُوتٌ', 'فُولٌ', 'عُودٌ', 'ثُومٌ', 'دُودٌ', 'صُوفٌ', 'يَقُولُ', 'يَكُونُ', 'يَصُومُ'],
    sentences: ['تُوتٌ وَتِينٌ.', 'سُورٌ طَوِيلٌ.', 'يَقُولُ نُوحٌ: شُكْرًا.'],
    choose: [['whale', '', 'حُوتٌ', 'حُتٌ'], ['sheep', '', 'خَرُوفٌ', 'خَرُفٌ'], ['owl', '', 'بُومَةٌ', 'بُمَةٌ']],
    compose: [['نُو', 'رٌ', 'نُورٌ'], ['حُو', 'تٌ', 'حُوتٌ'], ['يَ', 'قُو', 'لُ', 'يَقُولُ'], ['تُو', 'تٌ', 'تُوتٌ']],
    pairs: [['بُ', 'بُو'], ['نُ', 'نُو'], ['حُ', 'حُو'], ['سُ', 'سُو'], ['تُ', 'تُو'], ['دُ', 'دُو']],
    parent: 'ابحثوا مع طفلكم عن كلمات فيها «ـُو» في علب الطعام وعناوين الكتب.',
  },
  {
    title: 'المدّ بالياء', explain: 'إذا جاءت الياء الساكنة بعد حرف عليه كسرة، نمدّ الصوت: بِـــي.',
    eq: [['بِ', 'كسرة'], '+', ['ي', 'ياء'], '=', ['بِي', 'مدّ']], hero: ['elephant', 'فِيلٌ'],
    table: gen(c => c + H.kasra + 'ي'),
    words: ['فِيلٌ', 'تِينٌ', 'طِينٌ', 'دِيكٌ', 'رِيشٌ', 'عِيدٌ', 'كِيسٌ', 'سَعِيدٌ', 'كَبِيرٌ', 'جَمِيلٌ', 'صَغِيرٌ', 'نَخِيلٌ'],
    sentences: ['فِيلٌ كَبِيرٌ.', 'دِيكٌ جَمِيلٌ.', 'عِيدٌ سَعِيدٌ.'],
    choose: [['elephant', '', 'فِيلٌ', 'فِلٌ'], ['palm', '', 'نَخِيلٌ', 'نَخِلٌ'], ['milk', '', 'حَلِيبٌ', 'حَلِبٌ']],
    compose: [['فِي', 'لٌ', 'فِيلٌ'], ['تِي', 'نٌ', 'تِينٌ'], ['دِي', 'كٌ', 'دِيكٌ'], ['كَ', 'بِي', 'رٌ', 'كَبِيرٌ']],
    pairs: [['بِ', 'بِي'], ['فِ', 'فِي'], ['تِ', 'تِي'], ['دِ', 'دِي'], ['سِ', 'سِي'], ['كِ', 'كِي']],
    parent: 'اطلبوا من طفلكم أن يمدّ الصوت مع حركة اليد: يد قصيرة للكسرة، ويد ممدودة لـ«ـِي».',
  },
  {
    title: 'الحركة القصيرة والمدّ', explain: 'الحركة صوت قصير، والمدّ صوت طويل. نستمع جيّداً ونفرّق بينهما.',
    eq: [['بَ', 'قصير'], '|', ['بَا', 'طويل'], '|', ['بُو', 'طويل'], '|', ['بِي', 'طويل']], hero: ['camel', 'جَمَلٌ'],
    table: shuffle(['ب', 'ت', 'ج', 'د', 'ر', 'س', 'ف', 'ل', 'م'].flatMap(c => [c + H.fatha, c + H.fatha + 'ا', c + H.damma + 'و', c + H.kasra + 'ي', c + H.damma, c + H.kasra]), 4).slice(0, 27),
    words: ['جَمَلٌ', 'جَمَالٌ', 'كَتَبَ', 'كِتَابٌ', 'سَحَبَ', 'سَحَابٌ', 'دَرَسَ', 'دُرُوسٌ', 'حَمَلَ', 'حَمَامٌ', 'رَسَمَ', 'رُسُومٌ'],
    sentences: ['كَتَبَ سَامِرٌ كِتَابًا.', 'جَمَلٌ جَمِيلٌ.', 'سَحَابٌ كَثِيرٌ.'],
    choose: [['camel', '', 'جَمَلٌ', 'جَمَالٌ'], ['book', '', 'كِتَابٌ', 'كَتَبَ'], ['cloud', '', 'سَحَابٌ', 'سَحَبَ']],
    compose: [['كِ', 'تَا', 'بٌ', 'كِتَابٌ'], ['جَ', 'مَ', 'لٌ', 'جَمَلٌ'], ['سَ', 'حَا', 'بٌ', 'سَحَابٌ'], ['دُ', 'رُو', 'سٌ', 'دُرُوسٌ']],
    pairs: [['بَا', 'بُو'], ['بُو', 'بِي'], ['سَا', 'سِي'], ['نُو', 'نَا'], ['فِي', 'فُو'], ['رَا', 'رِي']],
    parent: 'اقرؤوا كلمتين متشابهتين (جَمَلٌ / جَمَالٌ) واطلبوا من الطفل أن يرفع يده عند سماع المدّ.',
  },
  {
    title: 'السكون', explain: 'السكون (ـْ) يعني أنّ الحرف بلا حركة، فنقرؤه ملتصقاً بالحرف الذي قبله: أَبْ.',
    eq: [['أَ', ''], '+', ['بْ', 'سكون'], '=', ['أَبْ', 'مقطع']], hero: ['sun', 'شَمْسٌ'],
    table: gen(c => 'أَ' + c + H.sukun),
    words: ['شَمْسٌ', 'بَحْرٌ', 'كَلْبٌ', 'قِرْدٌ', 'ظَرْفٌ', 'طَبْلٌ', 'وَرْدٌ', 'مَوْزٌ', 'بَيْتٌ', 'ثَوْبٌ', 'يَلْعَبُ', 'يَكْتُبُ'],
    sentences: ['يَكْتُبُ سَمِيرٌ.', 'يَلْعَبُ كَلْبٌ صَغِيرٌ.', 'شَمْسٌ وَبَحْرٌ.'],
    choose: [['sun', '', 'شَمْسٌ', 'شَمَسٌ'], ['dog', '', 'كَلْبٌ', 'كَلَبٌ'], ['monkey', '', 'قِرْدٌ', 'قِرَدٌ']],
    compose: [['شَمْ', 'سٌ', 'شَمْسٌ'], ['بَحْ', 'رٌ', 'بَحْرٌ'], ['كَلْ', 'بٌ', 'كَلْبٌ'], ['يَلْ', 'عَ', 'بُ', 'يَلْعَبُ']],
    pairs: [['كَلْ', 'كَ'], ['شَمْ', 'شَ'], ['بَحْ', 'بَ'], ['قِرْ', 'قِ'], ['مَوْ', 'مَ'], ['بَيْ', 'بَ']],
    parent: 'صفّقوا مع كل مقطع: «شَمْ – سٌ»، «كَلْ – بٌ». التصفيق يساعد الطفل على تقطيع الكلمة.',
  },
  {
    title: 'تنوين الضمّ', explain: 'تنوين الضمّ (ـٌ) ضمّتان، ونسمع في آخره صوت نون: بٌ = بُنْ.',
    eq: [['بٌ', 'تنوين ضمّ'], '=', ['بُنْ', 'نسمعه']], hero: ['lion', 'أَسَدٌ'],
    table: gen(c => c + H.un),
    words: ['كِتَابٌ', 'قَلَمٌ', 'بَابٌ', 'وَلَدٌ', 'أَسَدٌ', 'جَمَلٌ', 'مَطَرٌ', 'سَمَكٌ', 'قَمَرٌ', 'عِنَبٌ', 'فِيلٌ', 'نُورٌ'],
    sentences: ['أَسَدٌ وَفِيلٌ.', 'قَلَمٌ وَكِتَابٌ.', 'وَلَدٌ نَشِيطٌ.'],
    choose: [['lion', '', 'أَسَدٌ', 'أَسَدُ'], ['pen', '', 'قَلَمٌ', 'قَلَمُ'], ['fish', '', 'سَمَكٌ', 'سَمَكُ']],
    compose: [['أَ', 'سَ', 'دٌ', 'أَسَدٌ'], ['قَ', 'لَ', 'مٌ', 'قَلَمٌ'], ['مَ', 'طَ', 'رٌ', 'مَطَرٌ'], ['فِي', 'لٌ', 'فِيلٌ']],
    pairs: [['بٌ', 'بُ'], ['سٌ', 'سُ'], ['دٌ', 'دُ'], ['مٌ', 'مُ'], ['رٌ', 'رُ'], ['لٌ', 'لُ']],
    parent: 'سمّوا أشياء البيت بتنوين الضمّ: «بَابٌ، كُوبٌ، قَلَمٌ» واطلبوا من الطفل أن يكرّرها.',
  },
  {
    title: 'تنوين الفتح', explain: 'تنوين الفتح (ـً) فتحتان، وغالباً تأتي بعده ألف لا تُقرأ: بًا = بَنْ.',
    eq: [['بًا', 'تنوين فتح'], '=', ['بَنْ', 'نسمعه']], hero: ['camel', 'أَرَى جَمَلًا'],
    table: gen(c => c + H.an + 'ا'),
    words: ['كِتَابًا', 'قَلَمًا', 'بَابًا', 'وَلَدًا', 'أَسَدًا', 'جَمَلًا', 'سَمَكًا', 'مَطَرًا', 'شُكْرًا', 'عَفْوًا', 'أَهْلًا', 'سَهْلًا'],
    sentences: ['رَسَمَ وَلَدٌ أَسَدًا.', 'أَكَلَ سَمِيرٌ تُوتًا.', 'أَهْلًا وَسَهْلًا.'],
    choose: [['camel', 'أَرَى', 'جَمَلًا', 'جَمَلٌ'], ['book', 'أَرَى', 'كِتَابًا', 'كِتَابٌ'], ['pen', 'أَرَى', 'قَلَمًا', 'قَلَمٌ']],
    compose: [['قَ', 'لَ', 'مًا', 'قَلَمًا'], ['شُكْ', 'رًا', 'شُكْرًا'], ['أَهْ', 'لًا', 'أَهْلًا'], ['وَ', 'لَ', 'دًا', 'وَلَدًا']],
    pairs: [['بًا', 'بَا'], ['مًا', 'مَا'], ['دًا', 'دَا'], ['رًا', 'رَا'], ['لًا', 'لَا'], ['سًا', 'سَا']],
    parent: 'علّموا الطفل كلمات اللطف: «شُكْرًا، عَفْوًا، أَهْلًا» وانتبهوا لصوت النون في آخرها.',
  },
  {
    title: 'تنوين الكسر', explain: 'تنوين الكسر (ـٍ) كسرتان تحت الحرف، ونسمع صوت نون: بٍ = بِنْ.',
    eq: [['بٍ', 'تنوين كسر'], '=', ['بِنْ', 'نسمعه']], hero: ['house', 'فِي بَيْتٍ'],
    table: gen(c => c + H.in),
    words: ['بَيْتٍ', 'بَابٍ', 'قَلَمٍ', 'جَمَلٍ', 'بَحْرٍ', 'وَلَدٍ', 'فِي بَيْتٍ', 'مِنْ بَابٍ', 'بِقَلَمٍ', 'عَلَى جَمَلٍ', 'فِي بَحْرٍ', 'مَعَ وَلَدٍ'],
    sentences: ['كَتَبَ سَمِيرٌ بِقَلَمٍ.', 'سَبَحَ حُوتٌ فِي بَحْرٍ.', 'جَلَسَ وَلَدٌ عَلَى جَمَلٍ.'],
    choose: [['pen', 'أَكْتُبُ بِـ', 'قَلَمٍ', 'قَلَمٌ'], ['house', 'أَسْكُنُ فِي', 'بَيْتٍ', 'بَيْتٌ'], ['camel', 'جَلَسَ عَلَى', 'جَمَلٍ', 'جَمَلًا']],
    compose: [['بَيْ', 'تٍ', 'بَيْتٍ'], ['بَحْ', 'رٍ', 'بَحْرٍ'], ['جَ', 'مَ', 'لٍ', 'جَمَلٍ'], ['بَا', 'بٍ', 'بَابٍ']],
    pairs: [['بٍ', 'بِ'], ['تٍ', 'تِ'], ['رٍ', 'رِ'], ['مٍ', 'مِ'], ['لٍ', 'لِ'], ['كٍ', 'كِ']],
    parent: 'العبوا لعبة «أين؟»: أين القلم؟ «فِي كِيسٍ»، أين الكرة؟ «تَحْتَ كُرْسِيٍّ».',
  },
  {
    title: 'الشدّة', explain: 'الشدّة (ـّ) تعني أنّ الحرف مكتوب مرّة ونقرؤه مرّتين: الأول ساكن والثاني متحرّك.',
    eq: [['بْ', 'ساكن'], '+', ['بَ', 'متحرّك'], '=', ['بَّ', 'شدّة']], hero: ['bear', 'دُبٌّ'],
    table: gen(c => c + H.shadda + H.fatha),
    words: ['دُبٌّ', 'بَطَّةٌ', 'قِطَّةٌ', 'رُمَّانٌ', 'تُفَّاحٌ', 'سُكَّرٌ', 'أُمٌّ', 'عَمٌّ', 'جَدَّةٌ', 'مُعَلِّمٌ', 'رَسَّامٌ', 'حَمَّامٌ'],
    sentences: ['أُمِّي تُحِبُّنِي.', 'رَسَمَ رَسَّامٌ بَطَّةً.', 'أَكَلَ جَدِّي تُفَّاحًا.'],
    choose: [['bear', '', 'دُبٌّ', 'دُبٌ'], ['duck', '', 'بَطَّةٌ', 'بَطَةٌ'], ['cat', '', 'قِطَّةٌ', 'قِطَةٌ']],
    compose: [['دُبْ', 'بٌ', 'دُبٌّ'], ['أُمْ', 'مٌ', 'أُمٌّ'], ['سُكْ', 'كَ', 'رٌ', 'سُكَّرٌ'], ['تُفْ', 'فَا', 'حٌ', 'تُفَّاحٌ']],
    pairs: [['مَدَّ', 'مَدَ'], ['شَدَّ', 'شَدَ'], ['عَدَّ', 'عَدَ'], ['رَدَّ', 'رَدَ'], ['جَدٌّ', 'جَدٌ'], ['عَمٌّ', 'عَمٌ']],
    parent: 'اضغطوا على الحرف المشدّد بصوت أقوى قليلاً: «دُبْ – بٌ»، «سُكْ – كَرٌ».',
  },
  {
    title: 'التاء المربوطة والهاء', explain: 'التاء المربوطة (ة) في آخر الكلمة نقرؤها تاءً عند الوصل وهاءً عند الوقف، أمّا الهاء (ه) فتبقى هاءً.',
    eq: [['ة', 'تاء مربوطة'], '|', ['ه', 'هاء']], hero: ['rose', 'وَرْدَةٌ'],
    table: ['شَجَرَةٌ', 'وَرْدَةٌ', 'سَمَكَةٌ', 'بَقَرَةٌ', 'نَحْلَةٌ', 'غَيْمَةٌ', 'زَرَافَةٌ', 'وَجْهٌ', 'كِتَابُهُ', 'قَلَمُهُ', 'بَيْتُهُ', 'أَبُوهُ', 'مَدْرَسَةٌ', 'فَوَاكِهُ'],
    words: ['شَجَرَةٌ', 'وَرْدَةٌ', 'سَمَكَةٌ', 'بَقَرَةٌ', 'نَحْلَةٌ', 'غَيْمَةٌ', 'مَدْرَسَةٌ', 'وَجْهٌ', 'كِتَابُهُ', 'قَلَمُهُ', 'بَيْتُهُ', 'أَبُوهُ'],
    sentences: ['وَرْدَةٌ جَمِيلَةٌ.', 'نَحْلَةٌ صَغِيرَةٌ.', 'قَرَأَ سَمِيرٌ كِتَابَهُ.'],
    choose: [['rose', '', 'وَرْدَةٌ', 'وَرْدَهٌ'], ['cow', '', 'بَقَرَةٌ', 'بَقَرَهٌ'], ['bee', '', 'نَحْلَةٌ', 'نَحْلَهٌ']],
    compose: [['وَرْ', 'دَ', 'ةٌ', 'وَرْدَةٌ'], ['نَحْ', 'لَ', 'ةٌ', 'نَحْلَةٌ'], ['بَ', 'قَ', 'رَ', 'ةٌ', 'بَقَرَةٌ'], ['وَجْ', 'هٌ', 'وَجْهٌ']],
    pairs: [['سَمَكَةٌ', 'سَمَكٌ'], ['وَرْدَةٌ', 'وَرْدٌ'], ['شَجَرَةٌ', 'شَجَرٌ'], ['نَحْلَةٌ', 'نَحْلٌ'], ['بَقَرَةٌ', 'بَقَرٌ'], ['غَيْمَةٌ', 'غَيْمٌ']],
    parent: 'اطلبوا من الطفل أن يبحث عن «ة» في أسماء أفراد الأسرة والأشياء حوله.',
  },
  {
    title: 'اللام القمريّة', explain: 'اللام القمريّة تُكتب وتُقرأ، وعليها سكون: الْقَمَرُ. حروفها في جملة: «ابْغِ حَجَّكَ وَخَفْ عَقِيمَهُ».',
    eq: [['الْ', 'تُقرأ'], '+', ['قَمَرُ', ''], '=', ['الْقَمَرُ', '']], hero: ['moon', 'الْهِلَالُ'],
    table: ['الْأَسَدُ', 'الْبَابُ', 'الْغَيْمَةُ', 'الْحُوتُ', 'الْجَمَلُ', 'الْكَلْبُ', 'الْوَلَدُ', 'الْخَرُوفُ', 'الْفِيلُ', 'الْعِنَبُ', 'الْقِرْدُ', 'الْيَدُ', 'الْمَوْزُ', 'الْهِلَالُ'],
    words: ['الْقَمَرُ', 'الْبَابُ', 'الْكِتَابُ', 'الْوَلَدُ', 'الْفِيلُ', 'الْجَمَلُ', 'الْحُوتُ', 'الْأَسَدُ', 'الْعِنَبُ', 'الْمَطَرُ', 'الْيَدُ', 'الْخَرُوفُ'],
    sentences: ['الْقَمَرُ جَمِيلٌ.', 'الْوَلَدُ يَقْرَأُ.', 'الْفِيلُ كَبِيرٌ.'],
    choose: [['book', '', 'الْكِتَابُ', 'الْكِّتَابُ'], ['elephant', '', 'الْفِيلُ', 'الْفِّيلُ'], ['moon', '', 'الْهِلَالُ', 'الْهِّلَالُ']],
    compose: [['الْ', 'قَ', 'مَ', 'رُ', 'الْقَمَرُ'], ['الْ', 'بَا', 'بُ', 'الْبَابُ'], ['الْ', 'وَ', 'لَ', 'دُ', 'الْوَلَدُ'], ['الْ', 'فِي', 'لُ', 'الْفِيلُ']],
    pairs: [['الْبَابُ', 'بَابٌ'], ['الْقَمَرُ', 'قَمَرٌ'], ['الْوَلَدُ', 'وَلَدٌ'], ['الْفِيلُ', 'فِيلٌ'], ['الْجَمَلُ', 'جَمَلٌ'], ['الْكِتَابُ', 'كِتَابٌ']],
    parent: 'سمّوا أشياء الغرفة مع «الْ»: الْبَابُ، الْكُرْسِيُّ… وانتبهوا: اللام هنا تُقرأ.',
  },
  {
    title: 'اللام الشمسيّة', explain: 'اللام الشمسيّة تُكتب ولا تُقرأ، ويكون على الحرف الذي بعدها شدّة: الشَّمْسُ.',
    eq: [['ال', 'لا تُقرأ'], '+', ['شَّمْسُ', 'شدّة'], '=', ['الشَّمْسُ', '']], hero: ['sun', 'الشَّمْسُ'],
    table: ['التُّفَّاحُ', 'الثَّعْلَبُ', 'الدُّبُّ', 'الذُّرَةُ', 'الرُّمَّانُ', 'الزَّرَافَةُ', 'السَّمَكُ', 'الشَّمْسُ', 'الصَّدَفَةُ', 'الضِّفْدَعُ', 'الطَّبْلُ', 'الظَّرْفُ', 'اللَّيْمُونُ', 'النَّحْلَةُ'],
    words: ['الشَّمْسُ', 'السَّمَكُ', 'الدُّبُّ', 'النَّحْلَةُ', 'الرُّمَّانُ', 'التُّفَّاحُ', 'الزَّرَافَةُ', 'الطَّبْلُ', 'الصَّدَفَةُ', 'الثَّعْلَبُ', 'الذُّرَةُ', 'اللَّيْمُونُ'],
    sentences: ['الشَّمْسُ سَاطِعَةٌ.', 'السَّمَكُ يَسْبَحُ.', 'النَّحْلَةُ تَطِيرُ.'],
    choose: [['sun', '', 'الشَّمْسُ', 'الشَمْسُ'], ['fish', '', 'السَّمَكُ', 'السَمَكُ'], ['bear', '', 'الدُّبُّ', 'الدُبُّ']],
    compose: [['ال', 'شَّمْ', 'سُ', 'الشَّمْسُ'], ['ال', 'سَّ', 'مَ', 'كُ', 'السَّمَكُ'], ['ال', 'نَّحْ', 'لَ', 'ةُ', 'النَّحْلَةُ'], ['ال', 'زَّ', 'رَا', 'فَ', 'ةُ', 'الزَّرَافَةُ']],
    pairs: [['الشَّمْسُ', 'شَمْسٌ'], ['السَّمَكُ', 'سَمَكٌ'], ['الدُّبُّ', 'دُبٌّ'], ['النَّحْلَةُ', 'نَحْلَةٌ'], ['الرُّمَّانُ', 'رُمَّانٌ'], ['التُّفَّاحُ', 'تُفَّاحٌ']],
    parent: 'العبوا «شمس أم قمر؟»: تقولون كلمة مع «ال» ويقول الطفل هل اللام تُقرأ أم لا.',
  },
];

let n = 0;
const P = inner => page(inner, { n: ++n, level: LV });
const NK = (t, pt, extra = '') => `<span class="nk" style="font-size:${pt}pt;line-height:1.55;${extra}">${t}</span>`;

function eqRow(eq) {
  return `<div class="row" style="align-items:center;gap:2.5mm">${eq.map(tk => typeof tk === 'string'
    ? `<div style="flex:none;font-size:30pt;font-weight:900;width:10mm;text-align:center">${tk === '|' ? '' : tk}</div>`
    : `<div class="cell" style="flex-direction:column;height:36mm">${NK(tk[0], tk[0].length > 4 ? 30 : 42)}<span style="font-size:10pt;font-weight:700">${tk[1]}</span></div>`).join('')}</div>`;
}

function unitA(u, i) {
  const cols = u.table.length > 20 ? 9 : 7;
  const fs = u.table.length > 20 ? 24 : 20;
  return P(`${header(u.title, `الوحدة ${hd(i)}`, LV)}
  <div class="row" style="height:52mm">
    <div class="cell" style="flex:1.4;font-size:14pt;font-weight:700;line-height:1.9;padding:4mm 6mm;text-align:right;justify-content:flex-start">${u.explain}</div>
    <div class="cell" style="flex:1;flex-direction:column;padding:2mm"><div style="height:34mm;width:100%">${pic(u.hero[0])}</div>${NK(u.hero[1], 22)}</div>
  </div>
  ${sec(1, 'أنظرُ وأفهمُ', eqRow(u.eq))}
  ${sec(2, 'أقرأُ', `<div style="display:grid;grid-template-columns:repeat(${cols},1fr);gap:2mm">${u.table.map(t => `<div class="cell" style="height:${cols === 9 ? 17 : 22}mm">${NK(t, fs)}</div>`).join('')}</div>`, 'grow')}
  <div class="parent"><b>ركن الأهل:</b><span>${u.parent}</span></div>`);
}

function unitB(u, i) {
  return P(`${header(`كلمات وجمل: ${u.title}`, `الوحدة ${hd(i)}`, LV)}
  ${sec(1, 'أقرأُ الكلماتِ', `<div style="display:grid;grid-template-columns:repeat(4,1fr);gap:2.6mm">${u.words.map(wd => `<div class="cell" style="height:20mm">${NK(wd, 24)}</div>`).join('')}</div>`, '', 'أقرأ ثمّ أضع ✓ تحت ما قرأتُه وحدي')}
  ${sec(2, 'أقرأُ الجُمَلَ', `<div style="display:flex;flex-direction:column;gap:3mm">${u.sentences.map(s => `<div class="cell" style="height:21mm;justify-content:space-between;padding:0 6mm">${NK(s, 28)}<span style="font-size:13pt;letter-spacing:1mm">☐☐☐</span></div>`).join('')}</div>`, '', 'أقرأ كلّ جملة ثلاث مرّات')}
  ${sec(3, 'أُرَكِّبُ المقاطعَ وأقرأُ الكلمة', `<div style="display:grid;grid-template-columns:1fr 1fr;gap:3mm">${u.compose.map(c => {
    const parts = c.slice(0, -1);
    return `<div class="cell" style="height:21mm;gap:1.5mm;padding:0 2mm">${parts.map(p => `<span style="border:.4mm dashed #111;border-radius:2mm;padding:0 2mm">${NK(p, 20)}</span>`).join('<b>+</b>')}<b>=</b><span style="flex:1;border-bottom:.5mm solid #111;height:12mm"></span></div>`;
  }).join('')}</div>`, 'grow')}`);
}

function unitC(u, i) {
  return P(`${header(`أتدرّب: ${u.title}`, `الوحدة ${hd(i)}`, LV)}
  ${sec(1, 'أضعُ دائرةً حولَ الكلمةِ المناسبةِ للصورة', `<div style="display:flex;flex-direction:column;gap:2.6mm">${u.choose.map(([img, pre, a, b], k) => {
    const opts = k % 2 ? [b, a] : [a, b];
    return `<div class="row" style="height:33mm;align-items:center"><div class="cell" style="flex:0 0 40mm;height:33mm;padding:1.5mm">${pic(img)}</div>
      ${pre ? `<div style="flex:none">${NK(pre, 24)}</div>` : ''}${opts.map(o => `<div class="cell" style="height:24mm">${NK(o, 27)}</div>`).join('')}</div>`;
  }).join('')}</div>`)}
  ${sec(2, 'أنسخُ الكلماتِ بخطٍّ جميل', `<div style="display:grid;grid-template-columns:1fr 1fr;gap:3mm">${u.words.slice(0, 6).map(wd => `<div class="cell" style="height:21mm;justify-content:space-between;padding:0 4mm">${NK(wd, 22)}<span style="width:50%;border-bottom:.5mm solid #111;height:12mm"></span></div>`).join('')}</div>`, 'grow')}`);
}

function unitD(u, i) {
  const flu = shuffle([...u.words, ...u.words], i * 13).slice(0, 20);
  return P(`${header(`أسمع وأقرأ: ${u.title}`, `الوحدة ${hd(i)}`, LV)}
  ${sec(1, 'أسمعُ وأضعُ دائرةً حولَ ما يقرؤه المعلّم', `<div style="display:grid;grid-template-columns:repeat(3,1fr);gap:3mm">${u.pairs.map(([a, b], k) => `<div class="row" style="gap:2mm"><b style="align-self:center;font-size:12pt">${hd(k + 1)}</b>${(k % 2 ? [b, a] : [a, b]).map(o => `<div class="cell" style="height:21mm">${NK(o, 24)}</div>`).join('')}</div>`).join('')}</div>`, '', 'يقرأ المعلّم واحدة فقط من كلّ زوج')}
  ${sec(2, 'أقرأُ بطلاقة', `<div style="display:grid;grid-template-columns:repeat(5,1fr);gap:2.2mm">${flu.map(wd => `<div class="cell" style="height:19mm">${NK(wd, 21)}</div>`).join('')}</div>
     <div class="row" style="margin-top:3mm;font-size:12pt;font-weight:700">${[1, 2, 3].map(k => `<div class="cell" style="height:11mm;font-size:10.5pt">محاولة ${hd(k)}: ..... ثانية · أخطاء: .....</div>`).join('')}</div>`, 'grow', 'يحسب المعلّم الزمن والأخطاء')}
  <div class="parent"><b>نجمة الوحدة:</b><span>أتقنتُ «${u.title}» ☐ نعم ☐ أحتاج تدريباً &nbsp;&nbsp; توقيع المعلّم: ..................</span></div>`);
}

function reviewPage(units, k) {
  const words = shuffle(units.flatMap(u => u.words), k * 5).slice(0, 24);
  const sents = units.map(u => u.sentences[k % 3]);
  return P(`${header(`مراجعة: ${units.map(u => u.title).join(' · ')}`, `مراجعة ${hd(k)}`, LV)}
  ${sec(1, 'أقرأُ الكلمات', `<div style="display:grid;grid-template-columns:repeat(4,1fr);gap:2.4mm">${words.map(wd => `<div class="cell" style="height:19mm;flex-direction:column">${NK(wd, 22)}</div>`).join('')}</div>`)}
  ${sec(2, 'أقرأُ الجُمَل', `<div style="display:flex;flex-direction:column;gap:3mm">${sents.map(s => `<div class="cell" style="height:24mm">${NK(s, 30)}</div>`).join('')}</div>`, 'grow')}
  <div class="sec" style="display:flex;justify-content:space-around;font-size:14pt;font-weight:700;padding:3mm">
    <span>الكلمات الصحيحة: ...... من ${hd(24)}</span><span>الجمل: ...... من ${hd(3)}</span><span>توقيع المعلّم: ..........</span></div>`);
}

function testPage(title, tag, seed) {
  const words = U.flatMap((u, i) => shuffle(u.words, seed + i).slice(0, 2));
  const sents = shuffle(U.map(u => u.sentences[seed % 3]), seed).slice(0, 4);
  return P(`${header(title, tag, LV)}
  ${sec(1, 'أقرأُ الكلمات', `<div style="display:grid;grid-template-columns:repeat(4,1fr);gap:2.4mm">${words.map(wd => `<div class="cell" style="height:19mm;flex-direction:column">${NK(wd, 20)}<span style="border:.4mm solid #111;width:5mm;height:5mm;border-radius:1mm;margin-top:-1mm"></span></div>`).join('')}</div>`, '', 'المعلّم يضع ✓ عند القراءة الصحيحة')}
  ${sec(2, 'أقرأُ الجُمَل', `<div style="display:grid;grid-template-columns:1fr 1fr;gap:3mm">${sents.map(s => `<div class="cell" style="height:21mm">${NK(s, 22)}</div>`).join('')}</div>`, 'grow')}
  <div class="sec" style="display:flex;justify-content:space-around;font-size:14pt;font-weight:700;padding:3.5mm">
    <span>الكلمات: ...... من ${hd(24)}</span><span>الجمل: ...... من ${hd(4)}</span><span>التاريخ: ..../..../........</span></div>`);
}

function titlePage() {
  const imgs = ['whale', 'door', 'bear', 'rose', 'sun', 'elephant'];
  return P(`<div style="border:1.2mm solid #111;border-radius:9mm;flex:1;display:flex;flex-direction:column;align-items:center;padding:12mm 10mm;gap:6mm;text-align:center">
    <div style="font-size:14pt;font-weight:700;border:.6mm solid #111;border-radius:5mm;padding:1mm 6mm">سلسلة علاج الضعف القرائي</div>
    <div style="font-size:66pt;font-weight:900;line-height:1.15">أقرأ بثقة</div>
    <div style="font-size:22pt;font-weight:900;background:#111;color:#fff;border-radius:6mm;padding:2mm 10mm">المستوى الثاني</div>
    <div style="font-size:18pt;font-weight:700;line-height:1.5">أقرأ المدود والسكون والتنوين<br>والشدّة و«ال»</div>
    <div style="display:grid;grid-template-columns:repeat(3,38mm);gap:5mm;margin-top:2mm">${imgs.map(i => `<div style="height:34mm">${pic(i)}</div>`).join('')}</div>
    <div style="margin-top:auto;width:100%;font-size:15pt;line-height:2.4;text-align:right">اسم التلميذ: ............................................................<br>الصف والشعبة: ......................... المدرسة: ..................................</div></div>`);
}

function guidePage() {
  const steps = [
    ['شرط البدء', 'أن يكون التلميذ قد أتقن المستوى الأول (الحروف بالحركات القصيرة).'],
    ['أربع صفحات لكل وحدة', 'أتعرّف ← أقرأ الكلمات والجمل ← أتدرّب ← أسمع وأقرأ بطلاقة.'],
    ['التقطيع والتركيب', 'درّب التلميذ على تقطيع الكلمة إلى مقاطع ثم تركيبها، فهو مفتاح القراءة.'],
    ['قياس الطلاقة', 'سجّل زمن القراءة والأخطاء ثلاث مرّات؛ التحسّن بين المحاولات يحفّز التلميذ.'],
    ['المراجعات', 'بعد كل ثلاث وحدات صفحة مراجعة. لا تنتقل إن قلّت القراءة الصحيحة عن ٨٠٪.'],
    ['البطاقات', 'في آخر الكتاب بطاقات للقصّ تُستعمل في ألعاب القراءة داخل الصف وفي البيت.'],
  ];
  return P(`${header('كيف تستعمل هذا الكتاب؟', 'دليل المعلّم', LV)}
  <div class="sec" style="font-size:12.5pt;line-height:1.75">ينقل هذا المستوى التلميذ من قراءة الحرف إلى قراءة الكلمة والجملة القصيرة، عبر اثنتي عشرة وحدة: المدود الثلاثة، والسكون، والتنوين بأنواعه، والشدّة، والتاء المربوطة، واللام القمريّة والشمسيّة.</div>
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:4mm">${steps.map(([t, d], i) => `<div class="sec" style="padding:3.5mm 4.5mm"><div class="t"><i>${hd(i + 1)}</i><span>${t}</span></div><div style="font-size:11.5pt;line-height:1.7">${d}</div></div>`).join('')}</div>
  ${sec(7, 'محتوى الوحدات', `<div style="display:grid;grid-template-columns:repeat(3,1fr);gap:2mm;font-size:11.5pt;font-weight:700">${U.map((u, i) => `<div>${hd(i + 1)}. ${u.title}</div>`).join('')}</div>`)}
  <div class="parent"><b>للأهل:</b><span>في كل وحدة «ركن الأهل» بنشاط بيتي قصير. عشر دقائق يومياً مع التشجيع تصنع فرقاً كبيراً.</span></div>`);
}

function trackerPage() {
  return P(`${header('جدول متابعة التقدّم', 'للمعلّم', LV)}
  <table style="font-size:11pt"><thead><tr style="height:11mm;background:#eee"><th style="width:44mm">الوحدة</th><th>يقرأ المقاطع</th><th>يقرأ الكلمات</th><th>يقرأ الجمل</th><th>زمن الطلاقة</th><th style="width:30mm">التاريخ</th></tr></thead>
  <tbody>${U.map((u, i) => `<tr style="height:15.5mm"><td style="font-weight:700">${hd(i + 1)}. ${u.title}</td><td></td><td></td><td></td><td></td><td></td></tr>`).join('')}</tbody></table>`);
}

function cardsPage(title, items) {
  return P(`${header(title, 'بطاقات للقصّ', LV)}
  <div style="display:grid;grid-template-columns:repeat(4,1fr);grid-auto-rows:1fr;flex:1;border:.5mm dashed #111">${items.map(t => `<div style="border:.5mm dashed #111;display:flex;align-items:center;justify-content:center">${NK(t, t.length > 4 ? 26 : 36)}</div>`).join('')}</div>
  <div style="text-align:center;font-size:11pt">✂ تُقصّ البطاقات على الخطوط المنقّطة وتُستعمل في ألعاب القراءة</div>`);
}

function certificatePage() {
  return P(`<div style="border:1.4mm double #111;border-radius:9mm;flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:7mm;text-align:center;padding:12mm">
    <div style="height:42mm;width:42mm">${pic('star')}</div>
    <div style="font-size:42pt;font-weight:900">شهادةُ إتقان</div>
    <div style="font-size:20pt;font-weight:700">المستوى الثاني من سلسلة «أقرأ بثقة»</div>
    <div style="font-size:16pt;line-height:2.2">تُمنح هذه الشهادة للتلميذ/ة<br>.......................................................................<br>لإتقانه قراءة الكلمات بالمدود والسكون والتنوين والشدّة</div>
    <div style="display:flex;gap:30mm;font-size:14pt;margin-top:6mm"><span>المعلّم/ة: ..................</span><span>التاريخ: ..../..../........</span></div>
    <div class="row" style="width:120mm;height:30mm;margin-top:4mm">${['whale', 'elephant', 'bear'].map(i => `<div style="flex:1">${pic(i)}</div>`).join('')}</div></div>`);
}

async function build(out) {
  n = 0;
  const pages = [titlePage(), guidePage(), testPage('الاختبار القبلي', 'قبل البدء', 1), trackerPage()];
  U.forEach((u, i) => {
    pages.push(unitA(u, i + 1), unitB(u, i + 1), unitC(u, i + 1), unitD(u, i + 1));
    if ((i + 1) % 3 === 0) pages.push(reviewPage(U.slice(i - 2, i + 1), (i + 1) / 3));
  });
  pages.push(testPage('الاختبار البعدي', 'نهاية المستوى', 2));
  pages.push(cardsPage('بطاقات المدود', shuffle(['بَا', 'تُو', 'سِي', 'نَا', 'فِي', 'لُو', 'مَا', 'رِي', 'دُو', 'كَا', 'جِي', 'حُو', 'قَا', 'زِي', 'نُو', 'شَا', 'طِي', 'عُو', 'هَا', 'وِي'], 3)));
  pages.push(cardsPage('بطاقات الكلمات', shuffle(['شَمْسٌ', 'كَلْبٌ', 'قَلَمًا', 'بَيْتٍ', 'دُبٌّ', 'أُمٌّ', 'وَرْدَةٌ', 'الْقَمَرُ', 'الشَّمْسُ', 'بَابٌ', 'فِيلٌ', 'حُوتٌ', 'سُكَّرٌ', 'بَحْرٍ', 'أَهْلًا', 'نَحْلَةٌ', 'الْوَلَدُ', 'السَّمَكُ', 'يَلْعَبُ', 'كِتَابٌ'], 5)));
  pages.push(certificatePage());
  await renderPDF(pages, out);
  return pages.length;
}
module.exports = { build, U };
if (require.main === module) build(path.join(ROOT, 'output/level2-interior.pdf')).then(c => console.log('pages', c));
