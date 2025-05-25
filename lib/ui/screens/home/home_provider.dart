import 'package:flutter/material.dart';
import 'package:telemetri/data/models/activity_model.dart';
import 'package:telemetri/data/models/history_model.dart';
import 'package:telemetri/data/models/user_model.dart';
import 'package:telemetri/data/repositories/activity_repository.dart';
import 'package:telemetri/data/repositories/profile_repository.dart';
import 'package:telemetri/data/repositories/history_repository.dart';

class HomeProvider with ChangeNotifier {
  final ActivityRepository _activityRepository = ActivityRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  final HistoryRepository _historyRepository = HistoryRepository();

  List<Activity> _todayActivities = [];
  List<History> _recentHistory = [];
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  List<Activity> get todayActivities => _todayActivities;
  User? get currentUser => _currentUser;
  List<History> get recentHistory => _recentHistory;
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

  Future<void> loadRecentHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _historyRepository.getHistory(page: 1);

      if (result.success && result.data != null) {
        _recentHistory = result.data!.data.take(3).toList();
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
    await Future.wait([
      loadTodayActivities(),
      loadUserProfile(),
      loadRecentHistory(),
    ]);
  }
}
