import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../data/models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class VendorProductsScreen extends StatefulWidget {
  const VendorProductsScreen({super.key});

  @override
  State<VendorProductsScreen> createState() => _VendorProductsScreenState();
}

class _VendorProductsScreenState extends State<VendorProductsScreen> {
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
        appBar: AppBar(
          title: const Text('منتجات المورد'),
          actions: <Widget>[
            IconButton(
              onPressed: () => context.push(AppRoutes.addProduct),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
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
              return EmptyState(
                title: 'لا توجد منتجات مضافة',
                subtitle: 'ابدأ بإضافة أول منتج لمتجرك.',
                icon: Icons.inventory_outlined,
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (BuildContext context, int index) {
                final ProductModel product = productProvider.vendorProducts[index];
                return Card(
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                      'السعر: ${product.finalPrice.toStringAsFixed(0)} IQD • المخزون: ${product.stock}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(_statusLabel(product.status)),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => context.push(AppRoutes.editProductLocation(product.id)),
                          child: const Text(
                            'تعديل',
                            style: TextStyle(decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                    onTap: () => context.push(AppRoutes.productDetailsLocation(product.id)),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: productProvider.vendorProducts.length,
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push(AppRoutes.addProduct),
          icon: const Icon(Icons.add_rounded),
          label: const Text('إضافة منتج'),
        ),
      ),
    );
  }

  String _statusLabel(ProductStatus status) {
    switch (status) {
      case ProductStatus.pending:
        return 'بانتظار الموافقة';
      case ProductStatus.approved:
        return 'مقبول';
      case ProductStatus.rejected:
        return 'مرفوض';
      case ProductStatus.outOfStock:
        return 'نفاد مخزون';
    }
  }
}
