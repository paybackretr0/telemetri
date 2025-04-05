import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../data/models/permission_model.dart';
import '../../../data/repositories/permission_repository.dart';
import '../../../data/repositories/activity_repository.dart';
import '../../../data/models/activity_model.dart';

enum PermissionStatus { initial, loading, loaded, error }

class PermissionProvider extends ChangeNotifier {
  final PermissionRepository _repository = PermissionRepository();
  final ActivityRepository _activityRepository = ActivityRepository();

  List<Permission> _myPermissions = [];
  List<Permission> get myPermissions => _myPermissions;

  List<Activity> _activities = [];
  List<Activity> get activities => _activities;

  Permission? _currentPermission;
  Permission? get currentPermission => _currentPermission;

  PermissionStatus _myPermissionsStatus = PermissionStatus.initial;
  PermissionStatus get myPermissionsStatus => _myPermissionsStatus;

  PermissionStatus _activitiesStatus = PermissionStatus.initial;
  PermissionStatus get activitiesStatus => _activitiesStatus;

  final PermissionStatus _allPermissionsStatus = PermissionStatus.initial;
  PermissionStatus get allPermissionsStatus => _allPermissionsStatus;

  PermissionStatus _permissionDetailStatus = PermissionStatus.initial;
  PermissionStatus get permissionDetailStatus => _permissionDetailStatus;

  PermissionStatus _createPermissionStatus = PermissionStatus.initial;
  PermissionStatus get createPermissionStatus => _createPermissionStatus;

  PermissionStatus _updatePermissionStatus = PermissionStatus.initial;
  PermissionStatus get updatePermissionStatus => _updatePermissionStatus;

  PermissionStatus _cancelPermissionStatus = PermissionStatus.initial;
  PermissionStatus get cancelPermissionStatus => _cancelPermissionStatus;

  PermissionStatus _processPermissionStatus = PermissionStatus.initial;
  PermissionStatus get processPermissionStatus => _processPermissionStatus;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _successMessage = '';
  String get successMessage => _successMessage;

  Future<void> getActivities({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _activitiesStatus = PermissionStatus.loading;
    notifyListeners();

    try {
      final result = await _activityRepository.getActivities(
        type: type,
        startDate: startDate,
        endDate: endDate,
      );

      if (result.success) {
        _activities = result.data ?? [];
        _activitiesStatus = PermissionStatus.loaded;
      } else {
        _errorMessage = result.message;
        _activitiesStatus = PermissionStatus.error;
      }
    } catch (e) {
      _errorMessage = 'Error fetching activities: $e';
      _activitiesStatus = PermissionStatus.error;
    }

    notifyListeners();
  }

  Future<void> getMyPermissions({String? status}) async {
    _myPermissionsStatus = PermissionStatus.loading;
    notifyListeners();

    final result = await _repository.getMyPermissions(status: status);

    if (result.success) {
      _myPermissions = result.data ?? [];
      _myPermissionsStatus = PermissionStatus.loaded;
    } else {
      _errorMessage = result.message;
      _myPermissionsStatus = PermissionStatus.error;
    }

    notifyListeners();
  }

  Future<void> getPermissionDetail(int id) async {
    if (_permissionDetailStatus != PermissionStatus.loading) {
      _permissionDetailStatus = PermissionStatus.loading;
      notifyListeners();
    }

    try {
      final result = await _repository.getPermission(id);

      if (result.success) {
        _currentPermission = result.data;
        _permissionDetailStatus = PermissionStatus.loaded;
      } else {
        _errorMessage = result.message;
        _permissionDetailStatus = PermissionStatus.error;
      }
    } catch (e) {
      _errorMessage = 'Error fetching permission detail: $e';
      _permissionDetailStatus = PermissionStatus.error;
    }

    if (WidgetsBinding.instance.schedulerPhase !=
        SchedulerPhase.persistentCallbacks) {
      notifyListeners();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<bool> createPermission({
    required int activityId,
    required String reason,
    File? attachment,
  }) async {
    _createPermissionStatus = PermissionStatus.loading;
    notifyListeners();

    final result = await _repository.createPermission(
      activityId: activityId,
      reason: reason,
      attachment: attachment,
    );

    if (result.success) {
      _successMessage = result.message;
      _createPermissionStatus = PermissionStatus.loaded;
      await getMyPermissions();
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.message;
      _createPermissionStatus = PermissionStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePermission({
    required int id,
    int? activityId,
    String? reason,
    File? attachment,
  }) async {
    _updatePermissionStatus = PermissionStatus.loading;
    notifyListeners();

    final result = await _repository.updatePermission(
      id: id,
      activityId: activityId,
      reason: reason,
      attachment: attachment,
    );

    if (result.success) {
      _successMessage = result.message;
      _updatePermissionStatus = PermissionStatus.loaded;

      if (_currentPermission != null && _currentPermission!.id == id) {
        _currentPermission = result.data;
      }

      await getMyPermissions();
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.message;
      _updatePermissionStatus = PermissionStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelPermission(int id) async {
    try {
      _cancelPermissionStatus = PermissionStatus.loading;
      notifyListeners();

      final result = await _repository.cancelPermission(id);

      if (result.success) {
        _successMessage = result.message;
        _cancelPermissionStatus = PermissionStatus.loaded;

        // Update the local state
        if (_currentPermission != null && _currentPermission!.id == id) {
          _currentPermission = null;
        }

        // Refresh permissions list
        await getMyPermissions();
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.message;
        _cancelPermissionStatus = PermissionStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _cancelPermissionStatus = PermissionStatus.error;
      notifyListeners();
      return false;
    }
  }

  void resetStatus() {
    _createPermissionStatus = PermissionStatus.initial;
    _updatePermissionStatus = PermissionStatus.initial;
    _cancelPermissionStatus = PermissionStatus.initial;
    _processPermissionStatus = PermissionStatus.initial;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();
  }

  void resetCurrentPermission() {
    _currentPermission = null;
    _permissionDetailStatus = PermissionStatus.initial;
    notifyListeners();
  }
}
