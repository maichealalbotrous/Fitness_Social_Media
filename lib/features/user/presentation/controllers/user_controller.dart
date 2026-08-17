import 'package:flutter/foundation.dart';
import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/user/domain/entities/user_profile.dart';
import 'package:fitness_social_app/features/user/domain/usecases/user_usecases.dart';

class UserController extends ChangeNotifier {
  UserController({
    required GetUserById getById,
    required GetUserByUsername getByUsername,
    required UpdateUserProfile updateProfile,
    required UploadUserProfilePicture uploadProfilePicture,
  })  : _getById = getById,
        _getByUsername = getByUsername,
        _updateProfile = updateProfile,
        _uploadProfilePicture = uploadProfilePicture;

  final GetUserById _getById;
  final GetUserByUsername _getByUsername;
  final UpdateUserProfile _updateProfile;
  final UploadUserProfilePicture _uploadProfilePicture;
  final Map<String, UserProfile> _cache = <String, UserProfile>{};

  UserProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? get profile => _profile;
  UserProfile? profileFor(String id) => _cache[id.trim()];
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<UserProfile?> loadById(String id, {bool forceRefresh = false}) async {
    final key = id.trim();
    if (key.isEmpty) return null;
    if (!forceRefresh && _cache[key] != null) {
      _profile = _cache[key];
      notifyListeners();
      return _profile;
    }
    return _load(() => _getById(key), cacheKey: key);
  }

  Future<UserProfile?> loadByUsername(String username) async {
    final value = username.trim();
    if (value.isEmpty) return null;
    return _load(() => _getByUsername(value));
  }

  Future<UserProfile?> updateProfile({String? bio, String? profilePictureUrl}) async {
    return _load(() => _updateProfile(
          bio: bio,
          profilePictureUrl: profilePictureUrl,
        ), cacheKey: _profile?.id);
  }

  Future<String?> uploadProfilePicture({required String fileName, required List<int> bytes}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final url = await _uploadProfilePicture(fileName: fileName, bytes: bytes);
      _errorMessage = null;
      return url;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'تعذر رفع صورة الملف الشخصي.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<UserProfile?> _load(
    Future<UserProfile> Function() request, {
    String? cacheKey,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await request();
      _profile = result;
      _cache[cacheKey ?? result.id] = result;
      return result;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'تعذر تحميل بيانات المستخدم.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }
}
