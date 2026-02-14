import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

enum _SearchSort {
  relevance,
  newest,
  priceLowToHigh,
  priceHighToLow,
  ratingHighToLow,
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _selectedCategoryId;
  _SearchSort _sortBy = _SearchSort.relevance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final ProductProvider productProvider = context.read<ProductProvider>();
    final CategoryProvider categoryProvider = context.read<CategoryProvider>();
    final List<Future<void>> tasks = <Future<void>>[];

    if (productProvider.featuredProducts.isEmpty) {
      tasks.add(productProvider.loadFeaturedProducts());
    }
    if (categoryProvider.categories.isEmpty) {
      tasks.add(categoryProvider.loadRootCategories());
    }
    if (tasks.isNotEmpty) {
      await Future.wait(tasks);
    }
  }

  Future<void> _refreshSearchData() async {
    final ProductProvider productProvider = context.read<ProductProvider>();
    final CategoryProvider categoryProvider = context.read<CategoryProvider>();
    final List<Future<void>> tasks = <Future<void>>[
      productProvider.loadFeaturedProducts(),
      categoryProvider.loadRootCategories(),
    ];
    if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
      tasks.add(productProvider.loadProductsByCategory(_selectedCategoryId!));
    }
    await Future.wait(tasks);
  }

  Future<void> _onCategorySelected(String? categoryId) async {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    if (categoryId == null || categoryId.isEmpty) {
      return;
    }
    await context.read<ProductProvider>().loadProductsByCategory(categoryId);
  }

  List<ProductModel> _applySearchAndSort(List<ProductModel> source) {
    final String query = _query.trim().toLowerCase();
    final List<ProductModel> filtered = query.isEmpty
        ? source
        : source.where((ProductModel product) {
            final String tags = (product.tags ?? <String>[]).join(' ').toLowerCase();
            return product.name.toLowerCase().contains(query) ||
                product.description.toLowerCase().contains(query) ||
                tags.contains(query);
          }).toList();

    switch (_sortBy) {
      case _SearchSort.relevance:
        return filtered;
      case _SearchSort.newest:
        filtered.sort((ProductModel a, ProductModel b) => b.createdAt.compareTo(a.createdAt));
        return filtered;
      case _SearchSort.priceLowToHigh:
        filtered.sort((ProductModel a, ProductModel b) => a.finalPrice.compareTo(b.finalPrice));
        return filtered;
      case _SearchSort.priceHighToLow:
        filtered.sort((ProductModel a, ProductModel b) => b.finalPrice.compareTo(a.finalPrice));
        return filtered;
      case _SearchSort.ratingHighToLow:
        filtered.sort((ProductModel a, ProductModel b) => b.rating.compareTo(a.rating));
        return filtered;
    }
  }

  String _sortLabel(_SearchSort sort) {
    switch (sort) {
      case _SearchSort.relevance:
        return 'الأكثر صلة';
      case _SearchSort.newest:
        return 'الأحدث';
      case _SearchSort.priceLowToHigh:
        return 'السعر: الأقل أولاً';
      case _SearchSort.priceHighToLow:
        return 'السعر: الأعلى أولاً';
      case _SearchSort.ratingHighToLow:
        return 'الأعلى تقييمًا';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('البحث')),
        body: Consumer2<ProductProvider, CategoryProvider>(
          builder: (context, productProvider, categoryProvider, _) {
            final bool firstLoad = (productProvider.isLoading || categoryProvider.isLoading) &&
                productProvider.featuredProducts.isEmpty &&
                categoryProvider.categories.isEmpty;
            if (firstLoad) {
              return const Center(child: LoadingIndicator());
            }

            final bool hasNoProductData = productProvider.featuredProducts.isEmpty &&
                (_selectedCategoryId == null || productProvider.categoryProducts.isEmpty);
            if (productProvider.errorMessage != null && hasNoProductData) {
              return AppErrorWidget(
                message: productProvider.errorMessage!,
                onRetry: _refreshSearchData,
              );
            }
            if (categoryProvider.errorMessage != null && categoryProvider.categories.isEmpty) {
              return AppErrorWidget(
                message: categoryProvider.errorMessage!,
                onRetry: _refreshSearchData,
              );
            }

            final Map<String, CategoryModel> categoriesById = <String, CategoryModel>{
              for (final CategoryModel category in categoryProvider.categories) category.id: category,
            };
            final List<ProductModel> source = _selectedCategoryId == null
                ? productProvider.featuredProducts
                : productProvider.categoryProducts;
            final List<ProductModel> results = _applySearchAndSort(source);

            return RefreshIndicator(
              onRefresh: _refreshSearchData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: <Widget>[
                  TextField(
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
                  const SizedBox(height: 12),
                  const Text(
                    'التصنيف',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return ChoiceChip(
                            label: const Text('الكل'),
                            selected: _selectedCategoryId == null,
                            onSelected: (_) => _onCategorySelected(null),
                          );
                        }
                        final CategoryModel category = categoryProvider.categories[index - 1];
                        return ChoiceChip(
                          label: Text(category.nameAr ?? category.name),
                          selected: _selectedCategoryId == category.id,
                          onSelected: (_) => _onCategorySelected(category.id),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemCount: categoryProvider.categories.length + 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'الترتيب',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _SearchSort.values.map(
                      (_SearchSort sort) {
                        return ChoiceChip(
                          label: Text(_sortLabel(sort)),
                          selected: _sortBy == sort,
                          onSelected: (_) {
                            setState(() {
                              _sortBy = sort;
                            });
                          },
                        );
                      },
                    ).toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'عدد النتائج: ${results.length}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  if (productProvider.isLoading && source.isEmpty)
                    const SizedBox(
                      height: 90,
                      child: Center(child: LoadingIndicator()),
                    )
                  else if (results.isEmpty)
                    const EmptyState(
                      title: 'لا توجد نتائج',
                      subtitle: 'جرب كلمات بحث مختلفة أو اختر تصنيفًا آخر.',
                      icon: Icons.search_off_rounded,
                    )
                  else
                    ...results.map(
                      (ProductModel product) {
                        final String categoryLabel =
                            categoriesById[product.categoryId]?.nameAr ??
                                categoriesById[product.categoryId]?.name ??
                                product.categoryId;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            child: ListTile(
                              title: Text(product.name),
                              subtitle: Text(
                                '$categoryLabel • ${product.finalPrice.toStringAsFixed(0)} IQD',
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(product.rating.toStringAsFixed(1)),
                                  const Icon(Icons.star_rate_rounded, size: 16),
                                ],
                              ),
                              onTap: () => context.push(AppRoutes.productDetailsLocation(product.id)),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
