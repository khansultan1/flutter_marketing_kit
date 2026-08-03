/// Represents a target application route specification for screenshot capture.
class NavigationRoute {
  /// Creates a [NavigationRoute] instance.
  const NavigationRoute({
    required this.routePath,
    required this.screenId,
    this.queryParams = const {},
    this.routeArgs = const {},
  });

  /// Path of the route (e.g., `/`, `/premium`).
  final String routePath;

  /// Screen identifier associated with this route.
  final String screenId;

  /// Optional URI query parameters.
  final Map<String, String> queryParams;

  /// Optional route arguments payload.
  final Map<String, dynamic> routeArgs;

  /// Constructs full formatted URI string.
  String get fullUri {
    if (queryParams.isEmpty) return routePath;
    final queryStr =
        queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$routePath?$queryStr';
  }
}
