import 'package:flutter/material.dart';

class SearchBarCustom extends StatelessWidget {
  const SearchBarCustom({
    this.controller,
    this.onChanged,
    this.hintText = 'ابحث عن منتج أو متجر',
    super.key,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          onPressed: () => controller?.clear(),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
    );
  }
}
