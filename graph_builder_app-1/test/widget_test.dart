import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graph_builder_app/main.dart';

void main() {
  testWidgets('Graph Builder App has a title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    final titleFinder = find.text('Graph Builder');
    expect(titleFinder, findsOneWidget);
  });

  testWidgets('Home screen displays nodes', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // Add more tests to verify the presence of nodes or other widgets
  });
}