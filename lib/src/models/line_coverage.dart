/// Represents coverage data for a single line of code.
class LineCoverage {
  /// The line number (1-indexed).
  final int lineNumber;

  /// The number of times this line was executed.
  /// 0 means the line was not covered.
  /// null means the line is not executable (comments, blank lines, etc.)
  final int? hitCount;

  const LineCoverage({
    required this.lineNumber,
    required this.hitCount,
  });

  /// Whether this line was covered (executed at least once).
  bool get isCovered => hitCount != null && hitCount! > 0;

  /// Whether this line is executable (has coverage data).
  bool get isExecutable => hitCount != null;

  /// Whether this line was not covered but is executable.
  bool get isUncovered => hitCount != null && hitCount == 0;

  @override
  String toString() => 'LineCoverage(line: $lineNumber, hits: $hitCount)';
}
