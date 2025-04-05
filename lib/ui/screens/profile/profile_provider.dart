import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/environment/env_config.dart';

class ProfileProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId: EnvConfig.googleClientId,
  );

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> logout() async {
    if (_isLoading) return false; // Prevent multiple logout attempts

    try {
      _setLoading(true);
      _clearError();

      // First sign out from Google - make sure this completes
      try {
        await _googleSignIn.disconnect();
      } catch (e) {
        print('Google sign out error: $e');
        // Continue with logout even if Google sign out fails
      }

      // Then call the backend to logout
      final response = await _authRepository.logout();

      if (response.success) {
        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _setError('Logout failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
