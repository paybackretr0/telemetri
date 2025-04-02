import 'dart:convert';
import 'package:http/http.dart' as http;
import '../remote/api_config.dart';
import '../remote/api_response.dart';
import '../local/secure_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final http.Client _client = http.Client();
  final SecureStorage _storage = SecureStorage();

  Future<ApiResponse<User>> signInWithGoogle(String idToken) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.googleLogin}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'id_token': idToken}),
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
      await _storage.deleteAll();

      return ApiResponse(success: true, message: 'Logout successful');
    } catch (e) {
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
