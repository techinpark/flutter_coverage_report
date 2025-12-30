import 'file_coverage.dart';

/// Represents the complete coverage data from an lcov.info file.
class CoverageData {
  /// Test name (TN field in lcov).
  final String? testName;

  /// Coverage data for each file.
  final List<FileCoverage> files;

  /// Timestamp when the report was generated.
  final DateTime generatedAt;

  /// Title for the report.
  final String title;

  const CoverageData({
    this.testName,
    required this.files,
    required this.generatedAt,
    this.title = 'Coverage Report',
  });

  /// Total number of executable lines across all files.
  int get totalLinesFound => files.fold(0, (sum, f) => sum + f.linesFound);

  /// Total number of covered lines across all files.
  int get totalLinesHit => files.fold(0, (sum, f) => sum + f.linesHit);

  /// Total number of functions across all files.
  int get totalFunctionsFound =>
      files.fold(0, (sum, f) => sum + f.functionsFound);

  /// Total number of covered functions across all files.
  int get totalFunctionsHit => files.fold(0, (sum, f) => sum + f.functionsHit);

  /// Overall line coverage percentage (0-100).
  double get lineCoveragePercent {
    if (totalLinesFound == 0) return 100.0;
    return (totalLinesHit / totalLinesFound) * 100;
  }

  /// Overall function coverage percentage (0-100).
  double get functionCoveragePercent {
    if (totalFunctionsFound == 0) return 100.0;
    return (totalFunctionsHit / totalFunctionsFound) * 100;
  }

  /// Overall coverage status.
  CoverageStatus get status {
    final percent = lineCoveragePercent;
    if (percent >= 80) return CoverageStatus.high;
    if (percent >= 50) return CoverageStatus.medium;
    return CoverageStatus.low;
  }

  /// Number of files with high coverage (80%+).
  int get highCoverageCount =>
      files.where((f) => f.status == CoverageStatus.high).length;

  /// Number of files with medium coverage (50-79%).
  int get mediumCoverageCount =>
      files.where((f) => f.status == CoverageStatus.medium).length;

  /// Number of files with low coverage (<50%).
  int get lowCoverageCount =>
      files.where((f) => f.status == CoverageStatus.low).length;

  /// Top N files with lowest coverage.
  List<FileCoverage> getLowestCoverageFiles(int count) {
    final sorted = List<FileCoverage>.from(files)
      ..sort((a, b) => a.lineCoveragePercent.compareTo(b.lineCoveragePercent));
    return sorted.take(count).toList();
  }

  /// Files sorted by path for tree view.
  List<FileCoverage> get filesSortedByPath {
    final sorted = List<FileCoverage>.from(files)
      ..sort((a, b) => a.relativePath.compareTo(b.relativePath));
    return sorted;
  }

  /// Get unique directories from all files.
  Set<String> get directories {
    final dirs = <String>{};
    for (final file in files) {
      final parts = file.relativePath.split('/');
      var current = '';
      for (var i = 0; i < parts.length - 1; i++) {
        current = current.isEmpty ? parts[i] : '$current/${parts[i]}';
        dirs.add(current);
      }
    }
    return dirs;
  }

  @override
  String toString() =>
      'CoverageData(${files.length} files, ${lineCoveragePercent.toStringAsFixed(1)}% coverage)';
}
