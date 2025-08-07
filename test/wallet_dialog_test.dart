import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('private key input is obscured', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(MaterialApp(
      home: AlertDialog(
        content: TextField(
          controller: controller,
          obscureText: true,
        ),
      ),
    ));
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.obscureText, isTrue);
  });
}
