import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../storage/local_storage.dart';
import 'api_exception.dart';

/// Wrapper HTTP client yang otomatis menambahkan header:
/// - x-app-key: `appKey` (wajib di semua request)
/// - Authorization: Bearer `token` (untuk endpoint yang butuh login user)
class ApiClient {
  static const Duration _timeout = Duration(seconds: 20);

  static Future<Map<String, String>> _headers({
    bool withAuth = false,
    bool isJson = true,
  }) async {
    final headers = <String, String>{};
    if (isJson) headers['Content-Type'] = 'application/json';

    final appKey = await LocalStorage.getAppKey();
    if (appKey != null && appKey.isNotEmpty) {
      headers['x-app-key'] = appKey;
    }

    if (withAuth) {
      final token = await LocalStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Uri _uri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    if (query == null || query.isEmpty) return uri;
    final filtered = <String, String>{};
    query.forEach((key, value) {
      if (value != null) filtered[key] = value.toString();
    });
    return uri.replace(queryParameters: filtered);
  }

  // ---------------- GET ----------------
  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    bool withAuth = false,
  }) async {
    final res = await http
        .get(_uri(path, query), headers: await _headers(withAuth: withAuth))
        .timeout(_timeout);
    return _handleResponse(res);
  }

  // ---------------- POST (JSON) ----------------
  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool withAuth = false,
  }) async {
    final res = await http
        .post(
          _uri(path),
          headers: await _headers(withAuth: withAuth),
          body: jsonEncode(body ?? {}),
        )
        .timeout(_timeout);
    return _handleResponse(res);
  }

  // ---------------- PUT (JSON) ----------------
  static Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool withAuth = false,
  }) async {
    final res = await http
        .put(
          _uri(path),
          headers: await _headers(withAuth: withAuth),
          body: jsonEncode(body ?? {}),
        )
        .timeout(_timeout);
    return _handleResponse(res);
  }

  // ---------------- DELETE ----------------
  static Future<Map<String, dynamic>> delete(
    String path, {
    bool withAuth = false,
  }) async {
    final res = await http
        .delete(_uri(path), headers: await _headers(withAuth: withAuth))
        .timeout(_timeout);
    return _handleResponse(res);
  }

  // ---------------- MULTIPART (POST/PUT dengan file foto) ----------------
  static Future<Map<String, dynamic>> multipart(
    String path, {
    required String method, // 'POST' atau 'PUT'
    Map<String, String>? fields,
    File? file,
    String fileFieldName = 'foto',
    bool withAuth = false,
  }) async {
    final uri = _uri(path);
    final request = http.MultipartRequest(method, uri);

    final headers = await _headers(withAuth: withAuth, isJson: false);
    request.headers.addAll(headers);

    if (fields != null) request.fields.addAll(fields);

    if (file != null) {
      request.files.add(
        await http.MultipartFile.fromPath(fileFieldName, file.path),
      );
    }

    final streamedRes = await request.send().timeout(_timeout);
    final res = await http.Response.fromStream(streamedRes);
    return _handleResponse(res);
  }

  // ---------------- Response Handler ----------------
  static Map<String, dynamic> _handleResponse(http.Response res) {
    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        statusCode: res.statusCode,
        message: 'Gagal membaca response server (status ${res.statusCode})',
      );
    }

    final success = decoded['success'] == true;
    if (res.statusCode >= 200 && res.statusCode < 300 && success) {
      return decoded;
    }

    throw ApiException(
      statusCode: decoded['statusCode'] ?? res.statusCode,
      message: decoded['message'] ?? 'Terjadi kesalahan pada server',
      errors: decoded['errors'],
    );
  }
}
