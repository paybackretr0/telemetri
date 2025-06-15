import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../data/environment/env_config.dart';

class LoginProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  late final GoogleSignIn _googleSignIn;

  User? _user;
  bool _isLoading = false;
  String? _error;

  LoginProvider() {
    _initGoogleSignIn();
  }

  void _initGoogleSignIn() {
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'profile',
        'https://www.googleapis.com/auth/calendar',
        'https://www.googleapis.com/auth/calendar.events',
      ],
      serverClientId: Platform.isAndroid ? EnvConfig.googleWebClientId : null,
    );
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  Future<void> initAuth() async {
    try {
      _setLoading(true);
      _user = await _authRepository.getCurrentUser();
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _clearError();
      _setLoading(true);

      print(
        'Starting Google Sign-In process for ${Platform.operatingSystem}...',
      );

      // Clear any existing session
      try {
        await _googleSignIn.signOut();
        print('Previous session cleared');
      } catch (e) {
        print('Sign out error (ignorable): $e');
      }

      // Wait for sign out to complete
      await Future.delayed(const Duration(milliseconds: 1000));

      // Check if Google Play Services is available (Android only)
      if (Platform.isAndroid) {
        try {
          await _googleSignIn.isSignedIn();
        } catch (e) {
          print('Google Play Services error: $e');
          _setError(
            'Google Play Services not available. Please update Google Play Services.',
          );
          return false;
        }
      }

      // Start sign in
      print('Initiating Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Google Sign-In cancelled by user');
        _setError('Sign in was cancelled');
        return false;
      }

      print('Google user obtained: ${googleUser.email}');

      // Get authentication
      print('Getting authentication tokens...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null || accessToken == null) {
        print(
          'Failed to get tokens: idToken=${idToken != null}, accessToken=${accessToken != null}',
        );
        _setError('Failed to obtain authentication tokens');
        return false;
      }

      print('Tokens obtained successfully');

      // Sign in with backend
      print('Signing in with backend...');
      final response = await _authRepository.signInWithGoogle(
        idToken,
        accessToken,
      );

      if (response.success && response.data != null) {
        print('Backend authentication successful');
        _user = response.data;
        notifyListeners();
        return true;
      } else {
        print('Backend authentication failed: ${response.message}');
        _setError(response.message);
        return false;
      }
    } catch (e) {
      print('Google Sign-In error: $e');

      // Handle specific error codes
      if (e.toString().contains('ApiException: 10')) {
        _setError(
          'Google Sign-In configuration error. Please check app settings.',
        );
      } else if (e.toString().contains('network_error')) {
        _setError('Network error. Please check your internet connection.');
      } else {
        _setError('Sign in failed: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      _setLoading(true);
      await _authRepository.logout();
      await _googleSignIn.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: $e');
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
