import 'package:bazzone_driver/features/profile/presentation/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('StatCard renders label, value, and icon correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatCard(
            label: 'Заказы',
            value: '4 590',
            icon: Icons.flag_rounded,
          ),
        ),
      ),
    );

    // Verify label and value are shown
    expect(find.text('Заказы'), findsOneWidget);
    expect(find.text('4 590'), findsOneWidget);

    // Verify icon is shown
    expect(find.byIcon(Icons.flag_rounded), findsOneWidget);
  });

  testWidgets('StatCard renders with custom icon widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatCard(
            label: 'Опыт',
            value: '10 лет',
            icon: Icons.circle,
            iconWidget: SteeringWheelIcon(),
          ),
        ),
      ),
    );

    // Verify label and value are shown
    expect(find.text('Опыт'), findsOneWidget);
    expect(find.text('10 лет'), findsOneWidget);

    // Verify SteeringWheelIcon is rendered
    expect(find.byType(SteeringWheelIcon), findsOneWidget);
  });
}
