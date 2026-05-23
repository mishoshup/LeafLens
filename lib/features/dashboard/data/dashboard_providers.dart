import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:leaflens/core/network/api_client.dart';
import 'package:leaflens/core/network/ws_client.dart';
import 'package:leaflens/features/auth/data/auth_repository.dart';
import 'package:leaflens/features/dashboard/domain/dashboard_update.dart';

part 'dashboard_providers.g.dart';

/// Manages the WebSocket connection lifecycle for dashboard streaming.
class DashboardRepository {
  final ApiClient _api;
  final WsClient _ws;
  Stream<DashboardUpdate>? _stream;

  DashboardRepository(this._api, this._ws);

  /// Connect to FastAPI WS and start receiving dashboard updates.
  Stream<DashboardUpdate> connect(String token) {
    if (_stream != null) return _stream!;
    _stream = _ws
        .connect(token)
        .where((raw) => raw['type'] is String)
        .map(DashboardUpdate.fromJson);

    return _stream!;
  }

  /// Send an RPC command to the backend (water, mist, refill).
  Future<void> sendRpc(String method) async {
    await _api.post('/api/rpc', body: {'method': method});
  }

  /// Fetch 30-day history for a sensor key.
  Future<Map<String, dynamic>> fetchHistory(String key, int days) async {
    return _api.get('/api/telemetry/$key', params: {'days': '$days'});
  }

  void dispose() {
    _ws.dispose();
  }
}

// ── Providers ────────────────────────────────────────────

@riverpod
DashboardRepository dashboardRepository(Ref ref) {
  final api = ref.read(apiClientProvider);
  return DashboardRepository(api, WsClient());
}

@riverpod
Stream<DashboardUpdate> dashboardStream(Ref ref) {
  final repo = ref.read(dashboardRepositoryProvider);
  final auth = ref.watch(authStateProvider);

  final token = auth.value;
  if (token == null) return const Stream.empty();

  return repo.connect(token);
}

@Riverpod(keepAlive: true)
Future<String?> authState(Ref ref) async {
  final repo = ref.read(authRepositoryProvider);
  final token = await repo.tryRestore();
  if (token != null) {
    ref.read(apiClientProvider).setToken(token);
  }
  return token;
}
