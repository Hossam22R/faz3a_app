import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nema_store/app.dart';
import 'package:nema_store/config/dependency_injection/injection_container.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App boots successfully', (WidgetTester tester) async {
    setupDependencies();

    await tester.pumpWidget(const NemaStoreApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
