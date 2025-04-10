import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart' as model;
import '../../../data/repositories/notification_repository.dart';

enum NotificationStatus { initial, loading, loaded, error }

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  NotificationStatus _status = NotificationStatus.initial;
  List<model.Notification> _notifications = [];
  int _unreadCount = 0;
  String _errorMessage = '';
  int _currentPage = 1;
  int _lastPage = 1;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  String? _filterByReadStatus;

  NotificationStatus get status => _status;
  List<model.Notification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  String get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
    }

    if (_currentPage == 1) {
      _status = NotificationStatus.loading;
      notifyListeners();
    } else {
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      bool? isRead;
      if (_filterByReadStatus == 'Read') {
        isRead = true;
      } else if (_filterByReadStatus == 'Unread') {
        isRead = false;
      }

      final response = await _repository.getNotifications(
        page: _currentPage,
        isRead: isRead,
      );

      if (_currentPage == 1) {
        _notifications = response.data;
      } else {
        _notifications.addAll(response.data);
      }

      _lastPage = response.lastPage;
      _hasMoreData = _currentPage < _lastPage;
      _status = NotificationStatus.loaded;
    } catch (e) {
      _status = NotificationStatus.error;
      _errorMessage = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_hasMoreData && !_isLoadingMore) {
      _currentPage++;
      await loadNotifications();
    }
  }

  void filterByReadStatus(String filter) {
    if (filter == 'Semua') {
      _filterByReadStatus = null;
    } else {
      _filterByReadStatus = filter;
    }
    _currentPage = 1;
    loadNotifications(refresh: true);
  }

  Future<void> getUnreadCount() async {
    try {
      final response = await _repository.getUnreadCount();
      _unreadCount = response.count;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> markAsRead(int notificationId) async {
    try {
      final success = await _repository.markAsRead(notificationId);

      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final updatedNotification = model.Notification(
            id: _notifications[index].id,
            userId: _notifications[index].userId,
            title: _notifications[index].title,
            message: _notifications[index].message,
            type: _notifications[index].type,
            referenceId: _notifications[index].referenceId,
            isRead: true,
            createdAt: _notifications[index].createdAt,
            updatedAt: DateTime.now(),
          );

          _notifications[index] = updatedNotification;

          if (_unreadCount > 0) {
            _unreadCount--;
          }

          notifyListeners();
        }
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final success = await _repository.markAllAsRead();

      if (success) {
        _notifications =
            _notifications.map((notification) {
              return model.Notification(
                id: notification.id,
                userId: notification.userId,
                title: notification.title,
                message: notification.message,
                type: notification.type,
                referenceId: notification.referenceId,
                isRead: true,
                createdAt: notification.createdAt,
                updatedAt: DateTime.now(),
              );
            }).toList();

        _unreadCount = 0;

        notifyListeners();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteNotification(int notificationId) async {
    try {
      final success = await _repository.deleteNotification(notificationId);

      if (success) {
        _notifications.removeWhere((n) => n.id == notificationId);

        final wasUnread = _notifications.any(
          (n) => n.id == notificationId && !n.isRead,
        );
        if (wasUnread && _unreadCount > 0) {
          _unreadCount--;
        }

        notifyListeners();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAllNotifications() async {
    try {
      final success = await _repository.deleteAllNotifications();

      if (success) {
        _notifications = [];

        _unreadCount = 0;

        notifyListeners();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
