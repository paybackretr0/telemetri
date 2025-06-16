// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

class WebStorage {
  void setItem(String key, String value) => window.localStorage[key] = value;
  String? getItem(String key) => window.localStorage[key];
  void removeItem(String key) => window.localStorage.remove(key);
  void clear() => window.localStorage.clear();
}
