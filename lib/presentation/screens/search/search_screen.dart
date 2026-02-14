import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../data/models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<ProductProvider>().featuredProducts.isEmpty) {
        context.read<ProductProvider>().loadFeaturedProducts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('البحث')),
        body: Consumer<ProductProvider>(
          builder: (context, productProvider, _) {
            if (productProvider.isLoading && productProvider.featuredProducts.isEmpty) {
              return const Center(child: LoadingIndicator());
            }
            if (productProvider.errorMessage != null && productProvider.featuredProducts.isEmpty) {
              return AppErrorWidget(
                message: productProvider.errorMessage!,
                onRetry: () => context.read<ProductProvider>().loadFeaturedProducts(),
              );
            }

            final String query = _query.trim().toLowerCase();
            final List<ProductModel> source = productProvider.featuredProducts;
            final List<ProductModel> results = query.isEmpty
                ? source
                : source.where((ProductModel product) {
                    final String name = product.name.toLowerCase();
                    final String desc = product.description.toLowerCase();
                    return name.contains(query) || desc.contains(query);
                  }).toList();

            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (String value) {
                      setState(() {
                        _query = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'ابحث عن منتج...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _query = '';
                                });
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: results.isEmpty
                      ? const EmptyState(
                          title: 'لا توجد نتائج',
                          subtitle: 'جرب كلمات بحث مختلفة.',
                          icon: Icons.search_off_rounded,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (BuildContext context, int index) {
                            final ProductModel product = results[index];
                            return Card(
                              child: ListTile(
                                title: Text(product.name),
                                subtitle: Text(
                                  '${product.finalPrice.toStringAsFixed(0)} IQD',
                                ),
                                trailing: const Icon(Icons.chevron_left_rounded),
                                onTap: () =>
                                    context.push(AppRoutes.productDetailsLocation(product.id)),
                              ),
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemCount: results.length,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
