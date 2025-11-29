import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityWidget extends StatefulWidget {
  const ConnectivityWidget({super.key});

  @override
  State<ConnectivityWidget> createState() => _ConnectivityWidgetState();
}

class _ConnectivityWidgetState extends State<ConnectivityWidget> {
  static const _batteryChannel = MethodChannel('battery_channel');
  static const _connectivityChannel = MethodChannel('connectivity_channel');

  List<ConnectivityResult> _connectionStatus = [];
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  int _batteryLevel = 0;
  bool _isCharging = false;
  bool _isBluetoothOn = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
    _getBatteryInfo();
    _getBluetoothStatus();
    // Refresh every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _getBatteryInfo();
      _getBluetoothStatus();
    });
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    if (mounted) {
      setState(() {
        _connectionStatus = result;
      });
    }
  }

  Future<void> _getBatteryInfo() async {
    try {
      final result = await _batteryChannel.invokeMethod<Map>('getBatteryInfo');
      if (mounted && result != null) {
        setState(() {
          _batteryLevel = result['level'] ?? 0;
          _isCharging = result['isCharging'] ?? false;
        });
      }
    } catch (e) {
      debugPrint('Battery info failed: $e');
    }
  }

  Future<void> _getBluetoothStatus() async {
    try {
      final result = await _connectivityChannel.invokeMethod<bool>(
        'isBluetoothEnabled',
      );
      if (mounted) {
        setState(() {
          _isBluetoothOn = result ?? false;
        });
      }
    } catch (e) {
      debugPrint('Bluetooth status failed: $e');
      // Fallback - assume off if we can't check
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  bool get _hasWifi => _connectionStatus.contains(ConnectivityResult.wifi);
  bool get _hasMobile => _connectionStatus.contains(ConnectivityResult.mobile);
  bool get _hasVpn => _connectionStatus.contains(ConnectivityResult.vpn);
  bool get _hasNoConnection =>
      _connectionStatus.contains(ConnectivityResult.none) ||
      _connectionStatus.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Connectivity',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatusTile(
                  icon: Icons.wifi,
                  label: 'WiFi',
                  isActive: _hasWifi,
                  activeColor: Colors.blue,
                ),
                _buildStatusTile(
                  icon: Icons.signal_cellular_alt,
                  label: 'Jaringan',
                  isActive: _hasMobile,
                  activeColor: Colors.green,
                ),
                _buildStatusTile(
                  icon: Icons.bluetooth,
                  label: 'Bluetooth',
                  isActive: _isBluetoothOn,
                  activeColor: Colors.indigo,
                ),
                _buildBatteryTile(),
              ],
            ),
          ),
          if (_hasVpn)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purple, width: 1),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.vpn_key, color: Colors.purple, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'VPN Aktif',
                    style: TextStyle(color: Colors.purple, fontSize: 12),
                  ),
                ],
              ),
            ),
          if (_hasNoConnection)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red, width: 1),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.signal_wifi_off, color: Colors.red, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Tidak Ada Koneksi',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusTile({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? activeColor.withOpacity(0.15)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? activeColor : Colors.grey.shade700,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? activeColor : Colors.grey, size: 28),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            isActive ? 'Aktif' : 'Mati',
            style: TextStyle(
              color: isActive ? activeColor : Colors.grey.shade600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryTile() {
    Color batteryColor;
    IconData batteryIcon;

    if (_isCharging) {
      batteryColor = Colors.green;
      batteryIcon = Icons.battery_charging_full;
    } else if (_batteryLevel > 80) {
      batteryColor = Colors.green;
      batteryIcon = Icons.battery_full;
    } else if (_batteryLevel > 50) {
      batteryColor = Colors.lightGreen;
      batteryIcon = Icons.battery_5_bar;
    } else if (_batteryLevel > 20) {
      batteryColor = Colors.orange;
      batteryIcon = Icons.battery_3_bar;
    } else {
      batteryColor = Colors.red;
      batteryIcon = Icons.battery_1_bar;
    }

    return Container(
      decoration: BoxDecoration(
        color: batteryColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: batteryColor, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(batteryIcon, color: batteryColor, size: 28),
          const SizedBox(height: 6),
          const Text(
            'Baterai',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '$_batteryLevel%${_isCharging ? ' ⚡' : ''}',
            style: TextStyle(
              color: batteryColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Compact version untuk carousel
class ConnectivityCompactWidget extends StatefulWidget {
  const ConnectivityCompactWidget({super.key});

  @override
  State<ConnectivityCompactWidget> createState() =>
      _ConnectivityCompactWidgetState();
}

class _ConnectivityCompactWidgetState extends State<ConnectivityCompactWidget> {
  static const _batteryChannel = MethodChannel('battery_channel');

  List<ConnectivityResult> _connectionStatus = [];
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  int _batteryLevel = 0;
  bool _isCharging = false;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
    _getBatteryInfo();
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    if (mounted) setState(() => _connectionStatus = result);
  }

  Future<void> _getBatteryInfo() async {
    try {
      final result = await _batteryChannel.invokeMethod<Map>('getBatteryInfo');
      if (mounted && result != null) {
        setState(() {
          _batteryLevel = result['level'] ?? 0;
          _isCharging = result['isCharging'] ?? false;
        });
      }
    } catch (e) {
      debugPrint('Battery info failed: $e');
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasWifi = _connectionStatus.contains(ConnectivityResult.wifi);
    final hasMobile = _connectionStatus.contains(ConnectivityResult.mobile);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMiniStatus(
            Icons.wifi,
            hasWifi,
            hasWifi ? Colors.blue : Colors.grey,
          ),
          _buildMiniStatus(
            Icons.signal_cellular_alt,
            hasMobile,
            hasMobile ? Colors.green : Colors.grey,
          ),
          _buildBatteryMini(),
        ],
      ),
    );
  }

  Widget _buildMiniStatus(IconData icon, bool active, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildBatteryMini() {
    Color color;
    if (_batteryLevel > 50) {
      color = Colors.green;
    } else if (_batteryLevel > 20) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isCharging ? Icons.battery_charging_full : Icons.battery_std,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            '$_batteryLevel%',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
