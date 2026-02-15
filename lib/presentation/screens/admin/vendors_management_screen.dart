import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user_model.dart';
import '../../providers/vendor_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class VendorsManagementScreen extends StatefulWidget {
  const VendorsManagementScreen({super.key});

  @override
  State<VendorsManagementScreen> createState() => _VendorsManagementScreenState();
}

class _VendorsManagementScreenState extends State<VendorsManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorProvider>().loadVendorsForManagement();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إدارة الموردين')),
        body: Consumer<VendorProvider>(
          builder: (context, vendorProvider, _) {
            if (vendorProvider.isLoading && vendorProvider.vendors.isEmpty) {
              return const Center(child: LoadingIndicator());
            }
            if (vendorProvider.errorMessage != null && vendorProvider.vendors.isEmpty) {
              return AppErrorWidget(
                message: vendorProvider.errorMessage!,
                onRetry: () => context.read<VendorProvider>().loadVendorsForManagement(),
              );
            }
            if (vendorProvider.vendors.isEmpty) {
              return const EmptyState(title: 'لا يوجد موردون لعرضهم');
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (BuildContext context, int index) {
                final UserModel vendor = vendorProvider.vendors[index];
                final bool approved = vendor.isApproved ?? false;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          vendor.storeName ?? vendor.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(vendor.email),
                        Text(vendor.phone),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Chip(
                              label: Text(approved ? 'معتمد' : 'بانتظار/غير معتمد'),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: vendorProvider.isLoading
                                  ? null
                                  : () => _setApproval(vendor.id, true),
                              child: const Text('اعتماد'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: vendorProvider.isLoading
                                  ? null
                                  : () => _setApproval(vendor.id, false),
                              child: const Text('تعليق'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: vendorProvider.vendors.length,
            );
          },
        ),
      ),
    );
  }

  Future<void> _setApproval(String vendorId, bool approved) async {
    final VendorProvider vendorProvider = context.read<VendorProvider>();
    final bool ok = await vendorProvider.setVendorApproval(
      vendorId: vendorId,
      isApproved: approved,
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (approved ? 'تم اعتماد المورد' : 'تم تعليق المورد')
              : (vendorProvider.errorMessage ?? 'فشل تحديث حالة المورد'),
        ),
      ),
    );
  }
}
