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
        final List<dynamic> permissionsJson = data['data']['data'];
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

  Future<ApiResponse<Permission>> getPermission(int id) async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);

      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.permissions}/$id');

      final response = await _client.get(
        uri,
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
        print(data['message']);
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Gagal mendapatkan detail izin',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

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

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.permissions}'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['activity_id'] = activityId.toString();
      request.fields['reason'] = reason;

      if (attachment != null) {
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
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Gagal membuat pengajuan izin',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

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

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.permissions}/$id'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['_method'] = 'PUT';

      if (activityId != null) {
        request.fields['activity_id'] = activityId.toString();
      }

      if (reason != null) {
        request.fields['reason'] = reason;
      }

      if (attachment != null) {
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
