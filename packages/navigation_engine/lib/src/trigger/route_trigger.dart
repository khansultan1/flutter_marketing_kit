import 'package:navigation_engine/src/models/mock_data_binding.dart';
import 'package:navigation_engine/src/models/navigation_route.dart';
import 'package:navigation_engine/src/observer/marketing_route_observer.dart';

/// Programmatic route trigger for screenshot automation workflows.
class RouteTrigger {
  /// Creates a [RouteTrigger] with an optional observer.
  RouteTrigger({
    MarketingRouteObserver? observer,
  }) : observer = observer ?? MarketingRouteObserver();

  /// Route observer instance.
  final MarketingRouteObserver observer;

  /// Programmatically navigate to [route] and inject [mockBinding].
  Future<bool> navigateTo({
    required NavigationRoute route,
    MockDataBinding mockBinding = const MockDataBinding(),
    Duration settleTimeout = const Duration(seconds: 2),
  }) async {
    observer.onRoutePushed(route);

    // Simulate state injection delay and route transition settlement
    await Future<void>.delayed(const Duration(milliseconds: 100));
    observer.markSettled();

    return observer.isSettled;
  }
}
