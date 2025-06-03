import '../../../data/environment/env_config.dart';

class ApiConfig {
  static const String baseUrl = EnvConfig.apiBaseUrl;

  static const String googleLogin = 'auth/google-flutter';
  static const String logout = 'auth/logout';
  static const String refresh = 'refresh-google-token';

  static const String activities = 'activities';

  static const String permissions = 'permissions';
  static const String myPermissions = 'permissions/my';

  static const String delegations = 'delegations';
  static const String myDelegations = 'delegations/my';
  static const String processDelegations = 'delegations/process/{id}';

  static const String myDutySchedules = 'duty-schedules/my';
  static const String getDelegableDutySchedules = 'duty-schedules/delegable';
  static const String getPotentialDelegates =
      'duty-schedules/potential-delegates';

  static const String notifications = 'notifications';
  static const String deleteNotification = 'notifications/{id}';
  static const String deleteAllNotifications = 'notifications';
  static const String notificationsUnreadCount = 'notifications/unread-count';
  static const String markNotificationAsRead = 'notifications/{id}/read';
  static const String markAllNotificationsAsRead =
      'notifications/mark-all-read';

  static const String history = 'history/all';

  static const String profile = 'profile/my';
  static const String updateProfile = 'profile/update';

  static const String calendar = 'calendar';

  static const String absen = 'absensi/{code}';

  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusValidationError = 422;
  static const int statusServerError = 500;

  static const String accessTokenKey = 'access_token';
  static const String tokenTypeKey = 'token_type';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';
  static const String userRoleKey = 'user_role';
  static const String googleTokenKey = 'google_token';
}
