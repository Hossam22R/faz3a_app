import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'البحث',
      description: 'البحث الذكي عن المنتجات والموردين مع الفلاتر.',
      icon: Icons.search_rounded,
    );
  }
}
