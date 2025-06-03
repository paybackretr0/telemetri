import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/user_model.dart';
import '../remote/api_config.dart';
import '../remote/api_response.dart';
import '../local/secure_storage.dart';

class ProfileRepository {
  final http.Client _client = http.Client();
  final SecureStorage _storage = SecureStorage();

  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final token = await _storage.read(ApiConfig.accessTokenKey);

    final Map<String, String> headers =
        isMultipart
            ? {'Accept': 'application/json'}
            : {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<ApiResponse<User>> getProfile() async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}${ApiConfig.profile}';
      final response = await _client.get(Uri.parse(url), headers: headers);

      if (response.statusCode == ApiConfig.statusOk) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final bool success = responseData['success'] ?? false;
        final String message = responseData['message'] ?? 'No message';

        final Map<String, dynamic>? userData = responseData['data'];
        if (userData != null) {
          userData['id'] = userData['id'] ?? 0;
          userData['name'] = userData['name'] ?? '';
          userData['email'] = userData['email'] ?? '';
          userData['role'] = userData['role'] ?? '';

          userData['profile_picture'] = userData['profile_picture'] ?? '';
          userData['phone_number'] = userData['phone_number'] ?? '';
          userData['google_id'] = userData['google_id'] ?? '';
          userData['nim'] = userData['nim'] ?? '';
          userData['jurusan'] = userData['jurusan'] ?? '';
          userData['nomor_seri'] = userData['nomor_seri'] ?? '';
          userData['jabatan'] = userData['jabatan'] ?? '';
          userData['divisi'] = userData['divisi'] ?? '';
          userData['sub_divisi'] = userData['sub_divisi'] ?? '';
          try {
            final User user = User.fromJson(userData);
            return ApiResponse(success: success, message: message, data: user);
          } catch (e) {
            throw Exception('Error parsing user data: $e');
          }
        } else {
          return ApiResponse(success: success, message: message, data: null);
        }
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting profile: $e');
    }
  }

  Future<ApiResponse<User>> updateProfile({
    String? name,
    String? phoneNumber,
    String? nim,
    String? jurusan,
    String? nomorSeri,
    File? profilePicture,
  }) async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);
      if (token == null) throw Exception('Unauthorized');

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.updateProfile}');
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      if (profilePicture != null) {
        final request = http.MultipartRequest('POST', uri);
        request.headers.addAll(headers);

        if (name != null) request.fields['name'] = name;
        if (phoneNumber != null) request.fields['phone_number'] = phoneNumber;
        if (nim != null) request.fields['nim'] = nim;
        if (jurusan != null) request.fields['jurusan'] = jurusan;
        if (nomorSeri != null) request.fields['nomor_seri'] = nomorSeri;

        final fileExtension = profilePicture.path.split('.').last.toLowerCase();
        final mimeType = fileExtension == 'png' ? 'image/png' : 'image/jpeg';

        final multipartFile = await http.MultipartFile.fromPath(
          'profile_picture',
          profilePicture.path,
          contentType: MediaType.parse(mimeType),
        );

        request.files.add(multipartFile);

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        return _handleProfileResponse(response, profilePicture);
      } else {
        final body = <String, dynamic>{};
        if (name != null) body['name'] = name;
        if (phoneNumber != null) body['phone_number'] = phoneNumber;
        if (nim != null) body['nim'] = nim;
        if (jurusan != null) body['jurusan'] = jurusan;
        if (nomorSeri != null) body['nomor_seri'] = nomorSeri;

        final response = await _client.post(
          uri,
          headers: {...headers, 'Content-Type': 'application/json'},
          body: json.encode(body),
        );

        return _handleProfileResponse(response, null);
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  ApiResponse<User> _handleProfileResponse(
    http.Response response,
    File? fallbackImage,
  ) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    final bool success = responseData['success'] ?? false;
    final String message = responseData['message'] ?? 'No message';

    if (response.statusCode == ApiConfig.statusOk &&
        responseData['data'] != null) {
      final userData = responseData['data'] as Map<String, dynamic>;

      if (userData['profile_picture'] == null && fallbackImage != null) {
        userData['_local_profile_picture'] = fallbackImage.path;
      }

      final user = User.fromJson(userData);
      return ApiResponse(success: success, message: message, data: user);
    } else {
      return ApiResponse(success: success, message: message, data: null);
    }
  }
}
