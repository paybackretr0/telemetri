import 'package:flutter/material.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/repositories/activity_repository.dart';

enum EventStatus { initial, loading, success, error }

class ActivityProvider with ChangeNotifier {
  final ActivityRepository _repository = ActivityRepository();

  EventStatus _myEventsStatus = EventStatus.initial;
  EventStatus _createEventStatus = EventStatus.initial;
  EventStatus _attendanceTypesStatus = EventStatus.initial;
  EventStatus _usersStatus = EventStatus.initial;

  List<Activity> _myEvents = [];
  List<Map<String, dynamic>> _attendanceTypes = [];
  List<Map<String, dynamic>> _users = [];
  String _errorMessage = '';
  String _successMessage = '';

  EventStatus get myEventsStatus => _myEventsStatus;
  EventStatus get createEventStatus => _createEventStatus;
  EventStatus get attendanceTypesStatus => _attendanceTypesStatus;
  EventStatus get usersStatus => _usersStatus;
  List<Activity> get myEvents => _myEvents;
  List<Map<String, dynamic>> get attendanceTypes => _attendanceTypes;
  List<Map<String, dynamic>> get users => _users;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;

  void _setMyEventsStatus(EventStatus status) {
    _myEventsStatus = status;
    notifyListeners();
  }

  void _setUsersStatus(EventStatus status) {
    _usersStatus = status;
    notifyListeners();
  }

  void _setCreateEventStatus(EventStatus status) {
    _createEventStatus = status;
    notifyListeners();
  }

  void _setAttendanceTypesStatus(EventStatus status) {
    _attendanceTypesStatus = status;
    notifyListeners();
  }

  Future<void> getMyEvents({String? status}) async {
    try {
      _setMyEventsStatus(EventStatus.loading);

      final response = await _repository.getActivities(myActivitiesOnly: true);

      if (response.success && response.data != null) {
        _myEvents = response.data!;
        _setMyEventsStatus(EventStatus.success);
      } else {
        _errorMessage = response.message;
        _setMyEventsStatus(EventStatus.error);
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _setMyEventsStatus(EventStatus.error);
    }
  }

  Future<void> getUsers({String? search}) async {
    try {
      _setUsersStatus(EventStatus.loading);

      final response = await _repository.getUsers(search: search);

      if (response.success && response.data != null) {
        _users = response.data!;
        _setUsersStatus(EventStatus.success);
      } else {
        _errorMessage = response.message;
        _setUsersStatus(EventStatus.error);
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _setUsersStatus(EventStatus.error);
    }
  }

  Future<void> getAttendanceTypes() async {
    try {
      _setAttendanceTypesStatus(EventStatus.loading);

      final response = await _repository.getAttendanceTypes();
      if (response.success && response.data != null) {
        _attendanceTypes = response.data!;
        _setAttendanceTypesStatus(EventStatus.success);
      } else {
        _errorMessage = response.message;
        _setAttendanceTypesStatus(EventStatus.error);
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _setAttendanceTypesStatus(EventStatus.error);
    }
  }

  Future<bool> createEvent({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required String location,
    required int attendanceTypeId,
    required List<int> participantIds, // Ubah ke required
  }) async {
    try {
      _setCreateEventStatus(EventStatus.loading);

      final response = await _repository.createActivity(
        title: title,
        description: description,
        location: location,
        startTime: startTime,
        endTime: endTime,
        attendanceTypeId: attendanceTypeId,
        participantIds: participantIds,
      );

      if (response.success) {
        _successMessage = response.message;
        _setCreateEventStatus(EventStatus.success);
        return true;
      } else {
        _errorMessage = response.message;
        _setCreateEventStatus(EventStatus.error);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _setCreateEventStatus(EventStatus.error);
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();
  }
}
