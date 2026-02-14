import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class VendorAdsScreen extends StatefulWidget {
  const VendorAdsScreen({super.key});

  @override
  State<VendorAdsScreen> createState() => _VendorAdsScreenState();
}

class _VendorAdsScreenState extends State<VendorAdsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? vendorId = context.read<AuthProvider>().currentUser?.id;
      if (vendorId != null && vendorId.isNotEmpty) {
        context.read<ProductProvider>().loadVendorProducts(vendorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إعلانات المورد')),
        body: Consumer<ProductProvider>(
          builder: (context, productProvider, _) {
            if (productProvider.isLoading && productProvider.vendorProducts.isEmpty) {
              return const Center(child: LoadingIndicator());
            }
            if (productProvider.errorMessage != null && productProvider.vendorProducts.isEmpty) {
              final String? vendorId = context.read<AuthProvider>().currentUser?.id;
              return AppErrorWidget(
                message: productProvider.errorMessage!,
                onRetry: vendorId == null
                    ? null
                    : () => context.read<ProductProvider>().loadVendorProducts(vendorId),
              );
            }
            if (productProvider.vendorProducts.isEmpty) {
              return const EmptyState(
                title: 'لا توجد منتجات لإدارتها',
                subtitle: 'أضف منتجات أولاً ثم فعّل الباقات الإعلانية.',
                icon: Icons.campaign_outlined,
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                const Card(
                  child: ListTile(
                    title: Text('الأسعار الشهرية'),
                    subtitle: Text('برونزي 50,000 • فضي 100,000 • ذهبي 200,000 IQD'),
                  ),
                ),
                const SizedBox(height: 8),
                ...productProvider.vendorProducts.map(
                  (ProductModel product) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text('الباقة الحالية: ${_packageLabel(product.adPackage)}'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<AdPackage>(
                            initialValue: product.adPackage,
                            items: AdPackage.values
                                .map(
                                  (AdPackage package) => DropdownMenuItem<AdPackage>(
                                    value: package,
                                    child: Text(_packageLabel(package)),
                                  ),
                                )
                                .toList(),
                            onChanged: productProvider.isLoading
                                ? null
                                : (AdPackage? value) async {
                                    if (value == null || value == product.adPackage) {
                                      return;
                                    }
                                    final ProductModel updated = product.copyWith(
                                      adPackage: value,
                                      adExpiresAt:
                                          value == AdPackage.none ? null : DateTime.now().add(const Duration(days: 30)),
                                      updatedAt: DateTime.now(),
                                    );
                                    final bool ok = await context.read<ProductProvider>().saveVendorProduct(updated);
                                    if (!context.mounted) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          ok
                                              ? 'تم تحديث الباقة الإعلانية'
                                              : (productProvider.errorMessage ?? 'فشل تحديث الباقة'),
                                        ),
                                      ),
                                    );
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _packageLabel(AdPackage package) {
    switch (package) {
      case AdPackage.none:
        return 'بدون باقة';
      case AdPackage.bronze:
        return 'برونزي';
      case AdPackage.silver:
        return 'فضي';
      case AdPackage.gold:
        return 'ذهبي';
    }
  }
}
