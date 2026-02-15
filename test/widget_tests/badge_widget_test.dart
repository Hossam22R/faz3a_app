import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nema_store/presentation/widgets/common/badge_widget.dart';

void main() {
  testWidgets('BadgeWidget renders provided label', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: BadgeWidget(label: 'VIP'),
          ),
        ),
      ),
    );

    expect(find.text('VIP'), findsOneWidget);
    expect(find.byType(BadgeWidget), findsOneWidget);
  });
}
