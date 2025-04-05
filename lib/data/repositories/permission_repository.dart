import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/permission_model.dart';
import '../remote/api_config.dart';
import '../remote/api_response.dart';
import '../local/secure_storage.dart';

class PermissionRepository {
  final http.Client _client = http.Client();
  final SecureStorage _storage = SecureStorage();

  // Mendapatkan daftar izin pengguna saat ini
  Future<ApiResponse<List<Permission>>> getMyPermissions({
    String? status,
  }) async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);

      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      // Membangun query parameter jika ada status yang difilter
      var uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.myPermissions}');
      if (status != null && status.isNotEmpty) {
        uri = uri.replace(queryParameters: {'status': status});
      }

      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> permissionsJson =
            data['data']['data']; // Nested 'data' karena paginasi
        final List<Permission> permissions =
            permissionsJson.map((json) => Permission.fromJson(json)).toList();

        return ApiResponse(
          success: true,
          message: 'Berhasil mendapatkan data izin',
          data: permissions,
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Gagal mendapatkan data izin',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  // Mendapatkan detail izin berdasarkan ID
  Future<ApiResponse<Permission>> getPermission(int id) async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);

      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.permissions}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final permission = Permission.fromJson(data['data']);
        return ApiResponse(
          success: true,
          message: 'Berhasil mendapatkan detail izin',
          data: permission,
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Gagal mendapatkan detail izin',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  // Membuat pengajuan izin baru
  // Membuat pengajuan izin baru
  Future<ApiResponse<Permission>> createPermission({
    required int activityId,
    required String reason,
    File? attachment,
  }) async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);

      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      // Menggunakan multipart request untuk upload file
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.permissions}'),
      );

      // Menambahkan header
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Menambahkan data form
      request.fields['activity_id'] = activityId.toString();
      request.fields['reason'] = reason;

      // Debug information
      print(
        'Sending permission request with activity_id: ${activityId.toString()} (${activityId.runtimeType})',
      );

      // Menambahkan attachment jika ada
      if (attachment != null) {
        // Mendapatkan content type berdasarkan ekstensi file
        final String extension = attachment.path.split('.').last.toLowerCase();
        String contentType = 'application/octet-stream';

        if (extension == 'pdf') {
          contentType = 'application/pdf';
        } else if (['jpg', 'jpeg'].contains(extension)) {
          contentType = 'image/jpeg';
        } else if (extension == 'png') {
          contentType = 'image/png';
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'attachment',
            attachment.path,
            contentType: MediaType.parse(contentType),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final permission = Permission.fromJson(data['data']);
        return ApiResponse(
          success: true,
          message: data['message'] ?? 'Pengajuan izin berhasil dibuat',
          data: permission,
        );
      } else {
        print('Error: ${response.body}');
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Gagal membuat pengajuan izin',
        );
      }
    } catch (e) {
      print('Error: $e'); // Tambahkan print untuk melihat pesan error
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  // Memperbarui pengajuan izin
  Future<ApiResponse<Permission>> updatePermission({
    required int id,
    int? activityId,
    String? reason,
    File? attachment,
  }) async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);

      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      // Menggunakan multipart request untuk update file
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.permissions}/$id'),
      );

      // Menambahkan header
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Menambahkan method override untuk PUT
      request.fields['_method'] = 'PUT';

      // Menambahkan data form jika ada
      if (activityId != null) {
        request.fields['activity_id'] = activityId.toString();
      }

      if (reason != null) {
        request.fields['reason'] = reason;
      }

      // Menambahkan attachment jika ada
      if (attachment != null) {
        // Mendapatkan content type berdasarkan ekstensi file
        final String extension = attachment.path.split('.').last.toLowerCase();
        String contentType = 'application/octet-stream';

        if (extension == 'pdf') {
          contentType = 'application/pdf';
        } else if (['jpg', 'jpeg'].contains(extension)) {
          contentType = 'image/jpeg';
        } else if (extension == 'png') {
          contentType = 'image/png';
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'attachment',
            attachment.path,
            contentType: MediaType.parse(contentType),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final permission = Permission.fromJson(data['data']);
        return ApiResponse(
          success: true,
          message: data['message'] ?? 'Pengajuan izin berhasil diperbarui',
          data: permission,
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Gagal memperbarui pengajuan izin',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<void>> cancelPermission(int id) async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      final response = await _client.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.permissions}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          success: true,
          message: data['message'] ?? 'Pengajuan izin berhasil dibatalkan',
        );
      } else {
        // Better error handling for different status codes
        final data = jsonDecode(response.body);
        return ApiResponse(
          success: false,
          message:
              data['message'] ??
              'Gagal membatalkan pengajuan izin (${response.statusCode})',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }
}
