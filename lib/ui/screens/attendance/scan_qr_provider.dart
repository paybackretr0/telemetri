import 'package:flutter/material.dart';
import '../../../data/repositories/scan_qr_repository.dart';
import '../../../data/models/attendance_model.dart';

enum ScanQrStatus { initial, loading, success, error }

class ScanQrProvider extends ChangeNotifier {
  final ScanQrRepository _repository = ScanQrRepository();

  ScanQrStatus _status = ScanQrStatus.initial;
  String _message = '';
  Attendance? _attendance;
  String? _errorMessage;

  ScanQrStatus get status => _status;
  String get message => _message;
  Attendance? get attendance => _attendance;
  String? get errorMessage => _errorMessage;

  Future<void> scanQrCode(String code) async {
    try {
      _setLoading();

      final response = await _repository.scanQrCode(code);

      if (response.success && response.data != null) {
        _setSuccess(response.message, response.data!);
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
    }
  }

  void _setLoading() {
    _status = ScanQrStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess(String message, Attendance attendance) {
    _status = ScanQrStatus.success;
    _message = message;
    _attendance = attendance;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = ScanQrStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void reset() {
    _status = ScanQrStatus.initial;
    _message = '';
    _attendance = null;
    _errorMessage = null;
    notifyListeners();
  }
}
