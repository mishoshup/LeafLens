import 'package:flutter_test/flutter_test.dart';

import 'package:leaflens/app.dart';

void main() {
  group('DashboardScreen', () {
    // TODO: Dashboard is a placeholder ("Dashboard — next build").
    //       Remove skip and write real tests once dashboard is implemented:
    //       - Health Score gauge renders with real data
    //       - Sensor tiles show live telemetry
    //       - Quick action buttons send RPC
    //       - Offline indicator shows when WebSocket drops

    testWidgets('dashboard screen renders', (tester) async {
      // Will test:
      //   - Gauge displays current Growth Health Score
      //   - 4 sensor tiles (moisture, temp, humidity, water level)
      //   - Quick action row (Water Now, Mist Now, Refill)
      //   - Offline banner when disconnected
      //   - Stale indicator when data > 30 minutes old
      expect(true, isTrue);
    }, skip: true);

    testWidgets('tapping quick action sends RPC', (tester) async {
      // Will test:
      //   - Tap "Water Now" → calls dashboardRepo.sendRpc('triggerWatering')
      //   - Spinner shows during loading
      //   - Snackbar on success/failure
      expect(true, isTrue);
    }, skip: true);
  });
}
