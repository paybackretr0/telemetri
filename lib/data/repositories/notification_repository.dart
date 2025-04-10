import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import '../remote/api_config.dart';
import '../local/secure_storage.dart';

class NotificationRepository {
  final http.Client _client = http.Client();
  final SecureStorage _storage = SecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(ApiConfig.accessTokenKey);

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<NotificationResponse> getNotifications({
    int page = 1,
    int perPage = 15,
    bool? isRead,
  }) async {
    try {
      final headers = await _getHeaders();

      String url =
          '${ApiConfig.baseUrl}${ApiConfig.notifications}?page=$page&per_page=$perPage';

      if (isRead != null) {
        url += '&is_read=${isRead.toString()}';
      }

      final response = await _client.get(Uri.parse(url), headers: headers);

      if (response.statusCode == ApiConfig.statusOk) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return NotificationResponse.fromJson(responseData);
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting notifications: $e');
    }
  }

  Future<UnreadCountResponse> getUnreadCount() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.notificationsUnreadCount}'),
        headers: headers,
      );

      if (response.statusCode == ApiConfig.statusOk) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return UnreadCountResponse.fromJson(responseData);
      } else {
        throw Exception('Failed to load unread count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting unread count: $e');
    }
  }

  Future<bool> markAsRead(int notificationId) async {
    try {
      final headers = await _getHeaders();

      final url =
          '${ApiConfig.baseUrl}${ApiConfig.markNotificationAsRead.replaceFirst('{id}', notificationId.toString())}';

      final response = await http.patch(Uri.parse(url), headers: headers);

      if (response.statusCode == ApiConfig.statusOk) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] ?? false;
      } else {
        throw Exception(
          'Failed to mark notification as read: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final headers = await _getHeaders();

      final response = await http.patch(
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.markAllNotificationsAsRead}',
        ),
        headers: headers,
      );

      if (response.statusCode == ApiConfig.statusOk) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] ?? false;
      } else {
        throw Exception(
          'Failed to mark all notifications as read: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error marking all notifications as read: $e');
    }
  }

  Future<bool> deleteNotification(int notificationId) async {
    try {
      final headers = await _getHeaders();

      final url =
          '${ApiConfig.baseUrl}${ApiConfig.deleteNotification.replaceFirst('{id}', notificationId.toString())}';

      final response = await http.delete(Uri.parse(url), headers: headers);

      if (response.statusCode == ApiConfig.statusOk) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] ?? false;
      } else {
        throw Exception(
          'Failed to delete notification: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }

  Future<bool> deleteAllNotifications() async {
    try {
      final headers = await _getHeaders();

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.deleteAllNotifications}'),
        headers: headers,
      );

      if (response.statusCode == ApiConfig.statusOk) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] ?? false;
      } else {
        throw Exception(
          'Failed to delete all notifications: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error deleting all notifications: $e');
    }
  }
}
