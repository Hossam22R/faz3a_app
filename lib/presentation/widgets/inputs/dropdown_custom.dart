import 'package:flutter/material.dart';

class DropdownCustom<T> extends StatelessWidget {
  const DropdownCustom({
    required this.items,
    this.value,
    this.hint,
    this.onChanged,
    super.key,
  });

  final List<DropdownMenuItem<T>> items;
  final T? value;
  final String? hint;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
      ),
    );
  }
}
