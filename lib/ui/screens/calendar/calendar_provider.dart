import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/calendar_model.dart';
import '../../../data/repositories/calendar_repository.dart';

class CalendarProvider extends ChangeNotifier {
  final CalendarRepository _repository = CalendarRepository();

  bool _isLoading = false;
  String? _error;
  List<CalendarEvent> _events = [];
  List<Map<String, dynamic>> _formattedEvents = [];
  bool _needsReauthentication = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CalendarEvent> get events => _events;
  List<Map<String, dynamic>> get formattedEvents => _formattedEvents;
  bool get needsReauthentication => _needsReauthentication;

  Future<void> getEvents({String? email}) async {
    if (_isLoading) return;

    try {
      _setLoading(true);
      _clearError();
      _needsReauthentication = false;

      final response = await _repository.getEvents(email: email);

      if (response.success) {
        _events = response.data ?? [];
        _formatEvents();
      } else {
        if (response.message.contains('401') ||
            response.message.contains('UNAUTHENTICATED') ||
            response.message.contains('Invalid Credentials') ||
            response.message.contains('authentication credential')) {
          _needsReauthentication = true;
          throw Exception(
            'Autentikasi Google Calendar tidak valid. Silakan login kembali.',
          );
        }
        throw Exception(response.message);
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith("Exception: ")) {
        errorMessage = errorMessage.substring("Exception: ".length);
      }
      _setError('Gagal mendapatkan data kalender: $errorMessage');
    } finally {
      _setLoading(false);
    }
  }

  void _formatEvents() {
    _formattedEvents =
        _events.map((event) {
          DateTime? startDateTime;
          DateTime? endDateTime;

          try {
            if (event.start.dateTime.isNotEmpty) {
              startDateTime = DateTime.parse(event.start.dateTime);
            }

            if (event.end.dateTime.isNotEmpty) {
              endDateTime = DateTime.parse(event.end.dateTime);
            }
          } catch (e) {
            throw Exception('Error parsing date time: $e');
          }

          String date = '';
          String startTime = '';
          String endTime = '';

          if (startDateTime != null) {
            date = DateFormat('dd/MM/yyyy').format(startDateTime);
            startTime = DateFormat('HH.mm').format(startDateTime);
          }

          if (endDateTime != null) {
            endTime = DateFormat('HH.mm').format(endDateTime);
          }

          return {
            'title': event.summary,
            'date': date,
            'startTime': startTime,
            'endTime': endTime,
            'location': event.location,
            'description': event.description,
            'originalEvent': event,
          };
        }).toList();

    notifyListeners();
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
