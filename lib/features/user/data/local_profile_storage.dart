import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalProfileData {
  const LocalProfileData({this.displayName, this.email, this.avatarBase64});

  final String? displayName;
  final String? email;
  final String? avatarBase64;
}

class LocalProfileStorage {
  const LocalProfileStorage(this._preferences);

  static const _displayNameKey = 'local_profile_display_name';
  static const _emailKey = 'local_profile_email';
  static const _avatarBase64Key = 'local_profile_avatar_base64';

  final SharedPreferences _preferences;

  static Future<LocalProfileStorage> create() async {
    return LocalProfileStorage(await SharedPreferences.getInstance());
  }

  LocalProfileData read() {
    return LocalProfileData(
      displayName: _preferences.getString(_displayNameKey),
      email: _preferences.getString(_emailKey),
      avatarBase64: _preferences.getString(_avatarBase64Key),
    );
  }

  Future<void> saveIdentity({String? displayName, String? email}) async {
    if (displayName != null && displayName.trim().isNotEmpty) {
      await _preferences.setString(_displayNameKey, displayName.trim());
    }
    if (email != null && email.trim().isNotEmpty) {
      await _preferences.setString(_emailKey, email.trim());
    }
  }

  Future<void> saveAvatarBytes(List<int> bytes) {
    return _preferences.setString(_avatarBase64Key, base64Encode(bytes));
  }
}
