import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/user/data/models/user_profile_model.dart';

abstract interface class UserRemoteDataSource {
  Future<UserProfileModel> getById(String id);
  Future<UserProfileModel> getByUsername(String username);
  Future<UserProfileModel> updateProfile({required String bio, String? profilePictureUrl});
  Future<String> uploadProfilePicture({required String fileName, required List<int> bytes});
}

class ApiUserRemoteDataSource implements UserRemoteDataSource {
  const ApiUserRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<UserProfileModel> getById(String id) async {
    final response = await _apiClient.getJson('/api/Users/$id');
    return UserProfileModel.fromJson(response);
  }

  @override
  Future<UserProfileModel> getByUsername(String username) async {
    final response = await _apiClient.getJson(
      '/api/Users/by-username/${Uri.encodeComponent(username)}',
    );
    return UserProfileModel.fromJson(response);
  }

  @override
  Future<UserProfileModel> updateProfile({
    required String bio,
    String? profilePictureUrl,
  }) async {
    final response = await _apiClient.putJson(
      '/api/Users/profile',
      body: <String, dynamic>{
        'bio': bio,
        'profilePictureUrl': profilePictureUrl,
      },
    );
    return UserProfileModel.fromJson(response);
  }

  @override
  Future<String> uploadProfilePicture({
    required String fileName,
    required List<int> bytes,
  }) async {
    final response = await _apiClient.postMultipartBytes(
      '/api/Users/upload-profile-picture',
      fieldName: 'file',
      fileName: fileName,
      bytes: bytes,
    );
    final value = response['profilePictureUrl'] ?? response['ProfilePictureUrl'];
    if (value is! String || value.isEmpty) {
      throw const ApiException(message: 'لم يُرجع الخادم رابط الصورة.');
    }
    return value;
  }
}
