import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../data/models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/inputs/custom_text_field.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({
    required this.productId,
    super.key,
  });

  final String productId;

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.productId.isNotEmpty) {
        context.read<ProductProvider>().loadProductDetails(widget.productId);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _initializeForm(ProductModel product) {
    if (_isInitialized) {
      return;
    }
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _categoryController.text = product.categoryId;
    _priceController.text = product.price.toStringAsFixed(0);
    _discountController.text = product.discountPrice?.toStringAsFixed(0) ?? '';
    _stockController.text = product.stock.toString();
    _isInitialized = true;
  }

  Future<void> _submit(ProductModel existing) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final ProductModel updated = existing.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: _categoryController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      discountPrice: _discountController.text.trim().isEmpty
          ? null
          : double.parse(_discountController.text.trim()),
      stock: int.parse(_stockController.text.trim()),
      updatedAt: DateTime.now(),
    );

    final ProductProvider productProvider = context.read<ProductProvider>();
    final bool saved = await productProvider.saveVendorProduct(updated);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved ? 'تم تحديث المنتج بنجاح' : (productProvider.errorMessage ?? 'فشل تحديث المنتج'),
        ),
      ),
    );
    if (saved) {
      context.go(AppRoutes.vendorProducts);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تعديل المنتج')),
        body: Consumer<ProductProvider>(
          builder: (context, productProvider, _) {
            final ProductModel? product = productProvider.selectedProduct;
            if (productProvider.isLoading && product == null) {
              return const Center(child: LoadingIndicator());
            }
            if (productProvider.errorMessage != null && product == null) {
              return AppErrorWidget(
                message: productProvider.errorMessage!,
                onRetry: widget.productId.isEmpty
                    ? null
                    : () => context.read<ProductProvider>().loadProductDetails(widget.productId),
              );
            }
            if (product == null) {
              return const Center(child: Text('تعذر تحميل بيانات المنتج'));
            }

            _initializeForm(product);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      CustomTextField(
                        controller: _nameController,
                        labelText: 'اسم المنتج',
                        validator: _required,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _descriptionController,
                        labelText: 'الوصف',
                        validator: _required,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _categoryController,
                        labelText: 'معرف التصنيف',
                        validator: _required,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _priceController,
                        labelText: 'السعر',
                        keyboardType: TextInputType.number,
                        validator: _numberRequired,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _discountController,
                        labelText: 'سعر الخصم (اختياري)',
                        keyboardType: TextInputType.number,
                        validator: _optionalNumber,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _stockController,
                        labelText: 'المخزون',
                        keyboardType: TextInputType.number,
                        validator: _numberRequired,
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'حفظ التعديلات',
                        isLoading: productProvider.isLoading,
                        onPressed: () => _submit(product),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }

  String? _numberRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (double.tryParse(value.trim()) == null) {
      return 'قيمة رقمية غير صالحة';
    }
    return null;
  }

  String? _optionalNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (double.tryParse(value.trim()) == null) {
      return 'قيمة رقمية غير صالحة';
    }
    return null;
  }
}
