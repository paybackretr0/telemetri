import '../../../data/environment/env_config.dart';

class ApiConfig {
  static const String baseUrl = EnvConfig.apiBaseUrl;
  static const String googleLogin = 'auth/google-flutter';
  static const String logout = 'auth/logout';
  static const String refresh = 'auth/refresh';

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
}
