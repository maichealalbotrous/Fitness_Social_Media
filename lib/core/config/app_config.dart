class AppConfig {
  const AppConfig._();

  /// Pass at runtime, for example:
  /// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5024
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5024',
  );

  static Uri apiUri(String path) {
    final normalizedBaseUrl = apiBaseUrl.endsWith('/')
        ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
        : apiBaseUrl;

    return Uri.parse('$normalizedBaseUrl$path');
  }
}
