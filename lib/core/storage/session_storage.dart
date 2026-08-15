import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SessionStorage {
  Future<void> saveAccessToken(String token);

  Future<String?> readAccessToken();

  Future<void> clear();
}

class SecureSessionStorage implements SessionStorage {
  SecureSessionStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';

  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> saveAccessToken(String token) {
    return _secureStorage.write(key: _accessTokenKey, value: token);
  }

  @override
  Future<String?> readAccessToken() {
    return _secureStorage.read(key: _accessTokenKey);
  }

  @override
  Future<void> clear() {
    return _secureStorage.delete(key: _accessTokenKey);
  }
}
