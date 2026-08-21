import 'package:flutter/foundation.dart';
import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/auth/domain/entities/auth_credentials.dart';
import 'package:fitness_social_app/features/auth/domain/usecases/login_user.dart';
import 'package:fitness_social_app/features/auth/domain/usecases/register_user.dart';

enum AuthMode { login, register }

enum AuthSubmissionOutcome { authenticated, registered, failed }

class AuthController extends ChangeNotifier {
  AuthController({
    required LoginUser loginUser,
    required RegisterUser registerUser,
  })  : _loginUser = loginUser,
        _registerUser = registerUser;

  final LoginUser _loginUser;
  final RegisterUser _registerUser;

  AuthMode _mode = AuthMode.login;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  AuthMode get mode => _mode;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void switchMode() {
    _mode = _mode == AuthMode.login ? AuthMode.register : AuthMode.login;
    _clearMessages();
    notifyListeners();
  }

  Future<AuthSubmissionOutcome> submit({
    required String email,
    required String password,
    String? username,
  }) async {
    _isSubmitting = true;
    _clearMessages();
    notifyListeners();

    try {
      if (_mode == AuthMode.login) {
        await _loginUser(LoginCredentials(email: email, password: password));
        return AuthSubmissionOutcome.authenticated;
      }

      final message = await _registerUser(
        RegisterCredentials(
          username: username!,
          email: email,
          password: password,
        ),
      );
      _mode = AuthMode.login;
      _successMessage = message;
      return AuthSubmissionOutcome.registered;
    } on ApiException catch (exception) {
      _errorMessage = exception.message;
      return AuthSubmissionOutcome.failed;
    } catch (_) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      return AuthSubmissionOutcome.failed;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }
}
