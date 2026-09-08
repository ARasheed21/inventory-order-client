import 'dart:convert';

import 'package:core/core.dart';
import 'package:http/http.dart' as http;

/// Resolves [EnvironmentConfig] from a runtime-fetched `/env.json` document
/// served next to the app (git-ignored; see `web/env.example.json`).
///
/// The deploy pipeline generates `env.json` from pipeline secrets so no
/// environment value is ever hard-coded (FR-014).
abstract final class WebEnv {
  static Future<EnvironmentConfig> load() async {
    final Map<String, String?> lookup;
    try {
      final response = await http.get(Uri.parse('env.json'));
      if (response.statusCode != 200) {
        throw MissingEnvironmentException(
          'env.json',
          reason:
              'HTTP ${response.statusCode} while loading environment document',
        );
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      lookup = decoded.map((k, v) => MapEntry(k, v?.toString()));
    } on Object catch (error, stackTrace) {
      reportStartupProblem(error, stackTrace: stackTrace);
      rethrow;
    }
    try {
      return EnvironmentConfig.fromEnvironment(lookup: lookup);
    } on Object catch (error, stackTrace) {
      reportStartupProblem(error, stackTrace: stackTrace);
      rethrow;
    }
  }
}
