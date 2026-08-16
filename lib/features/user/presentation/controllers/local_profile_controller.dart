import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:fitness_social_app/features/user/data/local_profile_storage.dart';

class LocalProfileController extends ChangeNotifier {
  LocalProfileController({
    required SessionStorage sessionStorage,
    required LocalProfileStorage profileStorage,
    ImagePicker? imagePicker,
  })  : _sessionStorage = sessionStorage,
        _profileStorage = profileStorage,
        _imagePicker = imagePicker ?? ImagePicker();

  final SessionStorage _sessionStorage;
  final LocalProfileStorage _profileStorage;
  final ImagePicker _imagePicker;

  String _displayName = 'Repflow athlete';
  String _email = '';
  String? _userId;
  String? _avatarBase64;
  bool _isLoading = false;

  String get displayName => _displayName;
  String get email => _email;
  String? get userId => _userId;
  String? get avatarBase64 => _avatarBase64;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    final localData = _profileStorage.read();
    _displayName = localData.displayName ?? _displayName;
    _email = localData.email ?? '';
    _avatarBase64 = localData.avatarBase64;

    final token = await _sessionStorage.readAccessToken();
    if (token != null) {
      final claims = _decodeClaims(token);
      _userId = _claim(claims, const [
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
        'nameid',
        'sub',
      ]);
      _displayName = _claim(claims, const [
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name',
            'name',
          ]) ??
          _displayName;
      _email = _claim(claims, const [
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress',
            'email',
          ]) ??
          _email;
      await _profileStorage.saveIdentity(
        displayName: _displayName,
        email: _email,
      );
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> pickAvatar() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    await _profileStorage.saveAvatarBytes(bytes);
    _avatarBase64 = base64Encode(bytes);
    notifyListeners();
  }

  Map<String, dynamic> _decodeClaims(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return <String, dynamic>{};
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded);
      return payload is Map<String, dynamic> ? payload : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String? _claim(Map<String, dynamic> claims, List<String> keys) {
    for (final key in keys) {
      final value = claims[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }
}
