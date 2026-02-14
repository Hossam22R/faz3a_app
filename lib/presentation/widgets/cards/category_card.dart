import 'package:flutter/material.dart';

import '../../../data/models/category_model.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    required this.category,
    this.onTap,
    super.key,
  });

  final CategoryModel category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              const CircleAvatar(
                child: Icon(Icons.category_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.nameAr ?? category.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.chevron_left_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
