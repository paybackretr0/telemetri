class EnvConfig {
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: 'YOUR_GOOGLE_CLIENT_ID',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'URL_ADDRESS.example.com',
  );

  static const String storageUrl = String.fromEnvironment(
    'STORAGE_URL',
    defaultValue: 'URL_ADDRESS_STORAGE.example.com',
  );
}
