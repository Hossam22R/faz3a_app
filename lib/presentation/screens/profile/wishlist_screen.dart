import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/empty_state.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('المفضلة')),
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final List<String> wishlist = authProvider.currentUser?.wishlist ?? const <String>[];
            if (wishlist.isEmpty) {
              return const EmptyState(
                title: 'لا توجد منتجات في المفضلة',
                subtitle: 'أضف منتجات لتظهر هنا.',
                icon: Icons.favorite_border_rounded,
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (BuildContext context, int index) {
                final String productId = wishlist[index];
                return Card(
                  child: ListTile(
                    title: Text('Product ID: $productId'),
                    subtitle: const Text('اضغط لفتح تفاصيل المنتج'),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: () => context.push(AppRoutes.productDetailsLocation(productId)),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: wishlist.length,
            );
          },
        ),
      ),
    );
  }
}
