import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:telemetri/utils/platform_helper.dart';
import 'package:web/web.dart' as web;

class SecureStorage {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> write(String key, String value) async {
    if (PlatformHelper.isWeb) {
      web.window.localStorage.setItem(key, value);
    } else {
      await _secureStorage.write(key: key, value: value);
    }
  }

  Future<String?> read(String key) async {
    if (PlatformHelper.isWeb) {
      return web.window.localStorage.getItem(key);
    } else {
      return await _secureStorage.read(key: key);
    }
  }

  Future<void> delete(String key) async {
    if (PlatformHelper.isWeb) {
      web.window.localStorage.removeItem(key);
    } else {
      await _secureStorage.delete(key: key);
    }
  }

  Future<void> deleteAll() async {
    if (PlatformHelper.isWeb) {
      web.window.localStorage.clear();
    } else {
      await _secureStorage.deleteAll();
    }
  }
}
