/// Utility methods for color processing and HEX validation.
class ColorUtils {
  const ColorUtils._();

  /// Validates whether a given string is a valid HEX color code.
  static bool isValidHex(String hexString) {
    final cleanHex = hexString.replaceAll('#', '').trim();
    return (cleanHex.length == 6 || cleanHex.length == 8) &&
        RegExp(r'^[0-9a-fA-F]+$').hasMatch(cleanHex);
  }

  /// Converts a HEX string into an ARGB 32-bit integer.
  static int hexToInt(String hexString) {
    var cleanHex = hexString.replaceAll('#', '').trim();
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }
    return int.parse(cleanHex, radix: 16);
  }
}
