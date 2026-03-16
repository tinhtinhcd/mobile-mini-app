import 'package:factory_widgetbook/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders the widgetbook shell', (WidgetTester tester) async {
    await tester.pumpWidget(const app.FactoryWidgetbook());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Widgetbook'), findsOneWidget);
    expect(find.text('Navigation'), findsOneWidget);
  });
}
