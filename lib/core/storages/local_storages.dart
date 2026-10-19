
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

abstract class LocalStorage {
  Future<String?> getApiKey();
  Future<void> setApiKey(String apiKey);
  Future<String?> getAccessToken();
  Future<void> setAccessToken(String token);
  Future<String?> getRefreshToken();
  Future<void> setRefreshToken(String token);
  Future<void> clearTokens();
  Future<int?> getUserId();
  Future<void> setUserId(int id);
  Future<bool> getRememberMe();
  Future<void> setRememberMe(bool value);
  Future<String?> getSavedUsername();
  Future<void> setSavedUsername(String? username);
}

@LazySingleton(as: LocalStorage)
class LocalStorageImpl implements LocalStorage {
  const LocalStorageImpl(this._storage);
  final FlutterSecureStorage _storage;
  static const _apiKeyKey = 'apiKey';
  static const _accessTokenKey = 'accessToken';
  static const _userIdKey = 'userId';
  static const _rememberMeKey = 'rememberMe';
  static const _savedUsernameKey = 'savedUsername';
  static const _refreshTokenKey = 'refreshToken';

  // ── API Key ──

  @override
  Future<String?> getApiKey() => _storage.read(key: _apiKeyKey);

  @override
  Future<void> setApiKey(String apiKey) async {
    await _storage.write(key: _apiKeyKey, value: apiKey);
  }

  // ── Auth Tokens ──

  @override
  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<void> setAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }
  @override
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  @override
  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }
  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
  }

  // ── User ID ──

  @override
  Future<int?> getUserId() async {
    final value = await _storage.read(key: _userIdKey);
    return value != null ? int.tryParse(value) : null;
  }

  @override
  Future<void> setUserId(int userId) async {
    await _storage.write(key: _userIdKey, value: userId.toString());
  }

  // ── Remember Me ──

  @override
  Future<bool> getRememberMe() async {
    final value = await _storage.read(key: _rememberMeKey);
    return value == 'true';
  }

  @override
  Future<void> setRememberMe(bool value) async {
    await _storage.write(key: _rememberMeKey, value: value.toString());
  }

  @override
  Future<String?> getSavedUsername() => _storage.read(key: _savedUsernameKey);

  @override
  Future<void> setSavedUsername(String? username) async {
    if (username == null) {
      await _storage.delete(key: _savedUsernameKey);
    } else {
      await _storage.write(key: _savedUsernameKey, value: username);
    }
  }
}