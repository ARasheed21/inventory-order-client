import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';


import 'package:core/core.dart';
import 'package:dio/io.dart';

/// Validates server certificates against configured SPKI/cert pins
/// (Constitution VIII, FR-013 release hardening).
///
/// Active only in release-like environments when `CERT_PINS` is present.
/// Pins are SHA-256 hashes (hex) of the leaf certificate DER — computed once
/// per connection attempt and compared against the configured allow-list.
final class CertificatePinner {
  const CertificatePinner({required List<String> pins}) : _pins = pins;

  final List<String> _pins;

  bool get enabled => _pins.isNotEmpty;

  /// Returns `true` when the presented certificate matches a known pin.
  bool accepts(X509Certificate cert, String host) {
    if (!enabled) {
      return true;
    }
    final String fingerprint = sha256
        .convert(cert.der)
        .toString()
        .toLowerCase();
    final bool allowed = _pins.contains(fingerprint);
    if (!allowed) {
      throw CertificatePinException(host, fingerprint);
    }
    return true;
  }

  /// Installs pinning onto the given [Dio] instance.
  void install(Dio dio) {
    if (!enabled) return;
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final HttpClient client = HttpClient()
          ..badCertificateCallback =
              (X509Certificate cert, String host, int port) {
                try {
                  return accepts(cert, host);
                } on CertificatePinException {
                  return false;
                }
              };
        return client;
      },
    );
  }
}

/// Thrown when a server presents a certificate that does not match any pin.
final class CertificatePinException implements Exception {
  const CertificatePinException(this.host, this.fingerprint);

  final String host;
  final String fingerprint;

  @override
  String toString() =>
      'CertificatePinException: certificate for $host does not match any '
      'configured pin ($fingerprint)';
}

/// Convenience factory from environment configuration.
CertificatePinner? pinnerFromConfig(EnvironmentConfig config) {
  if (!config.isReleaseLike) return null;
  if (config.certPins.isEmpty) return null;
  return CertificatePinner(pins: config.certPins);
}
