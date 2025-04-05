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
      serverClientId: EnvConfig.googleClientId,
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

      // Force sign out to clear any existing sessions
      await _googleSignIn.signOut();

      // Add a delay to ensure the previous sign-out is completed
      await Future.delayed(const Duration(milliseconds: 300));

      // Sign in with catch for PlatformException
      GoogleSignInAccount? googleUser;
      try {
        // Disable debug prints to reduce noise
        debugPrint = (String? message, {int? wrapWidth}) {};

        googleUser = await _googleSignIn.signIn();

        // Restore debug prints
        debugPrint = debugPrintThrottled;
      } catch (e) {
        print('Google Sign-In error caught: $e');
        // If we get the deadlock error, try the silent approach
        if (e.toString().contains('deadlock')) {
          try {
            googleUser = await _googleSignIn.signInSilently();
          } catch (silentError) {
            _setError('Failed to sign in with Google: $silentError');
            _setLoading(false);
            return false;
          }
        }
      }

      if (googleUser == null) {
        _setLoading(false);
        _setError('Sign in was cancelled or failed');
        return false;
      }

      // Get authentication tokens
      GoogleSignInAuthentication? googleAuth;
      try {
        googleAuth = await googleUser.authentication;
      } catch (e) {
        print('Authentication error: $e');
        _setError('Failed to authenticate with Google: $e');
        _setLoading(false);
        return false;
      }

      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null || accessToken == null) {
        _setError('Failed to obtain authentication tokens');
        _setLoading(false);
        return false;
      }

      // Sign in with backend
      final response = await _authRepository.signInWithGoogle(
        idToken,
        accessToken,
      );

      if (response.success && response.data != null) {
        _user = response.data;
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Sign in failed: $e');
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
