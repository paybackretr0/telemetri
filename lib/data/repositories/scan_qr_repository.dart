import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/attendance_model.dart';
import '../remote/api_config.dart';
import '../remote/api_response.dart';
import '../local/secure_storage.dart';

class ScanQrRepository {
  final http.Client _client = http.Client();
  final SecureStorage _storage = SecureStorage();

  Future<ApiResponse<Attendance>> scanQrCode(String code) async {
    try {
      // Get current location
      Position position = await _getCurrentPosition();

      // Get token
      final token = await _storage.read(ApiConfig.accessTokenKey);
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }

      // Replace placeholder in URL
      final url =
          '${ApiConfig.baseUrl}${ApiConfig.absen.replaceAll('{code}', code)}';

      // Prepare request body
      final body = {
        'location': 'Mobile App',
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
      };

      // Make API call
      final response = await _client.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == ApiConfig.statusOk ||
          response.statusCode == ApiConfig.statusCreated) {
        final attendanceResponse = AttendanceResponse.fromJson(data);

        return ApiResponse(
          success: attendanceResponse.success,
          message: attendanceResponse.message,
          data: attendanceResponse.data,
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

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request user to enable
      throw Exception(
        'Layanan lokasi tidak aktif. Mohon aktifkan layanan lokasi.',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Izin lokasi ditolak secara permanen, silakan ubah di pengaturan perangkat',
      );
    }

    // When we reach here, permissions are granted and we can get the location
    return await Geolocator.getCurrentPosition();
  }
}
