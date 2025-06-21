import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import '../constants/app_constants.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  late final Dio _dio;
  final Connectivity _connectivity = Connectivity();

  void initialize() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: Duration(seconds: AppConstants.connectTimeoutSeconds),
        receiveTimeout: Duration(seconds: AppConstants.receiveTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add request/response interceptors for logging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) {
          // Print logs in debug mode only
          debugPrint('[API] $object');
        },
      ),
    );
  }

  /// Check if device has internet connection
  Future<bool> hasInternetConnection() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    return !connectivityResults.contains(ConnectivityResult.none);
  }

  /// Generic GET request
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Generic POST request
  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert to custom exceptions
  NetworkException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Connection timeout. Please check your internet connection.',
          type: NetworkExceptionType.timeout,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection. Please check your network settings.',
          type: NetworkExceptionType.noInternet,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _getHttpErrorMessage(statusCode);
        return NetworkException(
          message,
          type: NetworkExceptionType.serverError,
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return NetworkException(
          'Request was cancelled.',
          type: NetworkExceptionType.cancelled,
        );

      default:
        return NetworkException(
          'An unexpected error occurred: ${error.message}',
          type: NetworkExceptionType.unknown,
        );
    }
  }

  String _getHttpErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized access.';
      case 403:
        return 'Forbidden access.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'Server error (Code: $statusCode). Please try again.';
    }
  }
}

/// Custom network exception class
class NetworkException implements Exception {
  final String message;
  final NetworkExceptionType type;
  final int? statusCode;

  NetworkException(this.message, {required this.type, this.statusCode});

  @override
  String toString() => message;
}

/// Types of network exceptions
enum NetworkExceptionType {
  timeout,
  noInternet,
  serverError,
  cancelled,
  unknown,
}
