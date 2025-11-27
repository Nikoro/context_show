import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

@isTest
void testWithContext(
  String description,
  Future<void> Function(WidgetTester widgetTester, BuildContext context)
      callback, {
  Timeout? timeout,
}) =>
    testWidgets(description, (tester) async {
      await tester.pumpWidget(MaterialApp(home: SizedBox.shrink()));
      final context = tester.element(find.byType(SizedBox));
      await callback(tester, context);
    }, timeout: timeout);

extension WidgetTesterExtensions on WidgetTester {
  T widgetByType<T extends Widget>() => widget<T>(find.byType(T));
}
