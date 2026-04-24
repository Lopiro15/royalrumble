import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart';
import 'package:device_info_plus/device_info_plus.dart';

class BluetoothPermissionService {
  static final Location _location = Location();
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<bool> isLocationEnabled() async {
    try {
      return await _location.serviceEnabled();
    } catch (e) {
      debugPrint('Error checking location: $e');
      return false;
    }
  }

  static Future<bool> requestLocationService() async {
    try {
      return await _location.requestService();
    } catch (e) {
      debugPrint('Error requesting location service: $e');
      return false;
    }
  }

  static Future<bool> isBluetoothEnabled() async {
    try {
      return await Permission.bluetooth.serviceStatus.isEnabled;
    } catch (e) {
      debugPrint('Error checking bluetooth: $e');
      return false;
    }
  }

  static Future<void> openSystemSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('Error opening settings: $e');
    }
  }

  static Future<bool> requestAllPermissions() async {
    try {
      // Demander directement sans vérifier le manifeste
      final permissions = [
        Permission.location,
        Permission.bluetooth,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.nearbyWifiDevices,
      ];

      final results = await permissions.request();

      return results.values.every((status) => status.isGranted);
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  static Future<bool> areAllPermissionsGranted() async {
    try {
      return await Permission.location.isGranted &&
          await Permission.bluetooth.isGranted &&
          await Permission.bluetoothAdvertise.isGranted &&
          await Permission.bluetoothConnect.isGranted &&
          await Permission.bluetoothScan.isGranted;
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      return false;
    }
  }

  static Future<bool> prepareAll() async {
    // Vérifier localisation
    bool locationEnabled = await isLocationEnabled();
    if (!locationEnabled) {
      locationEnabled = await requestLocationService();
      if (!locationEnabled) return false;
    }

    // Vérifier Bluetooth
    bool bluetoothEnabled = await isBluetoothEnabled();
    if (!bluetoothEnabled) {
      await openSystemSettings();
      return false;
    }

    // Demander les permissions (sans vérifier le manifeste)
    bool permissionsGranted = await requestAllPermissions();

    return permissionsGranted && locationEnabled && bluetoothEnabled;
  }
}