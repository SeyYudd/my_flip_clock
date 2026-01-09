import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/error_handler.dart';

/// Service for handling geolocation
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _lastPosition;
  bool _isLocationEnabled = false;

  /// Check if location services are available
  Future<bool> isLocationEnabled() async {
    try {
      _isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      return _isLocationEnabled;
    } catch (e) {
      ErrorHandler().handleApiError('Geolocator', e);
      return false;
    }
  }

  /// Request location permission
  Future<bool> requestPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        ErrorHandler().handlePermissionError(
          'Location',
          'Location permission permanently denied',
        );
        return false;
      }

      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      ErrorHandler().handlePermissionError('Location', e.toString());
      return false;
    }
  }

  /// Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      if (!await isLocationEnabled()) {
        return _getCachedLocation();
      }

      if (!await requestPermission()) {
        return _getCachedLocation();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      _lastPosition = position;
      await _cacheLocation(position);

      return position;
    } catch (e) {
      ErrorHandler().handleApiError('getCurrentLocation', e);
      return _getCachedLocation();
    }
  }

  /// Get last known location (from cache)
  Future<Position?> _getCachedLocation() async {
    if (_lastPosition != null) return _lastPosition;

    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('cached_latitude');
      final lon = prefs.getDouble('cached_longitude');

      if (lat != null && lon != null) {
        return Position(
          latitude: lat,
          longitude: lon,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
    } catch (e) {
      ErrorHandler().handleApiError('getCachedLocation', e);
    }

    return null;
  }

  /// Cache location for offline use
  Future<void> _cacheLocation(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('cached_latitude', position.latitude);
      await prefs.setDouble('cached_longitude', position.longitude);
      await prefs.setInt(
        'cached_location_time',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      ErrorHandler().handleApiError('cacheLocation', e);
    }
  }

  /// Get coordinates (returns cached or default if unavailable)
  Future<Map<String, double>> getCoordinates() async {
    final position = await getCurrentLocation();

    if (position != null) {
      return {'latitude': position.latitude, 'longitude': position.longitude};
    }

    // Default to Jakarta as fallback
    return {'latitude': -6.2, 'longitude': 106.8};
  }
}
