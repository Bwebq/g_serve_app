import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String _prefKey = 'custom_api_base_url';
  static String? _customBaseUrl;

  static const String defaultLanUrl = 'http://192.168.11.164:8000/api';
  static const String defaultHotspotUrl = 'http://192.168.137.1:8000/api';
  static const String defaultEmulatorUrl = 'http://10.0.2.2:8000/api';
  static const String defaultLocalhostUrl = 'http://127.0.0.1:8000/api';

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _customBaseUrl = prefs.getString(_prefKey);
    } catch (e) {
      debugPrint('[ApiConfig] Error loading saved base URL: $e');
    }
  }

  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    if (kIsWeb) {
      return defaultLocalhostUrl;
    }
    if (Platform.isAndroid) {
      // Default to host PC LAN IP so physical devices on Wi-Fi connect seamlessly
      return defaultLanUrl;
    }
    return defaultLocalhostUrl;
  }

  static set customBaseUrl(String? url) {
    if (url != null && url.trim().isNotEmpty) {
      String clean = url.trim();
      if (clean.endsWith('/')) {
        clean = clean.substring(0, clean.length - 1);
      }
      if (!clean.endsWith('/api')) {
        clean = '$clean/api';
      }
      _customBaseUrl = clean;
    } else {
      _customBaseUrl = null;
    }
  }

  static Future<void> saveBaseUrl(String? url) async {
    customBaseUrl = url;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_customBaseUrl != null) {
        await prefs.setString(_prefKey, _customBaseUrl!);
      } else {
        await prefs.remove(_prefKey);
      }
    } catch (e) {
      debugPrint('[ApiConfig] Error saving base URL: $e');
    }
  }

  static const Duration timeoutDuration = Duration(seconds: 6);

  static Map<String, String> headers({String? token, String? division}) {
    final map = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      map['Authorization'] = 'Bearer $token';
    }
    if (division != null && division.isNotEmpty) {
      map['X-Division'] = division;
    }
    return map;
  }
}
