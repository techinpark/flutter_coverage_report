/// HTML template with Playwright-style layout.
String htmlTemplate({
  required String title,
  required String css,
  required String js,
  required String sidebarContent,
  required String dashboardContent,
  required String dataScript,
  required int highCount,
  required int lowCount,
}) {
  return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$title</title>
  <style>
$css
  </style>
</head>
<body>
  <div class="container">
    <!-- Header -->
    <header class="header">
      <div class="header-left">
        <button class="menu-toggle" onclick="toggleSidebar()" aria-label="Toggle menu">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M3 12h18M3 6h18M3 18h18"/>
          </svg>
        </button>
        <span class="logo">$title</span>
      </div>
      <div class="header-right">
        <div class="summary-badges">
          <span class="summary-badge high">✓ $highCount high</span>
          <span class="summary-badge low">✗ $lowCount low</span>
        </div>
        <button id="theme-toggle" class="theme-toggle" aria-label="Toggle theme">
          <svg id="theme-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="12" cy="12" r="4"/>
            <path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41"/>
          </svg>
        </button>
      </div>
    </header>

    <div class="content">
      <!-- Sidebar -->
      <aside class="sidebar">
        <div class="sidebar-header">
          <input type="text" id="search-box" class="search-box" placeholder="Search files...">
        </div>
        <div class="sidebar-content">
$sidebarContent
        </div>
        <div class="sidebar-footer">
          <div class="filter-buttons">
            <button class="filter-btn active" data-filter="all">All</button>
            <button class="filter-btn" data-filter="high">High</button>
            <button class="filter-btn" data-filter="medium">Medium</button>
            <button class="filter-btn" data-filter="low">Low</button>
          </div>
        </div>
      </aside>

      <!-- Main content -->
      <main class="main">
        <!-- Dashboard view -->
        <div id="dashboard-view">
$dashboardContent
        </div>

        <!-- Code view (hidden initially) -->
        <div id="code-view" style="display: none;">
          <button id="back-btn" class="back-btn">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M19 12H5M12 19l-7-7 7-7"/>
            </svg>
            Back to Dashboard
          </button>
          <div class="code-view">
            <div class="code-header">
              <span id="code-path" class="code-path"></span>
              <div class="code-coverage">
                <span id="code-badge" class="code-coverage-badge"></span>
              </div>
            </div>
            <div id="code-content" class="code-content">
            </div>
          </div>
        </div>
      </main>
    </div>
  </div>

  <script>
$dataScript
  </script>
  <script>
$js
  </script>
</body>
</html>
''';
}

/// Generate dashboard HTML content.
String dashboardTemplate({
  required String title,
  required double lineCoverage,
  required String lineStatus,
  required int linesHit,
  required int linesFound,
  required double functionCoverage,
  required String functionStatus,
  required int functionsHit,
  required int functionsFound,
  required int totalFiles,
  required int highCount,
  required int mediumCount,
  required int lowCount,
  required String uncoveredList,
  required String generatedAt,
}) {
  return '''
          <div class="dashboard">
            <div class="dashboard-header">
              <h1 class="dashboard-title">Coverage Dashboard</h1>
              <p class="dashboard-subtitle">Generated on $generatedAt</p>
            </div>

            <div class="stats-grid">
              <div class="stat-card">
                <div class="stat-label">Line Coverage</div>
                <div class="stat-value $lineStatus">${lineCoverage.toStringAsFixed(1)}%</div>
                <div class="progress-bar">
                  <div class="progress-fill $lineStatus" style="width: ${lineCoverage.clamp(0, 100)}%"></div>
                </div>
                <div style="margin-top: 8px; color: var(--color-fg-muted); font-size: 12px;">
                  $linesHit / $linesFound lines
                </div>
              </div>

              <div class="stat-card">
                <div class="stat-label">Function Coverage</div>
                <div class="stat-value $functionStatus">${functionCoverage.toStringAsFixed(1)}%</div>
                <div class="progress-bar">
                  <div class="progress-fill $functionStatus" style="width: ${functionCoverage.clamp(0, 100)}%"></div>
                </div>
                <div style="margin-top: 8px; color: var(--color-fg-muted); font-size: 12px;">
                  $functionsHit / $functionsFound functions
                </div>
              </div>

              <div class="stat-card">
                <div class="stat-label">Files</div>
                <div class="stat-value">$totalFiles</div>
                <div style="margin-top: 8px; color: var(--color-fg-muted); font-size: 12px;">
                  <span style="color: var(--color-success-fg);">$highCount high</span> ·
                  <span style="color: var(--color-warning-fg);">$mediumCount med</span> ·
                  <span style="color: var(--color-danger-fg);">$lowCount low</span>
                </div>
              </div>
            </div>

            <h2 style="font-size: 16px; font-weight: 600; margin-bottom: 12px;">Files with Low Coverage</h2>
            <div class="uncovered-list">
$uncoveredList
            </div>
          </div>
''';
}
