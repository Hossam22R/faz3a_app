import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/address_model.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/inputs/custom_text_field.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  bool _isDefault = false;

  @override
  void dispose() {
    _labelController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final String? userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
      );
      return;
    }

    final AddressModel address = AddressModel(
      id: 'addr_${DateTime.now().microsecondsSinceEpoch}',
      userId: userId,
      label: _labelController.text.trim(),
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      area: _areaController.text.trim(),
      street: _streetController.text.trim(),
      building: _buildingController.text.trim().isEmpty ? null : _buildingController.text.trim(),
      landmark: _landmarkController.text.trim().isEmpty ? null : _landmarkController.text.trim(),
      isDefault: _isDefault,
      createdAt: DateTime.now(),
    );

    final AddressProvider addressProvider = context.read<AddressProvider>();
    final bool ok = await addressProvider.saveAddress(address);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'تم حفظ العنوان' : (addressProvider.errorMessage ?? 'فشل حفظ العنوان')),
      ),
    );
    if (ok) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إضافة عنوان')),
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.currentUser == null) {
              return const EmptyState(title: 'لا يمكن إضافة عنوان بدون تسجيل دخول');
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      CustomTextField(
                        controller: _labelController,
                        labelText: 'اسم العنوان (المنزل/العمل)',
                        validator: _required,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _fullNameController,
                        labelText: 'الاسم الكامل',
                        validator: _required,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _phoneController,
                        labelText: 'رقم الهاتف',
                        keyboardType: TextInputType.phone,
                        validator: _required,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _cityController,
                        labelText: 'المدينة',
                        validator: _required,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _areaController,
                        labelText: 'المنطقة',
                        validator: _required,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _streetController,
                        labelText: 'الشارع',
                        validator: _required,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _buildingController,
                        labelText: 'البناية/الشقة (اختياري)',
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _landmarkController,
                        labelText: 'أقرب نقطة دالة (اختياري)',
                      ),
                      const SizedBox(height: 6),
                      SwitchListTile(
                        value: _isDefault,
                        onChanged: (bool value) {
                          setState(() {
                            _isDefault = value;
                          });
                        },
                        title: const Text('تعيين كعنوان افتراضي'),
                      ),
                      const SizedBox(height: 10),
                      Consumer<AddressProvider>(
                        builder: (context, addressProvider, __) {
                          return PrimaryButton(
                            label: 'حفظ العنوان',
                            isLoading: addressProvider.isLoading,
                            onPressed: _submit,
                          );
                        },
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
}
