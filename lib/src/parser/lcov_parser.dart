import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/models.dart';

/// Parser for lcov.info files.
class LcovParser {
  /// Base path to use for resolving relative paths.
  final String? basePath;

  /// Title for the report.
  final String title;

  const LcovParser({
    this.basePath,
    this.title = 'Coverage Report',
  });

  /// Parse an lcov.info file and return coverage data.
  Future<CoverageData> parse(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('File not found', filePath);
    }

    final content = await file.readAsString();
    return parseContent(content);
  }

  /// Parse lcov content string and return coverage data.
  CoverageData parseContent(String content) {
    final lines = content.split('\n');
    final files = <FileCoverage>[];
    String? testName;

    // Current file being parsed
    String? currentFilePath;
    final currentLines = <int, LineCoverage>{};
    final currentFunctions = <int, String>{};
    int linesFound = 0;
    int linesHit = 0;
    int functionsFound = 0;
    int functionsHit = 0;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Test Name
      if (trimmed.startsWith('TN:')) {
        testName = trimmed.substring(3).trim();
        if (testName.isEmpty) testName = null;
        continue;
      }

      // Source File
      if (trimmed.startsWith('SF:')) {
        currentFilePath = trimmed.substring(3).trim();
        currentLines.clear();
        currentFunctions.clear();
        linesFound = 0;
        linesHit = 0;
        functionsFound = 0;
        functionsHit = 0;
        continue;
      }

      // Function: line,name
      if (trimmed.startsWith('FN:')) {
        final parts = trimmed.substring(3).split(',');
        if (parts.length >= 2) {
          final lineNum = int.tryParse(parts[0]);
          if (lineNum != null) {
            currentFunctions[lineNum] = parts.sublist(1).join(',');
          }
        }
        continue;
      }

      // Functions Found
      if (trimmed.startsWith('FNF:')) {
        functionsFound = int.tryParse(trimmed.substring(4)) ?? 0;
        continue;
      }

      // Functions Hit
      if (trimmed.startsWith('FNH:')) {
        functionsHit = int.tryParse(trimmed.substring(4)) ?? 0;
        continue;
      }

      // Line Data: line,hit_count
      if (trimmed.startsWith('DA:')) {
        final parts = trimmed.substring(3).split(',');
        if (parts.length >= 2) {
          final lineNum = int.tryParse(parts[0]);
          final hitCount = int.tryParse(parts[1]);
          if (lineNum != null) {
            currentLines[lineNum] = LineCoverage(
              lineNumber: lineNum,
              hitCount: hitCount,
            );
          }
        }
        continue;
      }

      // Lines Found
      if (trimmed.startsWith('LF:')) {
        linesFound = int.tryParse(trimmed.substring(3)) ?? 0;
        continue;
      }

      // Lines Hit
      if (trimmed.startsWith('LH:')) {
        linesHit = int.tryParse(trimmed.substring(3)) ?? 0;
        continue;
      }

      // End of record - save current file
      if (trimmed == 'end_of_record') {
        if (currentFilePath != null) {
          files.add(FileCoverage(
            filePath: currentFilePath,
            relativePath: _getRelativePath(currentFilePath),
            lines: Map.from(currentLines),
            linesFound: linesFound,
            linesHit: linesHit,
            functionsFound: functionsFound,
            functionsHit: functionsHit,
            functions: Map.from(currentFunctions),
          ));
        }
        currentFilePath = null;
        continue;
      }
    }

    return CoverageData(
      testName: testName,
      files: files,
      generatedAt: DateTime.now(),
      title: title,
    );
  }

  /// Convert absolute path to relative path based on basePath.
  String _getRelativePath(String filePath) {
    if (basePath != null) {
      final normalized = p.normalize(filePath);
      final base = p.normalize(basePath!);
      if (normalized.startsWith(base)) {
        var relative = normalized.substring(base.length);
        if (relative.startsWith('/') || relative.startsWith(r'\')) {
          relative = relative.substring(1);
        }
        return relative;
      }
    }

    // Try to extract a sensible relative path
    // Look for common patterns like 'lib/', 'src/', etc.
    final patterns = ['lib/', 'src/', 'test/', 'bin/'];
    for (final pattern in patterns) {
      final index = filePath.indexOf(pattern);
      if (index != -1) {
        return filePath.substring(index);
      }
    }

    // Fall back to the full path
    return filePath;
  }
}
