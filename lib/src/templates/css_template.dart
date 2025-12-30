/// CSS template with GitHub Primer design system colors.
const String cssTemplate = r'''
:root {
  /* Light theme - GitHub Primer colors */
  --color-fg-default: #1f2328;
  --color-fg-muted: #59636e;
  --color-fg-subtle: #6e7781;
  --color-fg-accent: #0969da;

  --color-bg-default: #ffffff;
  --color-bg-subtle: #f6f8fa;
  --color-bg-muted: #eaeef2;
  --color-bg-inset: #eff2f5;

  --color-border-default: #d1d9e0;
  --color-border-muted: #d8dee4;

  /* Status colors */
  --color-success-fg: #1a7f37;
  --color-success-bg: #dafbe1;
  --color-success-emphasis: #1f883d;

  --color-warning-fg: #9a6700;
  --color-warning-bg: #fff8c5;
  --color-warning-emphasis: #bf8700;

  --color-danger-fg: #d1242f;
  --color-danger-bg: #ffebe9;
  --color-danger-emphasis: #cf222e;

  /* Coverage specific */
  --color-covered-bg: #dafbe1;
  --color-covered-border: #aceebb;
  --color-uncovered-bg: #ffebe9;
  --color-uncovered-border: #ffcecb;

  /* Sizes */
  --sidebar-width: 280px;
  --header-height: 60px;
  --code-font: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, monospace;
}

[data-theme="dark"] {
  --color-fg-default: #e6edf3;
  --color-fg-muted: #8b949e;
  --color-fg-subtle: #6e7681;
  --color-fg-accent: #58a6ff;

  --color-bg-default: #0d1117;
  --color-bg-subtle: #161b22;
  --color-bg-muted: #21262d;
  --color-bg-inset: #010409;

  --color-border-default: #30363d;
  --color-border-muted: #21262d;

  --color-success-fg: #3fb950;
  --color-success-bg: #0d1f17;
  --color-success-emphasis: #238636;

  --color-warning-fg: #d29922;
  --color-warning-bg: #1e1b0f;
  --color-warning-emphasis: #9e6a03;

  --color-danger-fg: #f85149;
  --color-danger-bg: #1f0c0c;
  --color-danger-emphasis: #da3633;

  --color-covered-bg: #0d1f17;
  --color-covered-border: #1b4721;
  --color-uncovered-bg: #1f0c0c;
  --color-uncovered-border: #5c2627;
}

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Noto Sans", Helvetica, Arial, sans-serif;
  font-size: 14px;
  line-height: 1.5;
  color: var(--color-fg-default);
  background-color: var(--color-bg-default);
}

/* Layout */
.container {
  display: flex;
  flex-direction: column;
  height: 100vh;
}

.header {
  height: var(--header-height);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  border-bottom: 1px solid var(--color-border-default);
  background-color: var(--color-bg-subtle);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo {
  font-size: 18px;
  font-weight: 600;
}

.content {
  display: flex;
  flex: 1;
  overflow: hidden;
}

.sidebar {
  width: var(--sidebar-width);
  border-right: 1px solid var(--color-border-default);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.sidebar-header {
  padding: 12px;
  border-bottom: 1px solid var(--color-border-default);
}

.search-box {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid var(--color-border-default);
  border-radius: 6px;
  background-color: var(--color-bg-default);
  color: var(--color-fg-default);
  font-size: 14px;
}

.search-box:focus {
  outline: none;
  border-color: var(--color-fg-accent);
  box-shadow: 0 0 0 3px rgba(9, 105, 218, 0.3);
}

.sidebar-content {
  flex: 1;
  overflow-y: auto;
  padding: 8px 0;
}

.sidebar-footer {
  padding: 12px;
  border-top: 1px solid var(--color-border-default);
}

.filter-buttons {
  display: flex;
  gap: 4px;
  flex-wrap: wrap;
}

.filter-btn {
  padding: 4px 8px;
  border: 1px solid var(--color-border-default);
  border-radius: 4px;
  background-color: var(--color-bg-default);
  color: var(--color-fg-muted);
  font-size: 12px;
  cursor: pointer;
  transition: all 0.15s ease;
}

.filter-btn:hover {
  background-color: var(--color-bg-subtle);
}

.filter-btn.active {
  background-color: var(--color-fg-accent);
  color: white;
  border-color: var(--color-fg-accent);
}

.main {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
}

/* File tree */
.tree-item {
  display: flex;
  align-items: center;
  padding: 6px 12px;
  cursor: pointer;
  transition: background-color 0.1s ease;
}

.tree-item:hover {
  background-color: var(--color-bg-subtle);
}

.tree-item.selected {
  background-color: var(--color-bg-muted);
}

.tree-item.folder {
  font-weight: 500;
}

.tree-icon {
  width: 16px;
  height: 16px;
  margin-right: 8px;
  flex-shrink: 0;
  color: var(--color-fg-muted);
}

.tree-item.folder .tree-icon {
  color: var(--color-fg-accent);
}

.tree-name {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.tree-badge {
  padding: 2px 6px;
  border-radius: 10px;
  font-size: 11px;
  font-weight: 500;
  margin-left: 8px;
}

.tree-badge.high {
  background-color: var(--color-success-bg);
  color: var(--color-success-fg);
}

.tree-badge.medium {
  background-color: var(--color-warning-bg);
  color: var(--color-warning-fg);
}

.tree-badge.low {
  background-color: var(--color-danger-bg);
  color: var(--color-danger-fg);
}

.tree-children {
  padding-left: 20px;
  display: none;
}

.tree-children.expanded {
  display: block;
}

/* Dashboard */
.dashboard {
  max-width: 900px;
}

.dashboard-header {
  margin-bottom: 24px;
}

.dashboard-title {
  font-size: 24px;
  font-weight: 600;
  margin-bottom: 8px;
}

.dashboard-subtitle {
  color: var(--color-fg-muted);
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.stat-card {
  padding: 16px;
  border: 1px solid var(--color-border-default);
  border-radius: 8px;
  background-color: var(--color-bg-subtle);
}

.stat-label {
  font-size: 12px;
  color: var(--color-fg-muted);
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: 4px;
}

.stat-value {
  font-size: 28px;
  font-weight: 600;
}

.stat-value.high { color: var(--color-success-fg); }
.stat-value.medium { color: var(--color-warning-fg); }
.stat-value.low { color: var(--color-danger-fg); }

/* Progress bar */
.progress-bar {
  height: 8px;
  background-color: var(--color-bg-muted);
  border-radius: 4px;
  overflow: hidden;
  margin-top: 8px;
}

.progress-fill {
  height: 100%;
  border-radius: 4px;
  transition: width 0.3s ease;
}

.progress-fill.high { background-color: var(--color-success-emphasis); }
.progress-fill.medium { background-color: var(--color-warning-emphasis); }
.progress-fill.low { background-color: var(--color-danger-emphasis); }

/* Top uncovered files */
.uncovered-list {
  border: 1px solid var(--color-border-default);
  border-radius: 8px;
  overflow: hidden;
}

.uncovered-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  border-bottom: 1px solid var(--color-border-default);
  cursor: pointer;
  transition: background-color 0.1s ease;
}

.uncovered-item:last-child {
  border-bottom: none;
}

.uncovered-item:hover {
  background-color: var(--color-bg-subtle);
}

.uncovered-path {
  font-family: var(--code-font);
  font-size: 13px;
}

.uncovered-percent {
  font-weight: 500;
}

.uncovered-percent.low {
  color: var(--color-danger-fg);
}

/* Code view */
.code-view {
  max-width: 100%;
}

.code-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  background-color: var(--color-bg-subtle);
  border: 1px solid var(--color-border-default);
  border-radius: 8px 8px 0 0;
}

.code-path {
  font-family: var(--code-font);
  font-size: 14px;
  font-weight: 500;
}

.code-coverage {
  display: flex;
  align-items: center;
  gap: 8px;
}

.code-coverage-badge {
  padding: 4px 10px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.code-coverage-badge.high {
  background-color: var(--color-success-bg);
  color: var(--color-success-fg);
}

.code-coverage-badge.medium {
  background-color: var(--color-warning-bg);
  color: var(--color-warning-fg);
}

.code-coverage-badge.low {
  background-color: var(--color-danger-bg);
  color: var(--color-danger-fg);
}

.code-content {
  border: 1px solid var(--color-border-default);
  border-top: none;
  border-radius: 0 0 8px 8px;
  overflow-x: auto;
}

.code-table {
  width: 100%;
  border-collapse: collapse;
  font-family: var(--code-font);
  font-size: 13px;
  line-height: 1.4;
}

.code-line {
  height: 22px;
}

.code-line:hover {
  background-color: var(--color-bg-subtle);
}

.code-line.covered {
  background-color: var(--color-covered-bg);
}

.code-line.uncovered {
  background-color: var(--color-uncovered-bg);
}

.line-number {
  width: 50px;
  text-align: right;
  padding: 0 12px;
  color: var(--color-fg-subtle);
  user-select: none;
  border-right: 1px solid var(--color-border-default);
}

.line-hits {
  width: 60px;
  text-align: center;
  padding: 0 8px;
  color: var(--color-fg-muted);
  border-right: 1px solid var(--color-border-default);
}

.line-hits.covered {
  color: var(--color-success-fg);
}

.line-hits.uncovered {
  color: var(--color-danger-fg);
}

.line-code {
  padding: 0 12px;
  white-space: pre;
}

/* Theme toggle */
.theme-toggle {
  width: 36px;
  height: 36px;
  border: 1px solid var(--color-border-default);
  border-radius: 6px;
  background-color: var(--color-bg-default);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background-color 0.1s ease;
}

.theme-toggle:hover {
  background-color: var(--color-bg-subtle);
}

.theme-toggle svg {
  width: 20px;
  height: 20px;
  fill: var(--color-fg-default);
}

/* Summary badges */
.summary-badges {
  display: flex;
  gap: 8px;
}

.summary-badge {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.summary-badge.high {
  background-color: var(--color-success-bg);
  color: var(--color-success-fg);
}

.summary-badge.low {
  background-color: var(--color-danger-bg);
  color: var(--color-danger-fg);
}

/* Responsive */
@media (max-width: 768px) {
  .sidebar {
    position: fixed;
    left: -280px;
    top: var(--header-height);
    height: calc(100vh - var(--header-height));
    z-index: 100;
    background-color: var(--color-bg-default);
    transition: left 0.2s ease;
  }

  .sidebar.open {
    left: 0;
  }

  .menu-toggle {
    display: block;
  }
}

@media (min-width: 769px) {
  .menu-toggle {
    display: none;
  }
}

/* Back button */
.back-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  border: 1px solid var(--color-border-default);
  border-radius: 6px;
  background-color: var(--color-bg-default);
  color: var(--color-fg-default);
  font-size: 14px;
  cursor: pointer;
  transition: background-color 0.1s ease;
  margin-bottom: 16px;
}

.back-btn:hover {
  background-color: var(--color-bg-subtle);
}
''';
