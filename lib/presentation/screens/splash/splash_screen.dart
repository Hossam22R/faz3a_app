import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.storefront_rounded, size: 72, color: AppColors.primaryGold),
              SizedBox(height: 16),
              Text(AppStrings.splashTitle, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text(AppStrings.splashSubtitle, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
