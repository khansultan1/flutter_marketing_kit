import 'package:navigation_engine/src/models/navigation_route.dart';

/// Observer class for tracking route navigation state and settlement.
class MarketingRouteObserver {
  /// Creates a [MarketingRouteObserver].
  MarketingRouteObserver();

  final List<NavigationRoute> _history = [];
  bool _isSettled = true;

  /// Current active top route.
  NavigationRoute? get currentRoute =>
      _history.isNotEmpty ? _history.last : null;

  /// Whether route transition animations have settled.
  bool get isSettled => _isSettled;

  /// Navigation route history stack.
  List<NavigationRoute> get history => List.unmodifiable(_history);

  /// Called when a new route is pushed.
  void onRoutePushed(NavigationRoute route) {
    _isSettled = false;
    _history.add(route);
  }

  /// Called when the top route is popped.
  void onRoutePopped() {
    if (_history.isNotEmpty) {
      _isSettled = false;
      _history.removeLast();
    }
  }

  /// Mark animation transitions as fully settled.
  void markSettled() {
    _isSettled = true;
  }
}
