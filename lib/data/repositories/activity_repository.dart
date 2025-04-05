import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/activity_model.dart';
import '../remote/api_config.dart';
import '../remote/api_response.dart';
import '../local/secure_storage.dart';

class ActivityRepository {
  final http.Client _client = http.Client();
  final SecureStorage _storage = SecureStorage();

  Future<ApiResponse<List<Activity>>> getActivities({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);

      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      var queryParams = <String, String>{};
      if (type != null) queryParams['type'] = type;
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.activities}',
      ).replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Activity> activities = [];

        if (data != null && data is Map) {
          if (data.containsKey('data')) {
            var activitiesData = data['data'];

            if (activitiesData is List) {
              for (var item in activitiesData) {
                if (item is Map<String, dynamic>) {
                  try {
                    activities.add(Activity.fromJson(item));
                  } catch (e) {
                    ApiResponse(
                      success: false,
                      message: 'Error parsing activity: $e',
                    );
                  }
                }
              }
            } else if (activitiesData is Map &&
                activitiesData.containsKey('data')) {
              var paginatedData = activitiesData['data'];
              if (paginatedData is List) {
                for (var item in paginatedData) {
                  if (item is Map<String, dynamic>) {
                    try {
                      activities.add(Activity.fromJson(item));
                    } catch (e) {
                      ApiResponse(
                        success: false,
                        message: 'Error parsing activity: $e',
                      );
                    }
                  }
                }
              }
            } else if (activitiesData is Map) {
              activitiesData.forEach((key, value) {
                if (value is Map<String, dynamic>) {
                  try {
                    activities.add(Activity.fromJson(value));
                  } catch (e) {
                    ApiResponse(
                      success: false,
                      message: 'Error parsing activity: $e',
                    );
                  }
                }
              });
            }
          }
        }

        return ApiResponse(
          success: true,
          message: 'Berhasil mendapatkan data aktivitas',
          data: activities,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Gagal mendapatkan data aktivitas: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<Activity>> getActivity(int id) async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);

      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.activities}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final responseBody = response.body;

      final data = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        Activity activity;
        try {
          activity = Activity.fromJson(data['data']);
        } catch (e) {
          rethrow;
        }

        return ApiResponse(
          success: true,
          message: 'Berhasil mendapatkan detail aktivitas',
          data: activity,
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Gagal mendapatkan detail aktivitas',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }
}
