import 'dart:convert';
import 'package:http/http.dart' as http;
import '../remote/api_config.dart';
import '../remote/api_response.dart';
import '../local/secure_storage.dart';
import '../models/delegation_model.dart';

class DelegationRepository {
  final http.Client _client = http.Client();
  final SecureStorage _storage = SecureStorage();

  Future<ApiResponse<List<Delegation>>> getMyDelegations({
    String? status,
    String? role,
  }) async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);

      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      // Build query parameters
      Map<String, String> queryParams = {};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (role != null && role.isNotEmpty) {
        queryParams['role'] = role;
      }

      var uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.myDelegations}');
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
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
        final List<dynamic> delegationJson =
            data['data']['data']; // Nested 'data' because of pagination
        final List<Delegation> delegations =
            delegationJson.map((json) => Delegation.fromJson(json)).toList();

        return ApiResponse(
          success: true,
          message: 'Berhasil mendapatkan data delegasi',
          data: delegations,
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Gagal mendapatkan data delegasi',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<Delegation>> getDelegationDetail(int id) async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);

      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.delegations}/$id');

      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final Delegation delegation = Delegation.fromJson(data['data']);

        return ApiResponse(
          success: true,
          message: 'Berhasil mendapatkan detail delegasi',
          data: delegation,
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Gagal mendapatkan detail delegasi',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<Delegation>> createDelegation(
    Map<String, dynamic> delegationData,
  ) async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);

      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.delegations}');

      final response = await _client.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(delegationData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final Delegation delegation = Delegation.fromJson(data['data']);

        return ApiResponse(
          success: true,
          message: data['message'] ?? 'Berhasil membuat delegasi',
          data: delegation,
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Gagal membuat delegasi',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<Delegation>> updateDelegation(
    int id,
    Map<String, dynamic> delegationData,
  ) async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);

      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.delegations}/$id');

      final response = await _client.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(delegationData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final Delegation delegation = Delegation.fromJson(data['data']);

        return ApiResponse(
          success: true,
          message: data['message'] ?? 'Berhasil mengupdate delegasi',
          data: delegation,
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Gagal mengupdate delegasi',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<bool>> cancelDelegation(int id) async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);

      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.delegations}/$id');

      final response = await _client.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: data['message'] ?? 'Berhasil membatalkan delegasi',
          data: true,
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Gagal membatalkan delegasi',
          data: false,
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e', data: false);
    }
  }

  Future<ApiResponse<bool>> approveDelegation(int id) async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);

      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.processDelegations.replaceFirst('{id}', id.toString())}',
      );

      final response = await _client.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': 'approved'}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: data['message'] ?? 'Berhasil menyetujui delegasi',
          data: true,
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Gagal menyetujui delegasi',
          data: false,
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e', data: false);
    }
  }

  Future<ApiResponse<bool>> rejectDelegation(int id) async {
    try {
      final token = await _storage.read(ApiConfig.accessTokenKey);

      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.processDelegations.replaceFirst('{id}', id.toString())}',
      );

      final response = await _client.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': 'rejected'}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: data['message'] ?? 'Berhasil menolak delegasi',
          data: true,
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Gagal menolak delegasi',
          data: false,
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e', data: false);
    }
  }
}
