import 'line_coverage.dart';

/// Represents coverage data for a single source file.
class FileCoverage {
  /// The absolute path to the source file.
  final String filePath;

  /// The relative path for display purposes.
  final String relativePath;

  /// Coverage data for each line in the file.
  final Map<int, LineCoverage> lines;

  /// Total number of executable lines (LF in lcov).
  final int linesFound;

  /// Number of lines that were executed (LH in lcov).
  final int linesHit;

  /// Total number of functions in the file (FNF in lcov).
  final int functionsFound;

  /// Number of functions that were executed (FNH in lcov).
  final int functionsHit;

  /// Function definitions: line number -> function name.
  final Map<int, String> functions;

  const FileCoverage({
    required this.filePath,
    required this.relativePath,
    required this.lines,
    required this.linesFound,
    required this.linesHit,
    this.functionsFound = 0,
    this.functionsHit = 0,
    this.functions = const {},
  });

  /// Line coverage percentage (0-100).
  double get lineCoveragePercent {
    if (linesFound == 0) return 100.0;
    return (linesHit / linesFound) * 100;
  }

  /// Function coverage percentage (0-100).
  double get functionCoveragePercent {
    if (functionsFound == 0) return 100.0;
    return (functionsHit / functionsFound) * 100;
  }

  /// Coverage status based on percentage.
  CoverageStatus get status {
    final percent = lineCoveragePercent;
    if (percent >= 80) return CoverageStatus.high;
    if (percent >= 50) return CoverageStatus.medium;
    return CoverageStatus.low;
  }

  /// Number of uncovered lines.
  int get uncoveredLines => linesFound - linesHit;

  /// File name without path.
  String get fileName => relativePath.split('/').last;

  /// Directory path without file name.
  String get directory {
    final parts = relativePath.split('/');
    if (parts.length <= 1) return '';
    return parts.sublist(0, parts.length - 1).join('/');
  }

  @override
  String toString() =>
      'FileCoverage($relativePath: ${lineCoveragePercent.toStringAsFixed(1)}%)';
}

/// Coverage status levels.
enum CoverageStatus {
  high, // 80%+
  medium, // 50-79%
  low, // <50%
}
