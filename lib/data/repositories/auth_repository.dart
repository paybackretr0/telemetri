import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart' as firebase;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:telemetri/utils/platform_helper.dart';
import '../remote/api_config.dart';
import '../remote/api_response.dart';
import '../local/secure_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final http.Client _client = http.Client();
  final SecureStorage _storage = SecureStorage();

  Future<ApiResponse<User>> signInWithGoogle(
    String idToken,
    String accessToken, {
    Map<String, dynamic>? userInfo,
  }) async {
    try {
      String? deviceToken;
      if (PlatformHelper.isAndroid) {
        try {
          final fcm = firebase.FirebaseMessaging.instance;
          deviceToken = await fcm.getToken();
          if (kDebugMode) {
            debugPrint('FCM Device Token: $deviceToken');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Failed to get FCM token: $e');
          }
        }
      } else if (PlatformHelper.isWeb) {
        if (kDebugMode) {
          debugPrint('Running on web - FCM token not applicable');
        }
      }

      Map<String, dynamic> requestBody = {
        'id_token': idToken,
        'access_token': accessToken,
      };

      if (PlatformHelper.isWeb && userInfo != null) {
        requestBody.addAll({
          'platform': 'web',
          'user_info': {
            'id': userInfo['id'],
            'email': userInfo['email'],
            'name': userInfo['name'],
            'picture': userInfo['picture'],
            'verified_email': userInfo['verified_email'] ?? true,
          },
        });
      } else {
        requestBody['platform'] = 'mobile';

        if (PlatformHelper.isMobile && deviceToken != null) {
          requestBody['device_token'] = deviceToken;
        }
      }

      if (kDebugMode) {
        debugPrint('Sending authentication request...');
        debugPrint('Request body keys: ${requestBody.keys.toList()}');
        debugPrint('Platform: ${requestBody['platform']}');
        if (PlatformHelper.isWeb) {
          debugPrint('User email: ${requestBody['user_info']?['email']}');
        }
      }

      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.googleLogin}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (kDebugMode) {
        debugPrint('Response status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = User.fromJson(data['user']);
        final token = data['access_token'];

        await _storage.write(ApiConfig.accessTokenKey, token);
        await _storage.write(ApiConfig.userIdKey, user.id.toString());
        await _storage.write(ApiConfig.userNameKey, user.name);
        await _storage.write(ApiConfig.userEmailKey, user.email);
        await _storage.write(ApiConfig.userRoleKey, user.role);
        await _storage.write(ApiConfig.googleTokenKey, accessToken);

        if (kDebugMode) {
          debugPrint('User data stored successfully');
        }

        return ApiResponse(
          success: true,
          message: 'Login successful',
          data: user,
        );
      } else {
        String errorMessage = 'Authentication failed';

        if (data['errors'] != null) {
          Map<String, dynamic> errors = data['errors'];
          List<String> errorMessages = [];

          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.cast<String>());
            } else {
              errorMessages.add(value.toString());
            }
          });

          errorMessage = errorMessages.join(', ');
        } else if (data['message'] != null) {
          errorMessage = data['message'];
        }

        return ApiResponse(success: false, message: errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Auth repository error: $e');
      }
      return ApiResponse(success: false, message: 'Sign in failed: $e');
    }
  }

  Future<ApiResponse<void>> logout() async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);
      if (token != null) {
        await _client.post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.logout}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
      }

      await _storage.deleteAll();

      return ApiResponse(success: true, message: 'Logout successful');
    } catch (e) {
      await _storage.deleteAll();
      return ApiResponse(success: false, message: 'Logout failed: $e');
    }
  }

  Future<ApiResponse<String>> refreshGoogleToken() async {
    try {
      final googleToken = await _storage.read(ApiConfig.googleTokenKey);
      if (googleToken == null) {
        return ApiResponse(
          success: false,
          message: 'Token Google tidak ditemukan',
        );
      }

      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.refresh}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'access_token': googleToken}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final newToken = data['access_token'];
        final newGoogleToken = data['google_token'];

        await _storage.write(ApiConfig.accessTokenKey, newToken);
        await _storage.write(ApiConfig.googleTokenKey, newGoogleToken);

        return ApiResponse(
          success: true,
          message: 'Token berhasil diperbarui',
          data: newToken,
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Gagal memperbarui token',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Refresh token gagal: $e');
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.read(ApiConfig.accessTokenKey);
    return token != null;
  }

  Future<User?> getCurrentUser() async {
    try {
      final id = await _storage.read(ApiConfig.userIdKey);
      final name = await _storage.read(ApiConfig.userNameKey);
      final email = await _storage.read(ApiConfig.userEmailKey);
      final role = await _storage.read(ApiConfig.userRoleKey);
      if (id != null && name != null && email != null && role != null) {
        return User(id: int.parse(id), name: name, email: email, role: role);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
