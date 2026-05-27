import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:leaflens/features/dashboard/presentation/widgets/sensor_card.dart';

void _noop() {}

void main() {
  group('SensorCard', () {
    testWidgets('renders sensor name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensorCard(
              sensorName: 'Temperature',
              value: 26,
              unit: '°C',
              unitIcon: Icons.thermostat,
              statusText: 'Temperature is normal',
              gaugeColor: Colors.green,
              onMoreTap: _noop,
            ),
          ),
        ),
      );

      expect(find.text('Temperature'), findsOneWidget);
    });

    testWidgets('renders unit text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensorCard(
              sensorName: 'Temperature',
              value: 26,
              unit: '°C',
              unitIcon: Icons.thermostat,
              statusText: 'Temperature is normal',
              gaugeColor: Colors.green,
              onMoreTap: _noop,
            ),
          ),
        ),
      );

      expect(find.text('°C'), findsOneWidget);
    });

    testWidgets('renders status text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensorCard(
              sensorName: 'Temperature',
              value: 26,
              unit: '°C',
              unitIcon: Icons.thermostat,
              statusText: 'Temperature is normal',
              gaugeColor: Colors.green,
              onMoreTap: _noop,
            ),
          ),
        ),
      );

      expect(find.text('Temperature is normal'), findsOneWidget);
    });

    testWidgets('renders More link', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensorCard(
              sensorName: 'Temperature',
              value: 26,
              unit: '°C',
              unitIcon: Icons.thermostat,
              statusText: 'Temperature is normal',
              gaugeColor: Colors.green,
              onMoreTap: _noop,
            ),
          ),
        ),
      );

      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('does not overflow on standard phone width', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: SensorCard(
                sensorName: 'Soil Moisture',
                value: 90,
                unit: '%',
                unitIcon: Icons.water_drop,
                statusText: 'Saturated',
                gaugeColor: Colors.red,
                onMoreTap: _noop,
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders gauge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensorCard(
              sensorName: 'Humidity',
              value: 64,
              unit: '%',
              unitIcon: Icons.water_drop_outlined,
              statusText: 'Perfect Environment',
              gaugeColor: Colors.green,
              onMoreTap: _noop,
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsAtLeast(1));
    });
  });
}
