import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:telemetri/utils/platform_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../data/environment/env_config.dart';

class LoginProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  GoogleSignIn? _googleSignIn;

  User? _user;
  bool _isLoading = false;
  String? _error;

  LoginProvider() {
    _initGoogleSignIn();
  }

  void _initGoogleSignIn() {
    try {
      if (PlatformHelper.isWeb) {
        _googleSignIn = GoogleSignIn(
          clientId: EnvConfig.googleWebClientId,
          scopes: [
            'email',
            'profile',
            'openid',
            'https://www.googleapis.com/auth/calendar',
            'https://www.googleapis.com/auth/calendar.events',
          ],
        );
      } else {
        _googleSignIn = GoogleSignIn(
          scopes: [
            'email',
            'profile',
            'openid',
            'https://www.googleapis.com/auth/calendar',
            'https://www.googleapis.com/auth/calendar.events',
          ],
          serverClientId:
              PlatformHelper.isAndroid ? EnvConfig.googleWebClientId : null,
        );
      }

      if (kDebugMode) {
        debugPrint(
          'GoogleSignIn initialized for ${PlatformHelper.isWeb ? "Web" : "Mobile"}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing GoogleSignIn: $e');
      }
      _setError('Failed to initialize Google Sign-In: $e');
    }
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  Future<void> initAuth() async {
    try {
      _setLoading(true);
      _user = await _authRepository.getCurrentUser();
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> _getUserInfoFromGoogle(
    String accessToken,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('https://www.googleapis.com/oauth2/v2/userinfo'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        if (kDebugMode) {
          debugPrint('Failed to get user info: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting user info: $e');
      }
      return null;
    }
  }

  Future<bool> signInWithGoogle() async {
    if (_googleSignIn == null) {
      _setError('Google Sign-In not initialized');
      return false;
    }

    try {
      _clearError();
      _setLoading(true);

      final platformName =
          PlatformHelper.isWeb
              ? 'Web'
              : PlatformHelper.isAndroid
              ? 'Android'
              : 'iOS';

      if (kDebugMode) {
        debugPrint('Starting Google Sign-In process for $platformName...');
      }

      try {
        await _googleSignIn!.signOut();
        if (kDebugMode) {
          debugPrint('Previous session cleared');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Sign out error (ignorable): $e');
        }
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (kDebugMode) {
        debugPrint('Initiating Google Sign-In...');
      }
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();

      if (googleUser == null) {
        if (kDebugMode) {
          debugPrint('Google Sign-In cancelled by user');
        }
        _setError('Sign in was cancelled');
        return false;
      }

      if (kDebugMode) {
        debugPrint('Google user obtained: ${googleUser.email}');
      }

      if (kDebugMode) {
        debugPrint('Getting authentication tokens...');
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (kDebugMode) {
        debugPrint('idToken available: ${idToken != null}');
        debugPrint('accessToken available: ${accessToken != null}');
      }

      if (accessToken == null) {
        if (kDebugMode) {
          debugPrint('No access token available');
        }
        _setError('Failed to obtain access token');
        return false;
      }

      Map<String, dynamic>? userInfo;
      if (PlatformHelper.isWeb) {
        if (kDebugMode) {
          debugPrint('Getting user info from Google API for web...');
        }
        userInfo = await _getUserInfoFromGoogle(accessToken);
        if (userInfo == null) {
          _setError('Failed to get user information');
          return false;
        }

        if (idToken == null) {
          idToken = _createWebIdToken(userInfo, accessToken);
          if (kDebugMode) {
            debugPrint('Created web ID token');
          }
        }
      }

      if (idToken == null) {
        if (kDebugMode) {
          debugPrint('No ID token available');
        }
        _setError('Failed to obtain ID token');
        return false;
      }

      if (kDebugMode) {
        debugPrint('Tokens obtained successfully');
        debugPrint('ID Token length: ${idToken.length}');
        debugPrint('Access Token length: ${accessToken.length}');
      }

      if (kDebugMode) {
        debugPrint('Signing in with backend...');
      }

      final response = await _authRepository.signInWithGoogle(
        idToken,
        accessToken,
        userInfo: userInfo,
      );

      if (response.success && response.data != null) {
        if (kDebugMode) {
          debugPrint('Backend authentication successful');
        }
        _user = response.data;
        notifyListeners();
        return true;
      } else {
        if (kDebugMode) {
          debugPrint('Backend authentication failed: ${response.message}');
        }
        _setError(response.message);
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Google Sign-In error: $e');
      }

      String errorMessage = 'Sign in failed';

      if (e.toString().contains('ApiException: 10')) {
        errorMessage =
            'Google Sign-In configuration error. Please check app settings.';
      } else if (e.toString().contains('network_error')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('popup_closed_by_user')) {
        errorMessage = 'Sign in was cancelled';
      } else if (e.toString().contains('access_denied')) {
        errorMessage = 'Access denied. Please allow permissions.';
      } else {
        errorMessage = 'Sign in failed: $e';
      }

      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _createWebIdToken(Map<String, dynamic> userInfo, String accessToken) {
    final header = {'alg': 'none', 'typ': 'JWT'};

    final payload = {
      'iss': 'https://accounts.google.com',
      'aud': EnvConfig.googleWebClientId,
      'sub': userInfo['id'],
      'email': userInfo['email'],
      'email_verified': userInfo['verified_email'] ?? true,
      'name': userInfo['name'],
      'picture': userInfo['picture'],
      'given_name': userInfo['given_name'],
      'family_name': userInfo['family_name'],
      'locale': userInfo['locale'] ?? 'en',
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600,
      'platform': 'web',
      'google_access_token': accessToken,
    };

    final headerEncoded = base64Url.encode(utf8.encode(jsonEncode(header)));
    final payloadEncoded = base64Url.encode(utf8.encode(jsonEncode(payload)));

    final signature = 'web-token';

    return '$headerEncoded.$payloadEncoded.$signature';
  }

  Future<void> logout() async {
    try {
      _setLoading(true);
      await _authRepository.logout();
      if (_googleSignIn != null) {
        await _googleSignIn!.signOut();
      }
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
