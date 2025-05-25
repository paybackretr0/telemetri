import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/history_model.dart';
import '../remote/api_config.dart';
import '../remote/api_response.dart';
import '../local/secure_storage.dart';

class HistoryRepository {
  final http.Client _client = http.Client();
  final SecureStorage _storage = SecureStorage();

  Future<ApiResponse<HistoryData>> getHistory({int page = 1}) async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);

      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      // Buat query parameters
      var queryParams = <String, String>{'page': page.toString()};

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.history}',
      ).replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == ApiConfig.statusOk) {
        if (data['success'] == true) {
          final historyResponse = HistoryResponse.fromJson(data);

          return ApiResponse(
            success: true,
            message: historyResponse.message,
            data: historyResponse.data,
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message'] ?? 'Gagal mendapatkan data riwayat',
          );
        }
      } else if (response.statusCode == ApiConfig.statusUnauthorized) {
        return ApiResponse(
          success: false,
          message: 'Sesi telah berakhir. Silakan login kembali.',
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Terjadi kesalahan pada server',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Terjadi kesalahan: $e');
    }
  }
}
