import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/calendar_model.dart';
import '../remote/api_config.dart';
import '../remote/api_response.dart';
import '../local/secure_storage.dart';

class CalendarRepository {
  final http.Client _client = http.Client();
  final SecureStorage _storage = SecureStorage();

  Future<ApiResponse<List<CalendarEvent>>> getEvents({String? email}) async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);

      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      var queryParams = <String, String>{};
      if (email != null && email.isNotEmpty) {
        queryParams['email'] = email;
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.calendar}',
      ).replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == ApiConfig.statusOk) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final List<dynamic> eventsJson = data['events'] ?? data['data'] ?? [];

          if (eventsJson.isEmpty) {
            return ApiResponse(
              success: true,
              message: 'Tidak ada data kalender',
              data: [],
            );
          }

          final List<CalendarEvent> events =
              eventsJson.map((json) => CalendarEvent.fromJson(json)).toList();

          return ApiResponse(
            success: true,
            message: 'Berhasil mendapatkan data kalender',
            data: events,
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message'] ?? 'Gagal mendapatkan data kalender',
          );
        }
      } else if (response.statusCode == ApiConfig.statusUnauthorized) {
        return ApiResponse(
          success: false,
          message: 'Sesi telah berakhir, silakan login kembali',
        );
      } else {
        try {
          final data = jsonDecode(response.body);
          return ApiResponse(
            success: false,
            message: data['message'] ?? 'Terjadi kesalahan pada server',
          );
        } catch (e) {
          return ApiResponse(
            success: false,
            message: 'Terjadi kesalahan pada server: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Terjadi kesalahan: $e');
    }
  }
}
