import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../security/hardware_keystore_service.dart';

/// Interceptor to automatically attach Hardware-stored Bearer Tokens
/// and manage 401 Unauthorized token refresh flows
class AuthInterceptor extends Interceptor {
  final HardwareKeystoreService keystoreService;
  final Dio dio;

  AuthInterceptor({
    required this.keystoreService,
    required this.dio,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await keystoreService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['X-AeroVault-Client-Version'] = AppConstants.appVersion;
    options.headers['Accept'] = 'application/json';

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Automatic Refresh Token Flow
      final refreshToken = await keystoreService.getRefreshToken();
      if (refreshToken != null) {
        try {
          // Attempt token refresh
          final refreshResponse = await dio.post(
            '/auth/refresh',
            data: {'refresh_token': refreshToken},
            options: Options(headers: {'No-Auth': 'true'}),
          );

          if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
            final newAccessToken = refreshResponse.data['access_token'] as String;
            final newRefreshToken = refreshResponse.data['refresh_token'] as String? ?? refreshToken;

            await keystoreService.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            // Retry original request with new token
            final requestOptions = err.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final cloneResponse = await dio.fetch(requestOptions);
            return handler.resolve(cloneResponse);
          }
        } catch (_) {
          // Wipe on failed refresh to protect session
          await keystoreService.wipeAllTokensAndSecrets();
        }
      }
    }

    return handler.next(err);
  }
}
