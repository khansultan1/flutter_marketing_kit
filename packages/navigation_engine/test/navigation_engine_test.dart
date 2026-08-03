import 'package:navigation_engine/navigation_engine.dart';
import 'package:test/test.dart';

void main() {
  group('NavigationRoute tests', () {
    test('constructs full URI with query parameters', () {
      const route = NavigationRoute(
        routePath: '/premium',
        screenId: 'premium',
        queryParams: {'source': 'banner', 'ref': '123'},
      );

      expect(route.fullUri, equals('/premium?source=banner&ref=123'));
    });
  });

  group('MockDataBinding tests', () {
    test('retrieves typed values from injected state', () {
      const binding = MockDataBinding(
        injectedState: {'isProUser': true, 'itemCount': 5},
      );

      expect(binding.getValue<bool>('isProUser'), isTrue);
      expect(binding.getValue<int>('itemCount'), equals(5));
      expect(binding.getValue<String>('nonExistent'), isNull);
    });
  });

  group('MarketingRouteObserver and RouteTrigger tests', () {
    test('tracks route navigation and settlement', () async {
      final trigger = RouteTrigger();
      const route = NavigationRoute(
        routePath: '/settings',
        screenId: 'settings',
      );

      final success = await trigger.navigateTo(route: route);
      expect(success, isTrue);

      expect(trigger.observer.currentRoute?.screenId, equals('settings'));
      expect(trigger.observer.isSettled, isTrue);
      expect(trigger.observer.history.length, equals(1));
    });
  });
}
