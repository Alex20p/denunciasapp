import 'package:flutter_test/flutter_test.dart';
import 'package:denunciasapp/main.dart';

void main() {
  testWidgets('DenunciasApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DenunciasApp());

    // Verify that the main title exists.
    expect(find.text('Denuncias Ciudadanas'), findsOneWidget);
  });
}
