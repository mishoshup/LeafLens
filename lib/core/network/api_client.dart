import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:leaflens/core/config/app_config.dart';
import 'package:leaflens/core/errors/failures.dart';

/// HTTP client for FastAPI backend.
///
/// Attaches user JWT to every request if available.
/// Throws typed Failures that Riverpod providers catch in the UI layer.
class ApiClient {
  /// Creates an [ApiClient] with an optional custom [baseUrl].
  /// Defaults to [AppConfig.apiUrl].
  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.apiUrl;

  /// The base URL for all HTTP requests (no trailing slash).
  final String baseUrl;

  /// The JWT token to attach as a Bearer header, or null if not authenticated.
  String? token;

  Map<String, String> get _headers {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (token != null) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  /// Sends a GET request to [path] with optional query [params].
  /// Returns the decoded JSON body as a map.
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? params,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers);
    return _handle(response);
  }

  /// Sends a POST request to [path] with an optional JSON [body].
  /// Uses the auth header if [token] is set.
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.post(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handle(response);
  }

  /// POST without auth header (for login/register).
  Future<Map<String, dynamic>> postPublic(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body != null ? jsonEncode(body) : null,
    );
    return _handle(response);
  }

  Map<String, dynamic> _handle(http.Response response) {
    if (response.statusCode == 401) {
      token = null;
      throw const SessionExpiredFailure();
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiFailure(response.statusCode, response.body);
    }
    if (response.body.isEmpty) return {};
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
