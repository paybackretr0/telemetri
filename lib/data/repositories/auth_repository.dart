import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../remote/api_config.dart';
import '../remote/api_response.dart';
import '../local/secure_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final http.Client _client = http.Client();
  final SecureStorage _storage = SecureStorage();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<ApiResponse<User>> signInWithGoogle(
      String idToken,
      String accessToken,
      ) async {
    try {
      // Get FCM device token
      String? deviceToken;
      try {
        deviceToken = await _fcm.getToken();
        print('FCM Device Token: $deviceToken');
      } catch (e) {
        print('Failed to get FCM token: $e');
        // Proceed with login even if token retrieval fails
      }

      // Send login request with device_token
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.googleLogin}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'id_token': idToken,
          'access_token': accessToken,
          'device_token': deviceToken, // Include device_token
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = User.fromJson(data['user']);
        final token = data['access_token'];

        // Store user data and tokens
        await _storage.write(ApiConfig.accessTokenKey, token);
        await _storage.write(ApiConfig.userIdKey, user.id.toString());
        await _storage.write(ApiConfig.userNameKey, user.name);
        await _storage.write(ApiConfig.userEmailKey, user.email);
        await _storage.write(ApiConfig.userRoleKey, user.role);
        await _storage.write(ApiConfig.googleTokenKey, accessToken);

        return ApiResponse(
          success: true,
          message: 'Login successful',
          data: user,
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Authentication failed',
        );
      }
    } catch (e) {
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
