import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/inputs/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final AuthProvider authProvider = context.read<AuthProvider>();
    final bool ok = await authProvider.updateProfile(
      fullName: _fullNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'تم حفظ البيانات' : (authProvider.errorMessage ?? 'فشل تحديث الملف'),
        ),
      ),
    );
  }

  void _initValues(AuthProvider authProvider) {
    if (_initialized || authProvider.currentUser == null) {
      return;
    }
    _fullNameController.text = authProvider.currentUser!.fullName;
    _emailController.text = authProvider.currentUser!.email;
    _phoneController.text = authProvider.currentUser!.phone;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تعديل الملف الشخصي')),
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.currentUser == null) {
              return const EmptyState(
                title: 'لا توجد بيانات مستخدم',
                icon: Icons.person_off_outlined,
              );
            }
            _initValues(authProvider);
            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      CustomTextField(
                        controller: _fullNameController,
                        labelText: 'الاسم الكامل',
                        validator: _required,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'البريد الإلكتروني',
                        keyboardType: TextInputType.emailAddress,
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _phoneController,
                        labelText: 'رقم الهاتف',
                        keyboardType: TextInputType.phone,
                        validator: _required,
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'حفظ',
                        isLoading: authProvider.isLoading,
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

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (!value.contains('@')) {
      return 'بريد إلكتروني غير صالح';
    }
    return null;
  }
}
