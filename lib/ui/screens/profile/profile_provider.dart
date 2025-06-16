import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:telemetri/utils/platform_helper.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/environment/env_config.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/models/user_model.dart';

class ProfileProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  GoogleSignIn? _googleSignIn;

  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;
  User? _user;
  File? _selectedImage;

  ProfileProvider() {
    _initGoogleSignIn();
  }

  void _initGoogleSignIn() {
    try {
      if (PlatformHelper.isWeb) {
        _googleSignIn = GoogleSignIn(
          clientId: EnvConfig.googleWebClientId,
          scopes: ['email'],
        );
      } else {
        _googleSignIn = GoogleSignIn(
          scopes: ['email'],
          serverClientId: EnvConfig.googleClientId,
        );
      }

      if (kDebugMode) {
        debugPrint(
          'ProfileProvider GoogleSignIn initialized for ${PlatformHelper.isWeb ? "Web" : "Mobile"}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing GoogleSignIn in ProfileProvider: $e');
      }
    }
  }

  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get error => _error;
  User? get user => _user;
  File? get selectedImage => _selectedImage;

  Future<void> getProfile() async {
    if (_isLoading) return;

    try {
      _setLoading(true);
      _clearError();

      final response = await _profileRepository.getProfile();

      if (response.success && response.data != null) {
        _user = response.data;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _setError('Failed to get profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> pickImage() async {
    if (!PlatformHelper.isMobile) {
      _setError('Image picking is only available on mobile devices');
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        _selectedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to pick image: $e');
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? nim,
    String? jurusan,
    String? nomorSeri,
  }) async {
    if (_isUpdating) return false;

    try {
      _setUpdating(true);
      _clearError();

      final File? uploadedImage =
          PlatformHelper.isMobile ? _selectedImage : null;

      final response = await _profileRepository.updateProfile(
        name: name,
        phoneNumber: phoneNumber,
        nim: nim,
        jurusan: jurusan,
        nomorSeri: nomorSeri,
        profilePicture: uploadedImage,
      );

      if (response.success && response.data != null) {
        _user = response.data;

        if (_user?.profilePicture == null && uploadedImage != null) {
          _user = _user!.copyWith(profilePicture: uploadedImage.path);
        }

        _selectedImage = null;

        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  Future<bool> logout() async {
    if (_isLoading) return false;

    try {
      _setLoading(true);
      _clearError();

      if (_googleSignIn != null) {
        try {
          await _googleSignIn!.disconnect();
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Google sign out failed: $e');
          }
        }
      }

      final response = await _authRepository.logout();

      if (response.success) {
        _user = null;
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

  void _setUpdating(bool updating) {
    _isUpdating = updating;
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

String getProfilePictureUrl(String? profilePicture) {
  if (profilePicture == null || profilePicture.isEmpty) {
    return '';
  }

  if (profilePicture.startsWith('/') || profilePicture.contains('\\')) {
    return profilePicture;
  }

  if (profilePicture.startsWith('http://') ||
      profilePicture.startsWith('https://')) {
    return profilePicture;
  }

  return '${EnvConfig.storageUrl}$profilePicture';
}
