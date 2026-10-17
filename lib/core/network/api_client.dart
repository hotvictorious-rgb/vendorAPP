import 'package:dio/dio.dart';
import '../services/storage_service.dart';
import 'api_exceptions.dart';

class ApiClient {
  final StorageService storageService;
  late final Dio dio;

  ApiClient({required this.storageService}) {
    dio = Dio(
      BaseOptions(
        baseUrl: storageService.getBaseUrl(),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Request & Auth Token Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Dynamic update of baseUrl in case of settings change
          options.baseUrl = storageService.getBaseUrl();
          options.headers['X-Terminal-Client'] = 'vendor_mobile_terminal';
          options.headers['X-Required-Role'] = 'vendor';

          final token = await storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          final response = error.response;
          String message = 'Network connection error. Please verify your internet.';
          int? statusCode = response?.statusCode;
          dynamic errors;

          dynamic serverData;
          if (response != null && response.data != null) {
            serverData = response.data;
            if (serverData is Map<String, dynamic>) {
              message = serverData['message'] ?? message;
              errors = serverData['errors'];
            }
          }

          // ZERO-KNOWLEDGE SECURITY MASKING:
          // Prevent internal server exceptions, SQL errors, or stack traces from reaching UI
          if (statusCode != null && statusCode >= 500) {
            message = 'An unexpected server error occurred. Please try again later.';
            errors = null;
          } else if (statusCode == 401) {
            message = 'Authentication required or session expired.';
          } else if (statusCode == 403) {
            if (serverData is! Map<String, dynamic> || serverData['message'] == null) {
              message = 'Access denied. You do not have permission for this action.';
            }
          }

          final customException = ApiException(
            message: message,
            statusCode: statusCode,
            errors: errors,
          );

          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: customException,
              type: error.type,
            ),
          );
        },
      ),
    );
  }

  // GET
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: e.message ?? 'Unknown request error');
    }
  }

  // POST
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.post(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: e.message ?? 'Unknown request error');
    }
  }
}
