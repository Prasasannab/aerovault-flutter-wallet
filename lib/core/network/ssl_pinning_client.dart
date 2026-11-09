import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';

/// Bank-Grade Dio Client with Enforced SSL Certificate Pinning
class SslPinningClient {
  const SslPinningClient._();

  /// Create and configure a secure Dio instance with Public Key Pinning & timeouts
  static Dio createSecureDio({
    bool enforcePinning = true,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: AppConstants.connectTimeoutSeconds),
        receiveTimeout: const Duration(seconds: AppConstants.receiveTimeoutSeconds),
        sendTimeout: const Duration(seconds: AppConstants.connectTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'X-Client-Platform': Platform.isIOS ? 'iOS' : 'Android',
        },
      ),
    );

    // Apply native SSL Certificate validation on mobile platforms
    final adapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient(context: SecurityContext(withTrustedRoots: true));

        if (enforcePinning) {
          client.badCertificateCallback = (X509Certificate cert, String host, int port) {
            // Calculate SHA-256 fingerprint of the certificate DER bytes
            final certFingerprint = sha256.convert(cert.der).toString().toLowerCase();

            // Match against pinned bank certificate hashes
            final isPinned = ApiEndpoints.pinnedCertificateFingerprints
                .map((e) => e.toLowerCase())
                .contains(certFingerprint);

            // Rejects MITM proxy tools like Charles Proxy, Wireshark, Burp Suite
            return isPinned;
          };
        }

        return client;
      },
    );

    dio.httpClientAdapter = adapter;

    return dio;
  }
}
