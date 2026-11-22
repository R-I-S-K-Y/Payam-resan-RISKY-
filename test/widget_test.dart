import 'package:family_messenger/app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login screen is shown first', (tester) async {
    await tester.pumpWidget(const FamilyApp());
    await tester.pumpAndSettle();

    expect(find.text('ورود'), findsWidgets);
    expect(find.text('پیام‌رسان خانواده'), findsWidgets);
  });

  testWidgets('login leads to the chat list', (tester) async {
    await tester.pumpWidget(const FamilyApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText).at(0), 'a@b.c');
    await tester.enterText(find.byType(EditableText).at(1), 'x');
    await tester.ensureVisible(find.text('ورود'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ورود'));
    await tester.pumpAndSettle();

    expect(find.text('گفتگوها'), findsOneWidget);
    expect(find.text('خانواده'), findsWidgets);
  });
}
