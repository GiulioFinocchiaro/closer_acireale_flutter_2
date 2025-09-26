import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'https://www.closeracireale.it/backend/public/api';

  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  // GET request
  Future<dynamic> get(
      String endpoint, {
        String? token,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<dynamic> post(
      String endpoint,
      Map<String, dynamic> data, {
        String? token,
        bool isFormData = false,
      }) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final dynamic requestData = isFormData ? FormData.fromMap(data) : data;

      final response = await _dio.post(
        endpoint,
        data: requestData,
        options: options,
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<dynamic> put(
      String endpoint,
      Map<String, dynamic> data, {
        String? token,
        bool isFormData = false,
      }) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final dynamic requestData = isFormData ? FormData.fromMap(data) : data;

      final response = await _dio.put(
        endpoint,
        data: requestData,
        options: options,
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<dynamic> delete(
      String endpoint, {
        Map<String, dynamic>? data,
        String? token,
      }) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final response = await _dio.delete(
        endpoint,
        data: data,
        options: options,
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Handle response
  dynamic _handleResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      if (response.data is Map<String, dynamic> || response.data is List) {
        return response.data;
      } else if (response.data is String) {
        try {
          final decoded = json.decode(response.data);
          if (decoded is Map<String, dynamic> || decoded is List) {
            return decoded;
          } else {
            throw Exception('Formato di risposta non valido');
          }
        } catch (e) {
          throw Exception('Formato di risposta non valido: $e');
        }
      } else {
        throw Exception('Formato di risposta non supportato');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.statusMessage}');
    }
  }

  // Handle errors
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return Exception('Timeout della connessione');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = _extractErrorMessage(error.response?.data);
          return Exception('$statusCode: $message');
        case DioExceptionType.cancel:
          return Exception('Richiesta annullata');
        case DioExceptionType.connectionError:
          return Exception('Errore di connessione');
        default:
          return Exception('Errore sconosciuto: ${error.message}');
      }
    }
    return Exception('Errore imprevisto: ${error.toString()}');
  }

  // Extract error message from response
  String _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return 'Errore sconosciuto dal server';

    if (responseData is Map<String, dynamic>) {
      return responseData['message'] ??
          responseData['error'] ??
          'Errore dal server';
    }

    if (responseData is String) {
      return responseData;
    }

    return 'Errore sconosciuto dal server';
  }
}