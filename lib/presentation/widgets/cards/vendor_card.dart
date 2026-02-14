import 'package:flutter/material.dart';

import '../../../data/models/user_model.dart';

class VendorCard extends StatelessWidget {
  const VendorCard({
    required this.vendor,
    this.onTap,
    super.key,
  });

  final UserModel vendor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(child: Icon(Icons.storefront_outlined)),
        title: Text(vendor.storeName ?? vendor.fullName),
        subtitle: Text(vendor.storeDescription ?? vendor.email),
        trailing: Text(
          vendor.rating != null ? vendor.rating!.toStringAsFixed(1) : '-',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
