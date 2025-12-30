import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_coverage_report/flutter_coverage_report.dart';

const String version = '1.0.0';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'output',
      abbr: 'o',
      help: 'Output HTML file path',
      defaultsTo: 'coverage/coverage-report.html',
    )
    ..addOption(
      'title',
      abbr: 't',
      help: 'Report title',
      defaultsTo: 'Coverage Report',
    )
    ..addOption(
      'base-path',
      abbr: 'b',
      help: 'Base path for source files',
    )
    ..addFlag(
      'open',
      help: 'Open report in browser after generation',
      negatable: false,
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show this help message',
      negatable: false,
    )
    ..addFlag(
      'version',
      abbr: 'v',
      help: 'Show version number',
      negatable: false,
    );

  try {
    final results = parser.parse(arguments);

    if (results['version'] as bool) {
      print('flutter_coverage_report version $version');
      return;
    }

    if (results['help'] as bool || results.rest.isEmpty) {
      _printUsage(parser);
      return;
    }

    final inputPath = results.rest.first;
    final outputPath = results['output'] as String;
    final title = results['title'] as String;
    final basePath = results['base-path'] as String?;
    final openBrowser = results['open'] as bool;

    // Validate input file
    final inputFile = File(inputPath);
    if (!await inputFile.exists()) {
      stderr.writeln('Error: Input file not found: $inputPath');
      exit(1);
    }

    print('📊 Flutter Coverage Report Generator');
    print('');
    print('Input:  $inputPath');
    print('Output: $outputPath');
    print('');

    // Parse lcov.info
    print('Parsing coverage data...');
    final parser2 = LcovParser(
      basePath: basePath ?? _inferBasePath(inputPath),
      title: title,
    );
    final coverageData = await parser2.parse(inputPath);

    print('Found ${coverageData.files.length} files');
    print('Overall coverage: ${coverageData.lineCoveragePercent.toStringAsFixed(1)}%');
    print('');

    // Generate HTML
    print('Generating HTML report...');
    final generator = HtmlGenerator(
      basePath: basePath ?? _inferBasePath(inputPath),
    );
    final html = await generator.generate(coverageData);

    // Write output
    final outputFile = File(outputPath);
    await outputFile.parent.create(recursive: true);
    await outputFile.writeAsString(html);

    print('✓ Report generated: $outputPath');
    print('');

    // Summary
    _printSummary(coverageData);

    // Open in browser
    if (openBrowser) {
      print('');
      print('Opening in browser...');
      await _openInBrowser(outputPath);
    }
  } catch (e) {
    if (e is FormatException) {
      stderr.writeln('Error: ${e.message}');
      _printUsage(parser);
      exit(1);
    }
    stderr.writeln('Error: $e');
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  print('Usage: fcr <lcov.info> [options]');
  print('');
  print('Generate Playwright-style HTML coverage reports from lcov.info files.');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('Examples:');
  print('  fcr coverage/lcov.info');
  print('  fcr coverage/lcov.info -o report.html --open');
  print('  fcr coverage/lcov.info --title "My App" --base-path /path/to/project');
  print('');
  print('Tip: Run with Flutter:');
  print('  flutter test --coverage && fcr coverage/lcov.info --open');
}

void _printSummary(CoverageData data) {
  final status = data.status;
  final emoji = switch (status) {
    CoverageStatus.high => '🟢',
    CoverageStatus.medium => '🟡',
    CoverageStatus.low => '🔴',
  };

  print('Summary:');
  print('  $emoji Line Coverage:     ${data.lineCoveragePercent.toStringAsFixed(1)}% (${data.totalLinesHit}/${data.totalLinesFound})');

  if (data.totalFunctionsFound > 0) {
    print('  📦 Function Coverage:  ${data.functionCoveragePercent.toStringAsFixed(1)}% (${data.totalFunctionsHit}/${data.totalFunctionsFound})');
  }

  print('  📁 Files:              ${data.files.length}');
  print('     - High (80%+):      ${data.highCoverageCount}');
  print('     - Medium (50-79%):  ${data.mediumCoverageCount}');
  print('     - Low (<50%):       ${data.lowCoverageCount}');
}

String? _inferBasePath(String inputPath) {
  // Try to find project root from lcov.info path
  // Typically: /path/to/project/coverage/lcov.info
  final parts = inputPath.split('/');
  final coverageIndex = parts.indexOf('coverage');
  if (coverageIndex > 0) {
    return parts.sublist(0, coverageIndex).join('/');
  }
  return null;
}

Future<void> _openInBrowser(String path) async {
  final absolutePath = File(path).absolute.path;
  final uri = 'file://$absolutePath';

  if (Platform.isMacOS) {
    await Process.run('open', [uri]);
  } else if (Platform.isLinux) {
    await Process.run('xdg-open', [uri]);
  } else if (Platform.isWindows) {
    await Process.run('start', [uri], runInShell: true);
  }
}
