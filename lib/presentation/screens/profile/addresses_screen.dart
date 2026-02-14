import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final String? userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null || userId.isEmpty) {
      return;
    }
    await context.read<AddressProvider>().loadAddresses(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('العناوين')),
        body: Consumer<AddressProvider>(
          builder: (context, addressProvider, _) {
            if (addressProvider.isLoading && addressProvider.addresses.isEmpty) {
              return const Center(child: LoadingIndicator());
            }
            if (addressProvider.errorMessage != null && addressProvider.addresses.isEmpty) {
              return AppErrorWidget(
                message: addressProvider.errorMessage!,
                onRetry: _load,
              );
            }
            if (addressProvider.addresses.isEmpty) {
              return const EmptyState(
                title: 'لا توجد عناوين محفوظة',
                subtitle: 'أضف عنوانًا جديدًا للمتابعة.',
                icon: Icons.location_on_outlined,
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (BuildContext context, int index) {
                final address = addressProvider.addresses[index];
                return Card(
                  child: ListTile(
                    title: Text(address.label),
                    subtitle: Text(address.compactAddress),
                    trailing: address.isDefault ? const Chip(label: Text('افتراضي')) : null,
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: addressProvider.addresses.length,
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await context.push(AppRoutes.addAddress);
            if (!mounted) {
              return;
            }
            await _load();
          },
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('إضافة عنوان'),
        ),
      ),
    );
  }
}
