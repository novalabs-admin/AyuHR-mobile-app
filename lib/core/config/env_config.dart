import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized environment configuration.
///
/// Access via `EnvConfig.instance` or inject via GetIt: `getIt<EnvConfig>()`.
///
/// All environment variables are read from the `.env` file loaded at startup.
/// To add a new variable:
/// 1. Add it to your `.env.*` files
/// 2. Add a getter below
class EnvConfig {
  EnvConfig._();

  static final EnvConfig instance = EnvConfig._();

  /// Application display name
  String get appName => dotenv.get('APP_NAME', fallback: 'Template');

  /// Base URL for API requests
  String get baseUrl => dotenv.get('BASE_URL');

  /// Base URL for Rating Engine API requests
  String get ratingEngineBaseUrl => dotenv.get('RATING_ENGINE_BASE_URL');

  /// API key for authentication
  String get apiKey => dotenv.get('API_KEY', fallback: '');

  /// Whether debug logging is enabled
  bool get enableLogging =>
      dotenv.get('ENABLE_LOGGING', fallback: 'false').toLowerCase() == 'true';
}
