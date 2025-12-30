import 'package:flutter_coverage_report/flutter_coverage_report.dart';
import 'package:test/test.dart';

void main() {
  group('LcovParser', () {
    test('parses simple lcov content', () {
      const content = '''
TN:Test
SF:/path/to/file.dart
DA:1,5
DA:2,3
DA:3,0
LF:3
LH:2
end_of_record
''';

      const parser = LcovParser(title: 'Test Report');
      final data = parser.parseContent(content);

      expect(data.files.length, 1);
      expect(data.testName, 'Test');
      expect(data.totalLinesFound, 3);
      expect(data.totalLinesHit, 2);
    });

    test('parses multiple files', () {
      const content = '''
SF:/path/to/file1.dart
DA:1,1
LF:1
LH:1
end_of_record
SF:/path/to/file2.dart
DA:1,0
LF:1
LH:0
end_of_record
''';

      const parser = LcovParser();
      final data = parser.parseContent(content);

      expect(data.files.length, 2);
      expect(data.files[0].linesHit, 1);
      expect(data.files[1].linesHit, 0);
    });

    test('calculates coverage percentage correctly', () {
      const content = '''
SF:/path/to/file.dart
DA:1,1
DA:2,1
DA:3,1
DA:4,1
DA:5,0
LF:5
LH:4
end_of_record
''';

      const parser = LcovParser();
      final data = parser.parseContent(content);

      expect(data.lineCoveragePercent, 80.0);
      expect(data.status, CoverageStatus.high);
    });

    test('parses function data', () {
      const content = '''
SF:/path/to/file.dart
FN:10,myFunction
FNF:1
FNH:1
LF:5
LH:5
end_of_record
''';

      const parser = LcovParser();
      final data = parser.parseContent(content);

      expect(data.files[0].functionsFound, 1);
      expect(data.files[0].functionsHit, 1);
      expect(data.files[0].functions[10], 'myFunction');
    });
  });

  group('FileCoverage', () {
    test('returns correct status for coverage levels', () {
      expect(
        FileCoverage(
          filePath: '/test',
          relativePath: 'test.dart',
          lines: {},
          linesFound: 100,
          linesHit: 90,
        ).status,
        CoverageStatus.high,
      );

      expect(
        FileCoverage(
          filePath: '/test',
          relativePath: 'test.dart',
          lines: {},
          linesFound: 100,
          linesHit: 60,
        ).status,
        CoverageStatus.medium,
      );

      expect(
        FileCoverage(
          filePath: '/test',
          relativePath: 'test.dart',
          lines: {},
          linesFound: 100,
          linesHit: 30,
        ).status,
        CoverageStatus.low,
      );
    });
  });

  group('LineCoverage', () {
    test('correctly identifies covered lines', () {
      final covered = LineCoverage(lineNumber: 1, hitCount: 5);
      final uncovered = LineCoverage(lineNumber: 2, hitCount: 0);
      final nonExecutable = LineCoverage(lineNumber: 3, hitCount: null);

      expect(covered.isCovered, isTrue);
      expect(covered.isExecutable, isTrue);
      expect(covered.isUncovered, isFalse);

      expect(uncovered.isCovered, isFalse);
      expect(uncovered.isExecutable, isTrue);
      expect(uncovered.isUncovered, isTrue);

      expect(nonExecutable.isCovered, isFalse);
      expect(nonExecutable.isExecutable, isFalse);
      expect(nonExecutable.isUncovered, isFalse);
    });
  });
}
