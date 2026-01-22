import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../configs/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _bearerToken;
  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  void setBearerToken(String token) {
    _bearerToken = token;
  }

  void clearBearerToken() {
    _bearerToken = null;
  }

  Map<String, String> _getHeaders({Map<String, String>? additionalHeaders}) {
    final headers = Map<String, String>.from(_defaultHeaders);

    if (_bearerToken != null) {
      headers['Authorization'] = 'Bearer $_bearerToken';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  Uri _buildUrl(String endpoint, {Map<String, dynamic>? queryParams}) {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    if (queryParams != null && queryParams.isNotEmpty) {
      return url.replace(queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())));
    }

    return url;
  }

  Future<ApiResponse> get(String endpoint, {Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
    try {
      final url = _buildUrl(endpoint, queryParams: queryParams);
      print('url: $url');
      print('headers: ${_getHeaders(additionalHeaders: headers)}');
      final response = await http.get(url, headers: _getHeaders(additionalHeaders: headers));

      return _handleResponse(response);
    } on SocketException catch (e) {
      debugPrint('SocketException: $e');
      return ApiResponse(statusCode: 500, data: 'Không có kết nối internet', success: false);
    } on HttpException catch (e) {
      debugPrint('HttpException: $e');
      return ApiResponse(statusCode: 500, data: 'Không tìm thấy dữ liệu', success: false);
    } on FormatException catch (e) {
      debugPrint('FormatException: $e');
      return ApiResponse(statusCode: 500, data: 'Định dạng dữ liệu không hợp lệ', success: false);
    } catch (e) {
      debugPrint('Exception: $e');
      return ApiResponse(statusCode: 500, data: 'Lỗi không xác định: $e', success: false);
    }
  }

  Future<ApiResponse> post(String endpoint, {Map<String, dynamic>? body, Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
    try {
      final url = _buildUrl(endpoint, queryParams: queryParams);
      final response = await http.post(
        url,
        headers: _getHeaders(additionalHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Không có kết nối internet');
    } on HttpException {
      throw ApiException('Không tìm thấy dữ liệu');
    } on FormatException {
      throw ApiException('Định dạng dữ liệu không hợp lệ');
    } catch (e) {
      throw ApiException('Lỗi không xác định: $e');
    }
  }

  Future<ApiResponse> put(String endpoint, {Map<String, dynamic>? body, Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
    try {
      final url = _buildUrl(endpoint, queryParams: queryParams);
      final response = await http.put(
        url,
        headers: _getHeaders(additionalHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Không có kết nối internet');
    } on HttpException {
      throw ApiException('Không tìm thấy dữ liệu');
    } on FormatException {
      throw ApiException('Định dạng dữ liệu không hợp lệ');
    } catch (e) {
      throw ApiException('Lỗi không xác định: $e');
    }
  }

  Future<ApiResponse> patch(String endpoint, {Map<String, dynamic>? body, Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
    try {
      final url = _buildUrl(endpoint, queryParams: queryParams);
      final response = await http.patch(
        url,
        headers: _getHeaders(additionalHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Không có kết nối internet');
    } on HttpException {
      throw ApiException('Không tìm thấy dữ liệu');
    } on FormatException {
      throw ApiException('Định dạng dữ liệu không hợp lệ');
    } catch (e) {
      throw ApiException('Lỗi không xác định: $e');
    }
  }

  Future<ApiResponse> delete(String endpoint, {Map<String, dynamic>? body, Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
    try {
      final url = _buildUrl(endpoint, queryParams: queryParams);
      final response = await http.delete(
        url,
        headers: _getHeaders(additionalHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Không có kết nối internet');
    } on HttpException {
      throw ApiException('Không tìm thấy dữ liệu');
    } on FormatException {
      throw ApiException('Định dạng dữ liệu không hợp lệ');
    } catch (e) {
      throw ApiException('Lỗi không xác định: $e');
    }
  }

  ApiResponse _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    dynamic data;
    try {
      data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (e) {
      data = response.body;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse(statusCode: statusCode, data: data, success: true);
    } else if (statusCode == 401) {
      throw ApiException('Không có quyền truy cập. Vui lòng đăng nhập lại.');
    } else if (statusCode == 403) {
      throw ApiException('Không có quyền thực hiện hành động này.');
    } else if (statusCode == 404) {
      throw ApiException('Không tìm thấy dữ liệu.');
    } else if (statusCode == 500) {
      throw ApiException('Lỗi server. Vui lòng thử lại sau.');
    } else {
      throw ApiException(data is Map && data.containsKey('message') ? data['message'] : 'Lỗi không xác định (Status: $statusCode)');
    }
  }
}

class ApiResponse {
  final int statusCode;
  final dynamic data;
  final bool success;

  ApiResponse({required this.statusCode, required this.data, required this.success});

  @override
  String toString() {
    return 'ApiResponse(statusCode: $statusCode, success: $success, data: $data)';
  }
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}
