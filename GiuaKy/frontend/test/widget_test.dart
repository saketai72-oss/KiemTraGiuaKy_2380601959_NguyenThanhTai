import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('TOEIC app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ToeicReadingApp());
    expect(find.text('Luyện Thi TOEIC Reading'), findsOneWidget);
  });
}
