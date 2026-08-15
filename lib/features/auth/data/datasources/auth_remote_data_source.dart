import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/auth/domain/entities/auth_credentials.dart';

abstract interface class AuthRemoteDataSource {
  Future<String> register(RegisterCredentials credentials);

  Future<String> login(LoginCredentials credentials);
}

class ApiAuthRemoteDataSource implements AuthRemoteDataSource {
  ApiAuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<String> register(RegisterCredentials credentials) async {
    final response = await _apiClient.postJson(
      '/api/Auth/register',
      body: <String, dynamic>{
        'username': credentials.username,
        'email': credentials.email,
        'password': credentials.password,
      },
    );

    final message = response['message'];
    return message is String && message.isNotEmpty
        ? message
        : 'تم إنشاء الحساب بنجاح.';
  }

  @override
  Future<String> login(LoginCredentials credentials) async {
    final response = await _apiClient.postJson(
      '/api/Auth/login',
      body: <String, dynamic>{
        'email': credentials.email,
        'password': credentials.password,
      },
    );

    final token = response['token'] ?? response['Token'];
    if (token is! String || token.isEmpty) {
      throw const ApiException(
        message: 'لم يُرجع الخادم رمز وصول صالحاً.',
      );
    }

    return token;
  }
}
