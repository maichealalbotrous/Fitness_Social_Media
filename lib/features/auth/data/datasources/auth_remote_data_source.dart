import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/auth/domain/entities/auth_credentials.dart';
import 'package:fitness_social_app/features/auth/domain/entities/password_reset_credentials.dart';

abstract interface class AuthRemoteDataSource {
  Future<String> register(RegisterCredentials credentials);

  Future<String> login(LoginCredentials credentials);

  Future<String> requestPasswordReset(String email);

  Future<String> resetPassword(PasswordResetCredentials credentials);

  Future<String> verifyEmail(String token);
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
  Future<String> requestPasswordReset(String email) async {
    final response = await _apiClient.postJson(
      '/api/Auth/forgot-password',
      body: <String, dynamic>{'email': email},
    );

    return _message(
      response,
      fallback: 'إذا كان الحساب موجوداً، فستصل تعليمات الاستعادة قريباً.',
    );
  }

  @override
  Future<String> resetPassword(PasswordResetCredentials credentials) async {
    final response = await _apiClient.postJson(
      '/api/Auth/reset-password',
      body: <String, dynamic>{
        'token': credentials.token,
        'newPassword': credentials.newPassword,
      },
    );

    return _message(response, fallback: 'تم تغيير كلمة المرور بنجاح.');
  }

  @override
  Future<String> verifyEmail(String token) async {
    final response = await _apiClient.postJson(
      '/api/Auth/verify-email',
      body: <String, dynamic>{'token': token},
    );

    return _message(response, fallback: 'تم التحقق من البريد الإلكتروني بنجاح.');
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

  String _message(Map<String, dynamic> response, {required String fallback}) {
    final message = response['message'];
    return message is String && message.isNotEmpty ? message : fallback;
  }
}
