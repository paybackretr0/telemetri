import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'web_storage_stub.dart' if (dart.library.html) 'web_storage_web.dart';

class SecureStorage {
  static const _secureStorage = FlutterSecureStorage();
  final _webStorage = WebStorage();

  Future<void> write(String key, String value) async {
    if (kIsWeb) {
      _webStorage.setItem(key, value);
    } else {
      await _secureStorage.write(key: key, value: value);
    }
  }

  Future<String?> read(String key) async {
    if (kIsWeb) {
      return _webStorage.getItem(key);
    } else {
      return await _secureStorage.read(key: key);
    }
  }

  Future<void> delete(String key) async {
    if (kIsWeb) {
      _webStorage.removeItem(key);
    } else {
      await _secureStorage.delete(key: key);
    }
  }

  Future<void> deleteAll() async {
    if (kIsWeb) {
      _webStorage.clear();
    } else {
      await _secureStorage.deleteAll();
    }
  }
}
