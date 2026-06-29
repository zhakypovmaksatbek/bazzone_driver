import 'package:dio/dio.dart';

class DioClient {
  DioClient({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? '',
          headers: {'Content-Type': 'application/json'},
        ),
      );

  final Dio _dio;

  Dio get dio => _dio;
}
