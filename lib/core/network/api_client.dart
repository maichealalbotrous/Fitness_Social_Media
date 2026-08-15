import 'dart:async';
import 'dart:convert';

import 'package:fitness_social_app/core/config/app_config.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .post(
            AppConfig.apiUri(path),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              ...?headers,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      return _decodeResponse(response);
    } on TimeoutException {
      throw const ApiException(
        message: 'انتهت مهلة الاتصال بالخادم. حاول مرة أخرى.',
      );
    } on http.ClientException {
      throw const ApiException(
        message: 'تعذر الاتصال بالخادم. تحقق من عنوان API والاتصال بالشبكة.',
      );
    }
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final decodedBody = _decodeBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    final message = decodedBody['message'];
    throw ApiException(
      statusCode: response.statusCode,
      message: message is String && message.isNotEmpty
          ? message
          : 'تعذر إتمام الطلب. حاول مرة أخرى.',
    );
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } on FormatException {
      return <String, dynamic>{};
    }
  }
}

class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
