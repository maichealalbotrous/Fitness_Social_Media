import 'dart:async';
import 'dart:convert';

import 'package:fitness_social_app/core/config/app_config.dart';
import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({http.Client? client, SessionStorage? sessionStorage})
      : _client = client ?? http.Client(),
        _sessionStorage = sessionStorage;

  final http.Client _client;
  final SessionStorage? _sessionStorage;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? headers,
  }) async {
    final response = await _sendRequest('GET', path, headers: headers);
    return _decodeObjectResponse(response);
  }

  Future<dynamic> getJsonValue(
    String path, {
    Map<String, String>? headers,
  }) async {
    final response = await _sendRequest('GET', path, headers: headers);
    final decodedBody = _decodeValue(response.body);
    _ensureSuccess(response, decodedBody);
    return decodedBody;
  }

  Future<List<dynamic>> getListValue(
    String path, {
    Map<String, String>? headers,
  }) async {
    final response = await _sendRequest('GET', path, headers: headers);
    final decodedBody = _decodeValue(response.body);
    _ensureSuccess(response, decodedBody);
    if (decodedBody is! List) {
      throw const ApiException(message: 'Invalid list response.');
    }
    return decodedBody.toList(growable: false);
  }

  Future<List<String>> getStringList(
    String path, {
    Map<String, String>? headers,
  }) async {
    final response = await _sendRequest('GET', path, headers: headers);
    final decodedBody = _decodeValue(response.body);
    _ensureSuccess(response, decodedBody);
    if (decodedBody is! List) {
      throw const ApiException(message: 'Invalid list response.');
    }
    return decodedBody.map((item) => item.toString()).toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> getListJson(
    String path, {
    Map<String, String>? headers,
  }) async {
    final response = await _sendRequest('GET', path, headers: headers);
    final decodedBody = _decodeValue(response.body);
    _ensureSuccess(response, decodedBody);

    if (decodedBody is! List) {
      throw const ApiException(message: 'Invalid posts response.');
    }

    return decodedBody
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    final response = await _sendRequest(
      'POST',
      path,
      body: body,
      headers: headers,
    );
    return _decodeObjectResponse(response);
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    final response = await _sendRequest(
      'PUT',
      path,
      body: body,
      headers: headers,
    );
    return _decodeObjectResponse(response);
  }

  Future<dynamic> putJsonValue(
    String path, {
    required dynamic body,
    Map<String, String>? headers,
  }) async {
    final response = await _sendRequest(
      'PUT',
      path,
      body: body,
      headers: headers,
    );
    final decoded = _decodeValue(response.body);
    _ensureSuccess(response, decoded);
    return decoded;
  }

  Future<Map<String, dynamic>> postMultipartBytes(
    String path, {
    required String fieldName,
    required String fileName,
    required List<int> bytes,
  }) async {
    try {
      final request = http.MultipartRequest('POST', AppConfig.apiUri(path));
      request.headers.addAll({
        'Accept': 'application/json',
        ...await _authorizationHeaders(),
      });
      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: fileName,
        ),
      );
      final streamedResponse = await _client
          .send(request)
          .timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);
      return _decodeObjectResponse(response);
    } on TimeoutException {
      throw const ApiException(
        message: 'The server connection timed out. Please try again.',
      );
    } on http.ClientException {
      throw const ApiException(
        message: 'Unable to connect to the server. Check the API URL and network connection.',
      );
    }
  }

  Future<Map<String, dynamic>> postMultipartFiles(
    String path, {
    required String fieldName,
    required List<MultipartUploadFile> files,
  }) async {
    try {
      final request = http.MultipartRequest('POST', AppConfig.apiUri(path));
      request.headers.addAll({
        'Accept': 'application/json',
        ...await _authorizationHeaders(),
      });
      for (final file in files) {
        request.files.add(http.MultipartFile.fromBytes(
          fieldName,
          file.bytes,
          filename: file.fileName,
        ));
      }
      final streamedResponse = await _client.send(request).timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      return _decodeObjectResponse(response);
    } on TimeoutException {
      throw const ApiException(message: 'File upload timed out. Please try again.');
    } on http.ClientException {
      throw const ApiException(message: 'Unable to connect to the server while uploading files.');
    }
  }

  Future<Map<String, dynamic>> patchJson(
    String path, {
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String>? headers,
  }) async {
    final response = await _sendRequest(
      'PATCH',
      path,
      body: body,
      headers: headers,
    );
    return _decodeObjectResponse(response);
  }

  Future<Map<String, dynamic>> deleteJson(
    String path, {
    Map<String, String>? headers,
  }) async {
    final response = await _sendRequest('DELETE', path, headers: headers);
    return _decodeObjectResponse(response);
  }

  Future<http.Response> _sendRequest(
    String method,
    String path, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final request = http.Request(method, AppConfig.apiUri(path));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...await _authorizationHeaders(),
        ...?headers,
      });
      if (body != null) {
        request.body = jsonEncode(body);
      }

      final streamedResponse = await _client
          .send(request)
          .timeout(const Duration(seconds: 20));
      return http.Response.fromStream(streamedResponse);
    } on TimeoutException {
      throw const ApiException(
        message: 'The server connection timed out. Please try again.',
      );
    } on http.ClientException {
      throw const ApiException(
        message: 'Unable to connect to the server. Check the API URL and network connection.',
      );
    }
  }

  Future<Map<String, String>> _authorizationHeaders() async {
    final token = await _sessionStorage?.readAccessToken();
    if (token == null || token.isEmpty) {
      return <String, String>{};
    }
    return <String, String>{'Authorization': 'Bearer $token'};
  }

  Map<String, dynamic> _decodeObjectResponse(http.Response response) {
    final decodedBody = _decodeValue(response.body);
    _ensureSuccess(response, decodedBody);
    return decodedBody is Map<String, dynamic>
        ? decodedBody
        : <String, dynamic>{};
  }

  void _ensureSuccess(http.Response response, dynamic decodedBody) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final errorBody = decodedBody is Map<String, dynamic>
        ? decodedBody
        : <String, dynamic>{};
    throw ApiException(
      statusCode: response.statusCode,
      message: _readErrorMessage(errorBody),
    );
  }

  String _readErrorMessage(Map<String, dynamic> response) {
    final directMessage = response['message'];
    if (directMessage is String && directMessage.isNotEmpty) {
      return directMessage;
    }

    final validationErrors = response['errors'];
    if (validationErrors is Map<String, dynamic>) {
      final messages = validationErrors.values
          .expand((value) => value is List ? value : <dynamic>[value])
          .whereType<String>()
          .where((message) => message.isNotEmpty)
          .toList();
      if (messages.isNotEmpty) {
        return messages.join('\n');
      }
    }

    final detail = response['detail'];
    if (detail is String && detail.isNotEmpty) {
      return detail;
    }

    final title = response['title'];
    if (title is String && title.isNotEmpty) {
      return title;
    }

    return 'Unable to complete the request. Please try again.';
  }

  dynamic _decodeValue(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      return jsonDecode(body);
    } on FormatException {
      return <String, dynamic>{};
    }
  }
}

class MultipartUploadFile {
  const MultipartUploadFile({required this.fileName, required this.bytes});

  final String fileName;
  final List<int> bytes;
}

class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
