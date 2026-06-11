class CastRoute {
  final String id;
  final String name;
  final String? description;

  const CastRoute({required this.id, required this.name, this.description});

  factory CastRoute.fromMethodChannelPayload(Object? payload) {
    if (payload is! Map) {
      return const CastRoute(id: '', name: 'Cast device');
    }

    final id = payload['id'];
    final name = payload['name'];
    final description = payload['description'];

    return CastRoute(
      id: id is String ? id : '',
      name: name is String && name.trim().isNotEmpty
          ? name.trim()
          : 'Cast device',
      description: description is String && description.trim().isNotEmpty
          ? description.trim()
          : null,
    );
  }
}

class CastRoutePickerState {
  final bool isSearching;
  final bool isConnecting;
  final String? connectingRouteName;
  final List<CastRoute> routes;
  final String? error;

  const CastRoutePickerState({
    required this.isSearching,
    required this.isConnecting,
    required this.routes,
    this.connectingRouteName,
    this.error,
  });

  const CastRoutePickerState.idle()
    : isSearching = false,
      isConnecting = false,
      connectingRouteName = null,
      routes = const [],
      error = null;

  CastRoutePickerState copyWith({
    bool? isSearching,
    bool? isConnecting,
    String? connectingRouteName,
    bool clearConnectingRouteName = false,
    List<CastRoute>? routes,
    String? error,
    bool clearError = false,
  }) {
    return CastRoutePickerState(
      isSearching: isSearching ?? this.isSearching,
      isConnecting: isConnecting ?? this.isConnecting,
      connectingRouteName: clearConnectingRouteName
          ? null
          : connectingRouteName ?? this.connectingRouteName,
      routes: routes ?? this.routes,
      error: clearError ? null : error ?? this.error,
    );
  }

  factory CastRoutePickerState.fromMethodChannelPayload(Object? payload) {
    if (payload is! Map) return const CastRoutePickerState.idle();

    final routes = payload['routes'];
    final connectingRouteName = payload['connectingRouteName'];
    final error = payload['error'];

    return CastRoutePickerState(
      isSearching: payload['isSearching'] == true,
      isConnecting: payload['isConnecting'] == true,
      connectingRouteName:
          connectingRouteName is String && connectingRouteName.trim().isNotEmpty
          ? connectingRouteName.trim()
          : null,
      routes: routes is List
          ? routes
                .map(CastRoute.fromMethodChannelPayload)
                .where((route) => route.id.isNotEmpty)
                .toList(growable: false)
          : const [],
      error: error is String && error.trim().isNotEmpty ? error.trim() : null,
    );
  }
}
