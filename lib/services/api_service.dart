import 'dart:convert';
import 'dart:io';
import 'package:chatbotflowclient/configs/toast_message_config.dart';
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
    String errorMessage = '';
    try {
      final url = _buildUrl(endpoint, queryParams: queryParams);
      final response = await http.get(url, headers: _getHeaders(additionalHeaders: headers));

      return _handleResponse(response);
    } on SocketException catch (e) {
      errorMessage = '${ToastMessageConfig.noInternetConnection}: $e';
    } on HttpException catch (e) {
      errorMessage = '${ToastMessageConfig.noDataFound}: $e';
    } on FormatException catch (e) {
      errorMessage = '${ToastMessageConfig.invalidDataFormat}: $e';
    } catch (e) {
      errorMessage = '${ToastMessageConfig.unknownError}: $e';
    }

    return ApiResponse(statusCode: 500, data: errorMessage, success: false);
  }

  Future<ApiResponse> post(String endpoint, {Map<String, dynamic>? body, Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
    String errorMessage = '';
    try {
      final url = _buildUrl(endpoint, queryParams: queryParams);
      final response = await http.post(
        url,
        headers: _getHeaders(additionalHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } on SocketException catch (e) {
      errorMessage = '${ToastMessageConfig.noInternetConnection}: $e';
    } on HttpException catch (e) {
      errorMessage = '${ToastMessageConfig.noDataFound}: $e';
    } on FormatException catch (e) {
      errorMessage = '${ToastMessageConfig.invalidDataFormat}: $e';
    } catch (e) {
      errorMessage = '${ToastMessageConfig.unknownError}: $e';
    }

    return ApiResponse(statusCode: 500, data: errorMessage, success: false);
  }

  Future<ApiResponse> put(String endpoint, {Map<String, dynamic>? body, Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
    String errorMessage = '';
    try {
      final url = _buildUrl(endpoint, queryParams: queryParams);
      final response = await http.put(
        url,
        headers: _getHeaders(additionalHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } on SocketException catch (e) {
      errorMessage = '${ToastMessageConfig.noInternetConnection}: $e';
    } on HttpException catch (e) {
      errorMessage = '${ToastMessageConfig.noDataFound}: $e';
    } on FormatException catch (e) {
      errorMessage = '${ToastMessageConfig.invalidDataFormat}: $e';
    } catch (e) {
      errorMessage = '${ToastMessageConfig.unknownError}: $e';
    }

    return ApiResponse(statusCode: 500, data: errorMessage, success: false);
  }

  Future<ApiResponse> patch(String endpoint, {Map<String, dynamic>? body, Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
    String errorMessage = '';
    try {
      final url = _buildUrl(endpoint, queryParams: queryParams);
      final response = await http.patch(
        url,
        headers: _getHeaders(additionalHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } on SocketException catch (e) {
      errorMessage = '${ToastMessageConfig.noInternetConnection}: $e';
    } on HttpException catch (e) {
      errorMessage = '${ToastMessageConfig.noDataFound}: $e';
    } on FormatException catch (e) {
      errorMessage = '${ToastMessageConfig.invalidDataFormat}: $e';
    } catch (e) {
      errorMessage = '${ToastMessageConfig.unknownError}: $e';
    }

    return ApiResponse(statusCode: 500, data: errorMessage, success: false);
  }

  Future<ApiResponse> delete(String endpoint, {Map<String, dynamic>? body, Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
    String errorMessage = '';
    try {
      final url = _buildUrl(endpoint, queryParams: queryParams);
      final response = await http.delete(
        url,
        headers: _getHeaders(additionalHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } on SocketException catch (e) {
      errorMessage = '${ToastMessageConfig.noInternetConnection}: $e';
    } on HttpException catch (e) {
      errorMessage = '${ToastMessageConfig.noDataFound}: $e';
    } on FormatException catch (e) {
      errorMessage = '${ToastMessageConfig.invalidDataFormat}: $e';
    } catch (e) {
      errorMessage = '${ToastMessageConfig.unknownError}: $e';
    }

    return ApiResponse(statusCode: 500, data: errorMessage, success: false);
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
    } else {
      String errorMessage = '';
      if (statusCode == 401) {
        errorMessage = ToastMessageConfig.forbidden;
      } else if (statusCode == 403) {
        errorMessage = ToastMessageConfig.forbidden;
      } else if (statusCode == 404) {
        errorMessage = ToastMessageConfig.notFound;
      } else if (statusCode == 500) {
        errorMessage = ToastMessageConfig.internalServerError;
      } else {
        errorMessage = data is Map && data.containsKey('message') ? data['message'] : '${ToastMessageConfig.unknownError} (Status: $statusCode)';
      }

      return ApiResponse(statusCode: statusCode, data: errorMessage, success: false);
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
