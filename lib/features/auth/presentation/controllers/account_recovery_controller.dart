import 'package:flutter/foundation.dart';

import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/auth/domain/entities/password_reset_credentials.dart';
import 'package:fitness_social_app/features/auth/domain/usecases/account_recovery_usecases.dart';

class AccountRecoveryController extends ChangeNotifier {
  AccountRecoveryController({
    required RequestPasswordReset requestPasswordReset,
    required ResetPassword resetPassword,
    required VerifyEmail verifyEmail,
  })  : _requestPasswordReset = requestPasswordReset,
        _resetPassword = resetPassword,
        _verifyEmail = verifyEmail;

  final RequestPasswordReset _requestPasswordReset;
  final ResetPassword _resetPassword;
  final VerifyEmail _verifyEmail;

  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> requestPasswordReset(String email) {
    return _submit(() => _requestPasswordReset(email));
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) {
    return _submit(
      () => _resetPassword(
        PasswordResetCredentials(token: token, newPassword: newPassword),
      ),
    );
  }

  Future<bool> verifyEmail(String token) {
    return _submit(() => _verifyEmail(token));
  }

  Future<bool> _submit(Future<String> Function() action) async {
    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      _successMessage = await action();
      return true;
    } on ApiException catch (exception) {
      _errorMessage = exception.message;
      return false;
    } catch (_) {
      _errorMessage = 'حدث خطأ غير متوقع. حاول مرة أخرى.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
