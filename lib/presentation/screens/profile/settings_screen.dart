import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الإعدادات')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return SwitchListTile(
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  title: const Text('الوضع الداكن'),
                  subtitle: Text(themeProvider.isDarkMode ? 'مفعل' : 'غير مفعل'),
                );
              },
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.language_outlined),
                title: const Text('اللغة'),
                subtitle: const Text('العربية (افتراضي حاليًا)'),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock_reset_outlined),
                title: const Text('إعادة تعيين كلمة المرور'),
                onTap: () => context.push(AppRoutes.forgotPassword),
              ),
            ),
            const SizedBox(height: 10),
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return ElevatedButton.icon(
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
