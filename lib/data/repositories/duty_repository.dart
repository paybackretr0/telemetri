import 'dart:convert';
import 'package:http/http.dart' as http;
import '../remote/api_response.dart';
import '../remote/api_config.dart';
import '../models/duty_model.dart';
import '../models/user_model.dart';
import '../local/secure_storage.dart';

class DutyRepository {
  final http.Client _client = http.Client();
  final SecureStorage _storage = SecureStorage();

  Future<ApiResponse<List<Duty>>> getDelegableDutySchedules() async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.getDelegableDutySchedules}',
      );

      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<Duty> duties = [];

        if (jsonData != null && jsonData is Map<String, dynamic>) {
          // Check if there's an error message from the backend
          if (jsonData.containsKey('message') &&
              jsonData.containsKey('exception')) {
            print('Backend error: ${jsonData['message']}');
            return ApiResponse(
              success: false,
              message: 'Error dari server: ${jsonData['message']}',
            );
          }

          if (jsonData.containsKey('data')) {
            final dutiesData = jsonData['data'] as List;
            duties =
                dutiesData
                    .map((item) => Duty.fromJson(item as Map<String, dynamic>))
                    .toList();
          }
        }

        return ApiResponse(
          success: true,
          message: 'Berhasil mendapatkan jadwal piket yang dapat didelegasikan',
          data: duties,
        );
      } else {
        print('Error message: ${response.body}');

        // Try to parse error message from JSON if possible
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> &&
              errorData.containsKey('message')) {
            return ApiResponse(
              success: false,
              message:
                  'Gagal mendapatkan jadwal piket: ${errorData['message']}',
            );
          }
        } catch (e) {
          return ApiResponse(
            success: false,
            message: 'Gagal mendapatkan jadwal piket: ${response.statusCode}',
          );
        }

        return ApiResponse(
          success: false,
          message: 'Gagal mendapatkan jadwal piket: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getDelegableDutySchedules: $e');
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  // Get all users who can be potential delegates
  Future<ApiResponse<List<User>>> getPotentialDelegates() async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.getPotentialDelegates}',
      );

      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          final List<dynamic> userData = jsonData['data'] ?? [];
          final List<User> users =
              userData
                  .map((item) => User.fromJson(item as Map<String, dynamic>))
                  .toList();

          return ApiResponse(
            success: true,
            message: 'Berhasil mendapatkan daftar delegasi',
            data: users,
          );
        } else {
          return ApiResponse(
            success: false,
            message: jsonData['message'] ?? 'Gagal mendapatkan daftar delegasi',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: 'Gagal mendapatkan daftar delegasi: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getPotentialDelegates: $e');
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  // Get the authenticated user's duty schedules
  Future<ApiResponse<List<Duty>>> getMyDutySchedules() async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.myDutySchedules}');

      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          final List<dynamic> scheduleData = jsonData['data'] ?? [];
          final List<Duty> duties =
              scheduleData
                  .map((item) => Duty.fromJson(item as Map<String, dynamic>))
                  .toList();

          return ApiResponse(
            success: true,
            message: 'Berhasil mendapatkan jadwal piket',
            data: duties,
          );
        } else {
          print('Error message: ${jsonData['message']}');
          return ApiResponse(
            success: false,
            message: jsonData['message'] ?? 'Gagal mendapatkan jadwal piket',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: 'Gagal mendapatkan jadwal piket: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getMyDutySchedules: $e');
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }
}
