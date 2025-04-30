import 'package:flutter/material.dart';
import 'package:telemetri/data/models/activity_model.dart';
import 'package:telemetri/data/models/user_model.dart';
import 'package:telemetri/data/repositories/activity_repository.dart';
import 'package:telemetri/data/repositories/profile_repository.dart';

class HomeProvider with ChangeNotifier {
  final ActivityRepository _activityRepository = ActivityRepository();
  final ProfileRepository _profileRepository =
      ProfileRepository(); // Tambahkan ini

  List<Activity> _todayActivities = [];
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  List<Activity> get todayActivities => _todayActivities;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTodayActivities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final result = await _activityRepository.getActivities(
        startDate: startOfDay,
        endDate: endOfDay,
      );

      if (result.success) {
        _todayActivities = result.data ?? [];
      } else {
        _error = result.message;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _profileRepository.getProfile();
      if (result.success) {
        _currentUser = result.data;
      } else {
        _error = result.message;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshHomeData() async {
    await Future.wait([loadTodayActivities(), loadUserProfile()]);
  }
}
