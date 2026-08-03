/// Mock data binding container for injecting state into screens during capture.
class MockDataBinding {
  /// Creates a [MockDataBinding] with optional state properties.
  const MockDataBinding({
    this.injectedState = const {},
    this.mockUserData = const {},
  });

  /// Injected application state key-value map.
  final Map<String, dynamic> injectedState;

  /// Mock user profile or session data payload.
  final Map<String, dynamic> mockUserData;

  /// Retrieve an injected state value by key.
  T? getValue<T>(String key) {
    final val = injectedState[key];
    if (val is T) return val;
    return null;
  }
}
