/// String utility extension methods for marketing formatting.
extension StringUtils on String {
  /// Capitalizes the first letter of the string.
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Converts snake_case or kebab-case string into Title Case.
  String toTitleCase() {
    if (isEmpty) return this;
    return replaceAll(RegExp('[-_]'), ' ')
        .split(' ')
        .map((word) => word.capitalize())
        .join(' ');
  }
}
