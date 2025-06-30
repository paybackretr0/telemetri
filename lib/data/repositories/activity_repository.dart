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
    bool myActivitiesOnly = false,
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

      String endpoint =
          myActivitiesOnly
              ? ApiConfig.getCreatedActivities
              : ApiConfig.activities;

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}$endpoint',
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
          if (data.containsKey('success') && data['success'] == true) {
            var activitiesData = data['data'];

            if (activitiesData is Map && activitiesData.containsKey('data')) {
              var paginatedData = activitiesData['data'];
              if (paginatedData is List) {
                for (var item in paginatedData) {
                  if (item is Map<String, dynamic>) {
                    try {
                      activities.add(Activity.fromJson(item));
                    } catch (e) {
                      print('Error parsing activity: $e');
                    }
                  }
                }
              }
            } else if (activitiesData is List) {
              // Direct array data
              for (var item in activitiesData) {
                if (item is Map<String, dynamic>) {
                  try {
                    activities.add(Activity.fromJson(item));
                  } catch (e) {
                    print('Error parsing activity: $e');
                  }
                }
              }
            }
          } else if (data.containsKey('data')) {
            // Standard response structure
            var activitiesData = data['data'];

            if (activitiesData is List) {
              for (var item in activitiesData) {
                if (item is Map<String, dynamic>) {
                  try {
                    activities.add(Activity.fromJson(item));
                  } catch (e) {
                    print('Error parsing activity: $e');
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
                      print('Error parsing activity: $e');
                    }
                  }
                }
              }
            }
          }
        }

        return ApiResponse(
          success: true,
          message: 'Berhasil mendapatkan data aktivitas',
          data: activities,
        );
      } else {
        final errorData = jsonDecode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Gagal mendapatkan data aktivitas',
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

  // UAS
  Future<ApiResponse<Activity>> createActivity({
    required String title,
    required String description,
    required String location,
    required DateTime startTime,
    required DateTime endTime,
    required int attendanceTypeId,
    required List<int> participantIds, // Ubah ke required sesuai backend
  }) async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);

      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      final data = {
        'title': title,
        'description': description,
        'location': location,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'attendance_type_id': attendanceTypeId,
        'participant_ids': participantIds, // Selalu kirim karena required
      };

      print('Sending data to backend: $data'); // Debug print

      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.createActivities}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      print('Response status: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        Activity activity = Activity.fromJson(responseData['data']);
        return ApiResponse(
          success: true,
          message: responseData['message'] ?? 'Aktivitas berhasil dibuat',
          data: activity,
        );
      } else {
        return ApiResponse(
          success: false,
          message: responseData['message'] ?? 'Gagal membuat aktivitas',
        );
      }
    } catch (e) {
      print('Exception in createActivity: $e'); // Debug print
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  // Method baru untuk mendapatkan daftar users
  Future<ApiResponse<List<Map<String, dynamic>>>> getUsers({
    String? search,
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
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.getUsers}',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Map<String, dynamic>> users = [];

        if (data != null && data is Map) {
          if (data.containsKey('success') && data['success'] == true) {
            var usersData = data['data'];

            if (usersData is List) {
              for (var item in usersData) {
                if (item is Map<String, dynamic>) {
                  users.add(item);
                }
              }
            } else if (usersData is Map && usersData.containsKey('data')) {
              // Handle pagination
              var paginatedData = usersData['data'];
              if (paginatedData is List) {
                for (var item in paginatedData) {
                  if (item is Map<String, dynamic>) {
                    users.add(item);
                  }
                }
              }
            }
          } else if (data.containsKey('data')) {
            var usersData = data['data'];
            if (usersData is List) {
              for (var item in usersData) {
                if (item is Map<String, dynamic>) {
                  users.add(item);
                }
              }
            }
          }
        }

        return ApiResponse(
          success: true,
          message: 'Berhasil mendapatkan daftar users',
          data: users,
        );
      } else {
        final errorData = jsonDecode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Gagal mendapatkan daftar users',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getAttendanceTypes() async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);

      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.attendanceTypes}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Map<String, dynamic>> attendanceTypes = [];

        if (data != null && data is Map) {
          if (data.containsKey('success') && data['success'] == true) {
            var typesData = data['data'];

            if (typesData is List) {
              for (var item in typesData) {
                if (item is Map<String, dynamic>) {
                  attendanceTypes.add(item);
                }
              }
            }
          } else if (data.containsKey('data')) {
            var typesData = data['data'];
            if (typesData is List) {
              for (var item in typesData) {
                if (item is Map<String, dynamic>) {
                  attendanceTypes.add(item);
                }
              }
            }
          }
        }

        return ApiResponse(
          success: true,
          message: 'Berhasil mendapatkan tipe kehadiran',
          data: attendanceTypes,
        );
      } else {
        final errorData = jsonDecode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Gagal mendapatkan tipe kehadiran',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }
}
