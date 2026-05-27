// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [DashboardRepository] used for streaming and RPC calls.

@ProviderFor(dashboardRepository)
final dashboardRepositoryProvider = DashboardRepositoryProvider._();

/// Provides the [DashboardRepository] used for streaming and RPC calls.

final class DashboardRepositoryProvider
    extends
        $FunctionalProvider<
          DashboardRepository,
          DashboardRepository,
          DashboardRepository
        >
    with $Provider<DashboardRepository> {
  /// Provides the [DashboardRepository] used for streaming and RPC calls.
  DashboardRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardRepositoryHash();

  @$internal
  @override
  $ProviderElement<DashboardRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DashboardRepository create(Ref ref) {
    return dashboardRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardRepository>(value),
    );
  }
}

String _$dashboardRepositoryHash() =>
    r'b57ac1694d73e47baefb3e5b145c06a055a41dcd';

/// Provides a live stream of [DashboardUpdate] events from the WebSocket.

@ProviderFor(dashboardStream)
final dashboardStreamProvider = DashboardStreamProvider._();

/// Provides a live stream of [DashboardUpdate] events from the WebSocket.

final class DashboardStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardUpdate>,
          DashboardUpdate,
          Stream<DashboardUpdate>
        >
    with $FutureModifier<DashboardUpdate>, $StreamProvider<DashboardUpdate> {
  /// Provides a live stream of [DashboardUpdate] events from the WebSocket.
  DashboardStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardStreamHash();

  @$internal
  @override
  $StreamProviderElement<DashboardUpdate> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<DashboardUpdate> create(Ref ref) {
    return dashboardStream(ref);
  }
}

String _$dashboardStreamHash() => r'1693ce513f56cebb022b46f23a3a269cfb54cb18';

/// Watches Supabase auth state and syncs the API client token.
/// Emits the current access token (null if not logged in).

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// Watches Supabase auth state and syncs the API client token.
/// Emits the current access token (null if not logged in).

final class AuthStateProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  /// Watches Supabase auth state and syncs the API client token.
  /// Emits the current access token (null if not logged in).
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'cffee782075ff0a886b3135c26a6e56047690e24';
