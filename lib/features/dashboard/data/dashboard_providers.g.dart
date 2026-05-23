// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dashboardRepository)
final dashboardRepositoryProvider = DashboardRepositoryProvider._();

final class DashboardRepositoryProvider
    extends
        $FunctionalProvider<
          DashboardRepository,
          DashboardRepository,
          DashboardRepository
        >
    with $Provider<DashboardRepository> {
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

@ProviderFor(dashboardStream)
final dashboardStreamProvider = DashboardStreamProvider._();

final class DashboardStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardUpdate>,
          DashboardUpdate,
          Stream<DashboardUpdate>
        >
    with $FutureModifier<DashboardUpdate>, $StreamProvider<DashboardUpdate> {
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

String _$dashboardStreamHash() => r'b9a516e597b279704f6c4b12718ac1ac9b666339';

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

final class AuthStateProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
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
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'3424295b8f2b1c654b565b916280fbb1fe4aa4b1';
