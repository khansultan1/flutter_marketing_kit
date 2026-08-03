import 'package:shared/shared.dart';
import 'package:test/test.dart';

void main() {
  group('DeviceSpec tests', () {
    test('finds device spec by id', () {
      final pixel = DeviceSpec.findById('pixel9');
      expect(pixel, isNotNull);
      expect(pixel!.name, equals('Google Pixel 9'));

      final iphone = DeviceSpec.findById('iphone16');
      expect(iphone, isNotNull);
      expect(iphone!.type, equals(DeviceType.phone));

      final invalid = DeviceSpec.findById('unknown_device');
      expect(invalid, isNull);
    });
  });

  group('ColorUtils tests', () {
    test('validates hex codes correctly', () {
      expect(ColorUtils.isValidHex('#5E5CE6'), isTrue);
      expect(ColorUtils.isValidHex('00C2FF'), isTrue);
      expect(ColorUtils.isValidHex('#FF5E5CE6'), isTrue);
      expect(ColorUtils.isValidHex('invalid'), isFalse);
      expect(ColorUtils.isValidHex('#12345'), isFalse);
    });

    test('converts hex to int correctly', () {
      expect(ColorUtils.hexToInt('#FF0000'), equals(0xFFFF0000));
      expect(ColorUtils.hexToInt('00FF00'), equals(0xFF00FF00));
    });
  });

  group('StringUtils tests', () {
    test('capitalizes strings correctly', () {
      expect('hello'.capitalize(), equals('Hello'));
      expect(''.capitalize(), equals(''));
    });

    test('converts snake and kebab case to title case', () {
      expect('home_screen'.toTitleCase(), equals('Home Screen'));
      expect('feature-graphic'.toTitleCase(), equals('Feature Graphic'));
    });
  });
}
