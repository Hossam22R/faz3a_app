import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class ProductsApprovalScreen extends StatefulWidget {
  const ProductsApprovalScreen({super.key});

  @override
  State<ProductsApprovalScreen> createState() => _ProductsApprovalScreenState();
}

class _ProductsApprovalScreenState extends State<ProductsApprovalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadPendingProductsForApproval();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('موافقة المنتجات')),
        body: Consumer<ProductProvider>(
          builder: (context, productProvider, _) {
            if (productProvider.isLoading && productProvider.pendingProducts.isEmpty) {
              return const Center(child: LoadingIndicator());
            }
            if (productProvider.errorMessage != null && productProvider.pendingProducts.isEmpty) {
              return AppErrorWidget(
                message: productProvider.errorMessage!,
                onRetry: () => context.read<ProductProvider>().loadPendingProductsForApproval(),
              );
            }
            if (productProvider.pendingProducts.isEmpty) {
              return const EmptyState(
                title: 'لا توجد منتجات بانتظار الموافقة',
                icon: Icons.fact_check_outlined,
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (BuildContext context, int index) {
                final ProductModel product = productProvider.pendingProducts[index];
                return Card(
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
                        Text('Vendor: ${product.vendorId}'),
                        Text('Category: ${product.categoryId}'),
                        Text('Price: ${product.finalPrice.toStringAsFixed(0)} IQD'),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: productProvider.isLoading
                                  ? null
                                  : () => _updateStatus(product.id, ProductStatus.approved),
                              child: const Text('قبول'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: productProvider.isLoading
                                  ? null
                                  : () => _updateStatus(product.id, ProductStatus.rejected),
                              child: const Text('رفض'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: productProvider.pendingProducts.length,
            );
          },
        ),
      ),
    );
  }

  Future<void> _updateStatus(String productId, ProductStatus status) async {
    final ProductProvider productProvider = context.read<ProductProvider>();
    final bool ok = await productProvider.updateProductApprovalStatus(
      productId: productId,
      status: status,
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (status == ProductStatus.approved ? 'تم قبول المنتج' : 'تم رفض المنتج')
              : (productProvider.errorMessage ?? 'فشل تحديث حالة المنتج'),
        ),
      ),
    );
  }
}
