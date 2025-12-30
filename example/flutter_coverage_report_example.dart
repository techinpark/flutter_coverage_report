import 'dart:io';

import 'package:flutter_coverage_report/flutter_coverage_report.dart';

void main() async {
  // Parse lcov.info
  const parser = LcovParser(title: 'My Coverage Report');
  final data = await parser.parse('coverage/lcov.info');

  print('Coverage: ${data.lineCoveragePercent.toStringAsFixed(1)}%');
  print('Files: ${data.files.length}');

  // Generate HTML report
  const generator = HtmlGenerator();
  final html = await generator.generate(data);

  // Write to file
  await File('coverage/report.html').writeAsString(html);
  print('Report generated: coverage/report.html');
}
