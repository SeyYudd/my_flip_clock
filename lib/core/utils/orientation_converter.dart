import 'package:flutter/services.dart';

/// Utility class for converting between DeviceOrientation and String
/// DRY principle: Don't Repeat Yourself!
class OrientationConverter {
  /// Convert DeviceOrientation to String for storage
  static String toStorageString(DeviceOrientation orientation) {
    switch (orientation) {
      case DeviceOrientation.landscapeLeft:
        return 'landscapeLeft';
      case DeviceOrientation.landscapeRight:
        return 'landscapeRight';
      case DeviceOrientation.portraitUp:
        return 'portraitUp';
      case DeviceOrientation.portraitDown:
        return 'portraitDown';
    }
  }

  /// Convert String to DeviceOrientation from storage
  static DeviceOrientation fromString(String value) {
    switch (value) {
      case 'landscapeLeft':
        return DeviceOrientation.landscapeLeft;
      case 'landscapeRight':
        return DeviceOrientation.landscapeRight;
      case 'portraitUp':
        return DeviceOrientation.portraitUp;
      case 'portraitDown':
        return DeviceOrientation.portraitDown;
      default:
        return DeviceOrientation.portraitUp;
    }
  }

  /// Convert list of DeviceOrientation to list of Strings
  static List<String> listToString(List<DeviceOrientation> orientations) {
    return orientations.map(toStorageString).toList();
  }

  /// Convert list of Strings to list of DeviceOrientation
  static List<DeviceOrientation> listFromString(List<String> values) {
    return values.map(fromString).toList();
  }
}
