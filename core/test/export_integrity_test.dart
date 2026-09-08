import 'dart:io';

import 'package:test/test.dart';

/// FR-003 / Constitution II: clients may import ONLY `package:core/core.dart`.
void main() {
  final String repoRoot = Directory.current.parent.path;

  final List<Directory> clientLibDirs = [
    Directory('$repoRoot/app/lib'),
    Directory('$repoRoot/web/lib'),
  ];

  test('clients import core only via its public entry point', () async {
    final List<String> violations = <String>[];
    const String legalImport = 'package:core/core.dart';
    final RegExp coreImport = RegExp(r'''['"]package:core/([^'"]+)['"]''');

    for (final Directory dir in clientLibDirs) {
      if (!dir.existsSync()) {
        fail('missing client library directory: ${dir.path}');
      }
      await for (final FileSystemEntity entity in dir.list(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final String src = entity.readAsStringSync();
        for (final RegExpMatch m in coreImport.allMatches(src)) {
          final String imported = m.group(0)!;
          if (imported != "'$legalImport'" && imported != '"$legalImport"') {
            violations.add('${entity.path}: imports $imported');
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Internal core modules must never be imported by clients:\n'
          '${violations.join('\n')}',
    );
  });
}
