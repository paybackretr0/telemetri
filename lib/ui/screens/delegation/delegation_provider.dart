import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../data/models/delegation_model.dart';
import '../../../data/models/duty_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/delegation_repository.dart';
import '../../../data/repositories/duty_repository.dart';

enum DelegationStatus { initial, loading, loaded, error }

class DelegationProvider extends ChangeNotifier {
  final DelegationRepository _repository = DelegationRepository();
  final DutyRepository _dutyRepository = DutyRepository();

  List<Delegation> _myDelegations = [];
  List<Delegation> get myDelegations => _myDelegations;

  Delegation? _currentDelegation;
  Delegation? get currentDelegation => _currentDelegation;

  List<Duty> _delegableDuties = [];
  List<Duty> get delegableDuties => _delegableDuties;

  List<User> _potentialDelegates = [];
  List<User> get potentialDelegates => _potentialDelegates;

  DelegationStatus _delegableDutiesStatus = DelegationStatus.initial;
  DelegationStatus get delegableDutiesStatus => _delegableDutiesStatus;

  DelegationStatus _potentialDelegatesStatus = DelegationStatus.initial;
  DelegationStatus get potentialDelegatesStatus => _potentialDelegatesStatus;

  DelegationStatus _myDelegationsStatus = DelegationStatus.initial;
  DelegationStatus get myDelegationsStatus => _myDelegationsStatus;

  DelegationStatus _delegationDetailStatus = DelegationStatus.initial;
  DelegationStatus get delegationDetailStatus => _delegationDetailStatus;

  DelegationStatus _createDelegationStatus = DelegationStatus.initial;
  DelegationStatus get createDelegationStatus => _createDelegationStatus;

  DelegationStatus _updateDelegationStatus = DelegationStatus.initial;
  DelegationStatus get updateDelegationStatus => _updateDelegationStatus;

  DelegationStatus _approveDelegationStatus = DelegationStatus.initial;
  DelegationStatus get approveDelegationStatus => _approveDelegationStatus;

  DelegationStatus _rejectDelegationStatus = DelegationStatus.initial;
  DelegationStatus get rejectDelegationStatus => _rejectDelegationStatus;

  DelegationStatus _cancelDelegationStatus = DelegationStatus.initial;
  DelegationStatus get cancelDelegationStatus => _cancelDelegationStatus;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _successMessage = '';
  String get successMessage => _successMessage;

  int? _currentUserId;
  int? get currentUserId => _currentUserId;

  void setCurrentUserId(int userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  Future<void> getMyDelegations({String? status, String? role}) async {
    _myDelegationsStatus = DelegationStatus.loading;
    notifyListeners();

    try {
      final result = await _repository.getMyDelegations(
        status: status,
        role: role,
      );

      if (result.success) {
        _myDelegations = result.data ?? [];
        _myDelegationsStatus = DelegationStatus.loaded;
      } else {
        _errorMessage = result.message;
        _myDelegationsStatus = DelegationStatus.error;
      }
    } catch (e) {
      _errorMessage = 'Error fetching delegations: $e';
      _myDelegationsStatus = DelegationStatus.error;
    }

    notifyListeners();
  }

  Future<void> getDelegationDetail(int id) async {
    if (_delegationDetailStatus != DelegationStatus.loading) {
      _delegationDetailStatus = DelegationStatus.loading;
      notifyListeners();
    }

    try {
      final result = await _repository.getDelegationDetail(id);

      if (result.success) {
        _currentDelegation = result.data;
        _delegationDetailStatus = DelegationStatus.loaded;
      } else {
        _errorMessage = result.message;
        _delegationDetailStatus = DelegationStatus.error;
      }
    } catch (e) {
      _errorMessage = 'Error fetching delegation detail: $e';
      _delegationDetailStatus = DelegationStatus.error;
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

  Future<void> getDelegableDuties() async {
    _delegableDutiesStatus = DelegationStatus.loading;
    notifyListeners();

    try {
      final result = await _dutyRepository.getDelegableDutySchedules();

      if (result.success) {
        _delegableDuties = result.data ?? [];
        _delegableDutiesStatus = DelegationStatus.loaded;
      } else {
        _errorMessage = result.message;
        _delegableDutiesStatus = DelegationStatus.error;
      }
    } catch (e) {
      _errorMessage = 'Error fetching duty schedules: $e';
      _delegableDutiesStatus = DelegationStatus.error;
    }

    notifyListeners();
  }

  Future<void> getPotentialDelegates() async {
    _potentialDelegatesStatus = DelegationStatus.loading;
    notifyListeners();

    try {
      final result = await _dutyRepository.getPotentialDelegates();

      if (result.success) {
        _potentialDelegates = result.data ?? [];
        _potentialDelegatesStatus = DelegationStatus.loaded;
      } else {
        _errorMessage = result.message;
        _potentialDelegatesStatus = DelegationStatus.error;
      }
    } catch (e) {
      _errorMessage = 'Error fetching potential delegates: $e';
      _potentialDelegatesStatus = DelegationStatus.error;
    }

    notifyListeners();
  }

  Future<bool> createDelegation({
    required int delegateId,
    required int dutyScheduleId,
    required DateTime delegationDate,
    required String reason,
  }) async {
    _createDelegationStatus = DelegationStatus.loading;
    notifyListeners();

    try {
      final delegationData = {
        'delegate_id': delegateId,
        'duty_schedule_id': dutyScheduleId,
        'delegation_date': delegationDate.toIso8601String(),
        'reason': reason,
      };

      final result = await _repository.createDelegation(delegationData);

      if (result.success) {
        _successMessage = result.message;
        _createDelegationStatus = DelegationStatus.loaded;
        await getMyDelegations();
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.message;
        _createDelegationStatus = DelegationStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error creating delegation: $e';
      _createDelegationStatus = DelegationStatus.error;
      notifyListeners();
      return false;
    }
  }

  // Update this method to accept a delegationData map
  Future<bool> updateDelegation({
    required int id,
    required Map<String, dynamic> delegationData,
  }) async {
    _updateDelegationStatus = DelegationStatus.loading;
    notifyListeners();

    try {
      final result = await _repository.updateDelegation(id, delegationData);

      if (result.success) {
        _successMessage = result.message;
        _updateDelegationStatus = DelegationStatus.loaded;

        // Update the current delegation if it's the one being edited
        if (_currentDelegation != null && _currentDelegation!.id == id) {
          _currentDelegation = result.data;
        }

        // Refresh delegations list
        await getMyDelegations();
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.message;
        _updateDelegationStatus = DelegationStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating delegation: $e';
      _updateDelegationStatus = DelegationStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> approveDelegation(int id) async {
    try {
      _approveDelegationStatus = DelegationStatus.loading;
      notifyListeners();

      final result = await _repository.approveDelegation(id);

      if (result.success) {
        _successMessage = result.message;
        _approveDelegationStatus = DelegationStatus.loaded;

        if (_currentDelegation != null && _currentDelegation!.id == id) {
          await getDelegationDetail(id);
        }

        await getMyDelegations();
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.message;
        _approveDelegationStatus = DelegationStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _approveDelegationStatus = DelegationStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectDelegation(int id) async {
    try {
      _rejectDelegationStatus = DelegationStatus.loading;
      notifyListeners();

      final result = await _repository.rejectDelegation(id);

      if (result.success) {
        _successMessage = result.message;
        _rejectDelegationStatus = DelegationStatus.loaded;

        // Update the local state
        if (_currentDelegation != null && _currentDelegation!.id == id) {
          await getDelegationDetail(id);
        }

        // Refresh delegations list
        await getMyDelegations();
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.message;
        _rejectDelegationStatus = DelegationStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _rejectDelegationStatus = DelegationStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelDelegation(int id) async {
    _cancelDelegationStatus = DelegationStatus.loading;
    notifyListeners();

    try {
      final result = await _repository.cancelDelegation(id);

      if (result.success) {
        _successMessage = result.message;
        _cancelDelegationStatus = DelegationStatus.loaded;

        // Update the local state
        if (_currentDelegation != null && _currentDelegation!.id == id) {
          await getDelegationDetail(id);
        }

        // Refresh delegations list
        await getMyDelegations();
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.message;
        _cancelDelegationStatus = DelegationStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error cancelling delegation: $e';
      _cancelDelegationStatus = DelegationStatus.error;
      notifyListeners();
      return false;
    }
  }

  void resetStatus() {
    _createDelegationStatus = DelegationStatus.initial;
    _updateDelegationStatus = DelegationStatus.initial;
    _approveDelegationStatus = DelegationStatus.initial;
    _rejectDelegationStatus = DelegationStatus.initial;
    _cancelDelegationStatus = DelegationStatus.initial;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();
  }

  void resetCurrentDelegation() {
    _currentDelegation = null;
    _delegationDetailStatus = DelegationStatus.initial;
    notifyListeners();
  }
}
