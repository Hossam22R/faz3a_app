import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../data/models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/inputs/custom_text_field.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _stockController = TextEditingController(text: '1');

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final String? vendorId = context.read<AuthProvider>().currentUser?.id;
    if (vendorId == null || vendorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب تسجيل الدخول كمورد')),
      );
      return;
    }

    final double price = double.parse(_priceController.text.trim());
    final double? discount = _discountController.text.trim().isEmpty
        ? null
        : double.parse(_discountController.text.trim());
    final int stock = int.parse(_stockController.text.trim());

    final ProductModel product = ProductModel(
      id: 'prd_${DateTime.now().microsecondsSinceEpoch}',
      vendorId: vendorId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: _categoryController.text.trim(),
      price: price,
      discountPrice: discount,
      stock: stock,
      images: const <String>[],
      status: ProductStatus.pending,
      createdAt: DateTime.now(),
    );

    final ProductProvider productProvider = context.read<ProductProvider>();
    final bool saved = await productProvider.saveVendorProduct(product);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'تم إضافة المنتج بنجاح وهو بانتظار الموافقة'
              : (productProvider.errorMessage ?? 'فشل إضافة المنتج'),
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
        appBar: AppBar(title: const Text('إضافة منتج')),
        body: Consumer<ProductProvider>(
          builder: (context, productProvider, _) {
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
                        label: 'حفظ المنتج',
                        isLoading: productProvider.isLoading,
                        onPressed: _submit,
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
