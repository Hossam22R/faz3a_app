import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config/dependency_injection/app_dependencies.dart';
import 'config/routes/app_router.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/address_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/providers/order_provider.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/providers/review_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/vendor_provider.dart';

class NemaStoreApp extends StatefulWidget {
  const NemaStoreApp({super.key});

  @override
  State<NemaStoreApp> createState() => _NemaStoreAppState();
}

class _NemaStoreAppState extends State<NemaStoreApp> {
  late final router = AppRouter.createRouter(AppDependencies.authSession);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: AppDependencies.authSession),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(AppDependencies.authRepository),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(AppDependencies.productRepository),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (_) => OrderProvider(AppDependencies.orderRepository),
        ),
        ChangeNotifierProvider<VendorProvider>(
          create: (_) => VendorProvider(AppDependencies.vendorRepository),
        ),
        ChangeNotifierProvider<CategoryProvider>(
          create: (_) => CategoryProvider(AppDependencies.categoryRepository),
        ),
        ChangeNotifierProvider<AddressProvider>(
          create: (_) => AddressProvider(AppDependencies.addressRepository),
        ),
        ChangeNotifierProvider<ReviewProvider>(
          create: (_) => ReviewProvider(AppDependencies.reviewRepository),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: router,
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
