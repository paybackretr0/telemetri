import 'dart:convert';
import 'package:http/http.dart' as http;
import '../remote/api_config.dart';
import '../remote/api_response.dart';
import '../local/secure_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final http.Client _client = http.Client();
  final SecureStorage _storage = SecureStorage();

  Future<ApiResponse<User>> signInWithGoogle(
    String idToken,
    String accessToken,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.googleLogin}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'id_token': idToken,
          'access_token':
              accessToken, // Tambahkan access_token untuk akses Calendar
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = User.fromJson(data['user']);
        final token = data['access_token'];

        await _storage.write(ApiConfig.accessTokenKey, token);
        await _storage.write(ApiConfig.userIdKey, user.id.toString());
        await _storage.write(ApiConfig.userNameKey, user.name);
        await _storage.write(ApiConfig.userEmailKey, user.email);
        await _storage.write(ApiConfig.userRoleKey, user.role);
        await _storage.write(
          ApiConfig.googleTokenKey,
          accessToken,
        ); // Simpan Google token

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
        // Call the logout API endpoint
        final response = await _client.post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.logout}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        // Log the response for debugging
        print('Logout API response: ${response.statusCode} - ${response.body}');
      }

      // Clear local storage regardless of API response
      await _storage.deleteAll();

      return ApiResponse(success: true, message: 'Logout successful');
    } catch (e) {
      print('Logout error: $e');
      // Still clear storage even if API call fails
      await _storage.deleteAll();
      return ApiResponse(success: false, message: 'Logout failed: $e');
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
