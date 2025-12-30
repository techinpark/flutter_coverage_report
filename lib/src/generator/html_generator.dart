import 'dart:convert';
import 'dart:io';

import '../models/models.dart';
import '../templates/templates.dart';

/// Generates HTML coverage reports.
class HtmlGenerator {
  /// Base path for reading source files.
  final String? basePath;

  const HtmlGenerator({this.basePath});

  /// Generate an HTML report from coverage data.
  Future<String> generate(CoverageData data) async {
    final sourceFiles = await _loadSourceFiles(data);

    final sidebarContent = _generateSidebar(data);
    final dashboardContent = _generateDashboard(data);
    final dataScript = _generateDataScript(data, sourceFiles);

    return htmlTemplate(
      title: data.title,
      css: cssTemplate,
      js: jsTemplate,
      sidebarContent: sidebarContent,
      dashboardContent: dashboardContent,
      dataScript: dataScript,
      highCount: data.highCoverageCount,
      lowCount: data.lowCoverageCount,
    );
  }

  /// Generate sidebar file tree HTML.
  String _generateSidebar(CoverageData data) {
    final buffer = StringBuffer();
    final tree = _buildFileTree(data.filesSortedByPath);

    _renderTree(buffer, tree, 0);

    return buffer.toString();
  }

  /// Build a tree structure from flat file list.
  Map<String, dynamic> _buildFileTree(List<FileCoverage> files) {
    final tree = <String, dynamic>{};

    for (final file in files) {
      final parts = file.relativePath.split('/');
      var current = tree;

      for (var i = 0; i < parts.length; i++) {
        final part = parts[i];
        final isFile = i == parts.length - 1;

        if (isFile) {
          current[part] = file;
        } else {
          current[part] ??= <String, dynamic>{};
          current = current[part] as Map<String, dynamic>;
        }
      }
    }

    return tree;
  }

  /// Render tree to HTML.
  void _renderTree(StringBuffer buffer, Map<String, dynamic> tree, int depth) {
    final sortedKeys = tree.keys.toList()..sort((a, b) {
      final aIsDir = tree[a] is Map;
      final bIsDir = tree[b] is Map;
      if (aIsDir && !bIsDir) return -1;
      if (!aIsDir && bIsDir) return 1;
      return a.compareTo(b);
    });

    for (final key in sortedKeys) {
      final value = tree[key];

      if (value is FileCoverage) {
        // File
        final status = value.status.name;
        buffer.writeln('''
          <div class="tree-item" data-file="${_escapeHtml(value.relativePath)}" data-name="${_escapeHtml(key)}" data-status="$status">
            <svg class="tree-icon" viewBox="0 0 16 16" fill="currentColor"><path d="M3.75 1.5a.25.25 0 0 0-.25.25v11.5c0 .138.112.25.25.25h8.5a.25.25 0 0 0 .25-.25V6H9.75A1.75 1.75 0 0 1 8 4.25V1.5H3.75ZM9.5 1.62V4.25c0 .138.112.25.25.25h2.63L9.5 1.62ZM2 1.75C2 .784 2.784 0 3.75 0h5.086c.464 0 .909.184 1.237.513l3.414 3.414c.329.328.513.773.513 1.237v8.086A1.75 1.75 0 0 1 12.25 15h-8.5A1.75 1.75 0 0 1 2 13.25V1.75Z"/></svg>
            <span class="tree-name">${_escapeHtml(key)}</span>
            <span class="tree-badge $status">${value.lineCoveragePercent.toStringAsFixed(0)}%</span>
          </div>
        ''');
      } else if (value is Map<String, dynamic>) {
        // Directory
        buffer.writeln('''
          <div class="tree-item folder">
            <svg class="tree-icon" viewBox="0 0 16 16" fill="currentColor"><path d="M1.75 1A1.75 1.75 0 0 0 0 2.75v10.5C0 14.216.784 15 1.75 15h12.5A1.75 1.75 0 0 0 16 13.25v-8.5A1.75 1.75 0 0 0 14.25 3H7.5a.25.25 0 0 1-.2-.1l-.9-1.2C6.07 1.26 5.55 1 5 1H1.75Z"/></svg>
            <span class="tree-name">${_escapeHtml(key)}</span>
          </div>
          <div class="tree-children expanded">
        ''');
        _renderTree(buffer, value, depth + 1);
        buffer.writeln('</div>');
      }
    }
  }

  /// Generate dashboard HTML.
  String _generateDashboard(CoverageData data) {
    final uncoveredList = StringBuffer();
    final lowFiles = data.getLowestCoverageFiles(5)
        .where((f) => f.lineCoveragePercent < 80)
        .toList();

    if (lowFiles.isEmpty) {
      uncoveredList.writeln('''
        <div class="uncovered-item" style="justify-content: center; color: var(--color-success-fg);">
          All files have good coverage!
        </div>
      ''');
    } else {
      for (final file in lowFiles) {
        uncoveredList.writeln('''
              <div class="uncovered-item" data-file="${_escapeHtml(file.relativePath)}">
                <span class="uncovered-path">${_escapeHtml(file.relativePath)}</span>
                <span class="uncovered-percent ${file.status.name}">${file.lineCoveragePercent.toStringAsFixed(1)}%</span>
              </div>
        ''');
      }
    }

    final lineStatus = data.status.name;
    final functionStatus = data.totalFunctionsFound > 0
        ? _getStatus(data.functionCoveragePercent).name
        : 'high';

    return dashboardTemplate(
      title: data.title,
      lineCoverage: data.lineCoveragePercent,
      lineStatus: lineStatus,
      linesHit: data.totalLinesHit,
      linesFound: data.totalLinesFound,
      functionCoverage: data.functionCoveragePercent,
      functionStatus: functionStatus,
      functionsHit: data.totalFunctionsHit,
      functionsFound: data.totalFunctionsFound,
      totalFiles: data.files.length,
      highCount: data.highCoverageCount,
      mediumCount: data.mediumCoverageCount,
      lowCount: data.lowCoverageCount,
      uncoveredList: uncoveredList.toString(),
      generatedAt: _formatDate(data.generatedAt),
    );
  }

  CoverageStatus _getStatus(double percent) {
    if (percent >= 80) return CoverageStatus.high;
    if (percent >= 50) return CoverageStatus.medium;
    return CoverageStatus.low;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Generate JavaScript data script.
  String _generateDataScript(
    CoverageData data,
    Map<String, List<String>> sourceFiles
  ) {
    final filesJson = data.files.map((f) {
      final lines = <String, int>{};
      f.lines.forEach((lineNum, coverage) {
        if (coverage.hitCount != null) {
          lines[lineNum.toString()] = coverage.hitCount!;
        }
      });

      return {
        'relativePath': f.relativePath,
        'percent': f.lineCoveragePercent,
        'status': f.status.name,
        'lines': lines,
        'sourceLines': sourceFiles[f.filePath] ?? sourceFiles[f.relativePath],
      };
    }).toList();

    return 'window.coverageData = ${jsonEncode({'files': filesJson})};';
  }

  /// Load source files for inline display.
  Future<Map<String, List<String>>> _loadSourceFiles(CoverageData data) async {
    final sources = <String, List<String>>{};

    for (final file in data.files) {
      List<String>? lines;

      // Try absolute path
      final absFile = File(file.filePath);
      if (await absFile.exists()) {
        lines = await absFile.readAsLines();
      }

      // Try with base path
      if (lines == null && basePath != null) {
        final relFile = File('$basePath/${file.relativePath}');
        if (await relFile.exists()) {
          lines = await relFile.readAsLines();
        }
      }

      if (lines != null) {
        sources[file.filePath] = lines;
        sources[file.relativePath] = lines;
      }
    }

    return sources;
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}
