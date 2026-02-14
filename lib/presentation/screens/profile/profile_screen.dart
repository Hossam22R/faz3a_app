import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/empty_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الملف الشخصي')),
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final UserModel? user = authProvider.currentUser;
            if (user == null) {
              return const EmptyState(
                title: 'لم يتم تسجيل الدخول',
                subtitle: 'قم بتسجيل الدخول لعرض الملف الشخصي.',
                icon: Icons.person_outline_rounded,
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          user.fullName,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(user.email),
                        Text(user.phone),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: <Widget>[
                            Chip(label: Text(_userTypeLabel(user.userType))),
                            Chip(label: Text(user.isVerified ? 'موثق' : 'غير موثق')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _ProfileActionTile(
                  icon: Icons.edit_outlined,
                  label: 'تعديل الملف الشخصي',
                  onTap: () => context.push(AppRoutes.editProfile),
                ),
                _ProfileActionTile(
                  icon: Icons.location_on_outlined,
                  label: 'العناوين',
                  onTap: () => context.push(AppRoutes.addresses),
                ),
                _ProfileActionTile(
                  icon: Icons.favorite_border_rounded,
                  label: 'المفضلة',
                  onTap: () => context.push(AppRoutes.wishlist),
                ),
                _ProfileActionTile(
                  icon: Icons.shopping_bag_outlined,
                  label: 'طلباتي',
                  onTap: () => context.push(AppRoutes.orders),
                ),
                _ProfileActionTile(
                  icon: Icons.settings_outlined,
                  label: 'الإعدادات',
                  onTap: () => context.push(AppRoutes.settings),
                ),
                if (user.userType == UserType.vendor || user.userType == UserType.admin)
                  _ProfileActionTile(
                    icon: Icons.storefront_outlined,
                    label: 'لوحة المورد',
                    onTap: () => context.push(AppRoutes.vendorDashboard),
                  ),
                if (user.userType == UserType.admin)
                  _ProfileActionTile(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'لوحة الإدارة',
                    onTap: () => context.push(AppRoutes.adminDashboard),
                  ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          await context.read<AuthProvider>().logout();
                          if (!context.mounted) {
                            return;
                          }
                          context.go(AppRoutes.login);
                        },
                  icon: const Icon(Icons.logout),
                  label: const Text('تسجيل الخروج'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _userTypeLabel(UserType type) {
    switch (type) {
      case UserType.customer:
        return 'عميل';
      case UserType.vendor:
        return 'مورد';
      case UserType.admin:
        return 'مدير';
    }
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_left_rounded),
        onTap: onTap,
      ),
    );
  }
}
