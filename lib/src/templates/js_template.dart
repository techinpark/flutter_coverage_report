/// JavaScript template for interactivity.
const String jsTemplate = r'''
(function() {
  // State
  let currentView = 'dashboard';
  let currentFile = null;
  let searchQuery = '';
  let filter = 'all';

  // Initialize
  document.addEventListener('DOMContentLoaded', init);

  function init() {
    initTheme();
    initSearch();
    initFilters();
    initFileTree();
    initBackButton();
    showDashboard();
  }

  // Theme
  function initTheme() {
    const savedTheme = localStorage.getItem('fcr-theme');
    const systemDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    const theme = savedTheme || (systemDark ? 'dark' : 'light');
    setTheme(theme);

    const toggle = document.getElementById('theme-toggle');
    if (toggle) {
      toggle.addEventListener('click', toggleTheme);
    }

    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
      if (!localStorage.getItem('fcr-theme')) {
        setTheme(e.matches ? 'dark' : 'light');
      }
    });
  }

  function setTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    updateThemeIcon(theme);
  }

  function toggleTheme() {
    const current = document.documentElement.getAttribute('data-theme') || 'light';
    const next = current === 'dark' ? 'light' : 'dark';
    setTheme(next);
    localStorage.setItem('fcr-theme', next);
  }

  function updateThemeIcon(theme) {
    const icon = document.getElementById('theme-icon');
    if (!icon) return;

    if (theme === 'dark') {
      icon.innerHTML = '<path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z"/>';
    } else {
      icon.innerHTML = '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41"/>';
    }
  }

  // Search
  function initSearch() {
    const searchBox = document.getElementById('search-box');
    if (!searchBox) return;

    searchBox.addEventListener('input', (e) => {
      searchQuery = e.target.value.toLowerCase();
      filterTree();
    });
  }

  // Filters
  function initFilters() {
    const buttons = document.querySelectorAll('.filter-btn');
    buttons.forEach(btn => {
      btn.addEventListener('click', () => {
        buttons.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        filter = btn.dataset.filter;
        filterTree();
      });
    });
  }

  function filterTree() {
    const items = document.querySelectorAll('.tree-item[data-file]');
    items.forEach(item => {
      const name = item.dataset.name?.toLowerCase() || '';
      const status = item.dataset.status;

      let visible = true;

      if (searchQuery && !name.includes(searchQuery)) {
        visible = false;
      }

      if (filter !== 'all' && status !== filter) {
        visible = false;
      }

      item.style.display = visible ? '' : 'none';
    });

    // Update folder visibility based on children
    updateFolderVisibility();
  }

  function updateFolderVisibility() {
    const folders = document.querySelectorAll('.tree-item.folder');
    folders.forEach(folder => {
      const children = folder.nextElementSibling;
      if (children && children.classList.contains('tree-children')) {
        const visibleItems = children.querySelectorAll('.tree-item[data-file]:not([style*="display: none"])');
        folder.style.display = visibleItems.length > 0 ? '' : 'none';
      }
    });
  }

  // File Tree
  function initFileTree() {
    const folderIconOpen = '<path d="M.513 1.513A1.75 1.75 0 0 1 1.75 1h3.5c.55 0 1.07.26 1.4.7l.9 1.2a.25.25 0 0 0 .2.1H14a1 1 0 0 1 1 1v.5H2.75a.75.75 0 0 0 0 1.5h12.5a.75.75 0 0 1 .734.9l-1.276 5.85A1.75 1.75 0 0 1 13.0 15H1.75A1.75 1.75 0 0 1 0 13.25V2.75c0-.464.184-.909.513-1.237Z"/>';
    const folderIconClosed = '<path d="M1.75 1A1.75 1.75 0 0 0 0 2.75v10.5C0 14.216.784 15 1.75 15h12.5A1.75 1.75 0 0 0 16 13.25v-8.5A1.75 1.75 0 0 0 14.25 3H7.5a.25.25 0 0 1-.2-.1l-.9-1.2C6.07 1.26 5.55 1 5 1H1.75Z"/>';

    const folders = document.querySelectorAll('.tree-item.folder');
    folders.forEach(folder => {
      folder.addEventListener('click', (e) => {
        e.stopPropagation();
        const children = folder.nextElementSibling;
        if (children && children.classList.contains('tree-children')) {
          children.classList.toggle('expanded');
          const icon = folder.querySelector('.tree-icon');
          if (icon) {
            icon.innerHTML = children.classList.contains('expanded') ? folderIconOpen : folderIconClosed;
          }
        }
      });
    });

    const files = document.querySelectorAll('.tree-item[data-file]');
    files.forEach(file => {
      file.addEventListener('click', (e) => {
        e.stopPropagation();
        showFile(file.dataset.file);
      });
    });

    const uncoveredItems = document.querySelectorAll('.uncovered-item');
    uncoveredItems.forEach(item => {
      item.addEventListener('click', () => {
        showFile(item.dataset.file);
      });
    });
  }

  // Navigation
  function showDashboard() {
    currentView = 'dashboard';
    currentFile = null;
    document.getElementById('dashboard-view').style.display = 'block';
    document.getElementById('code-view').style.display = 'none';
    updateSelection();
  }

  function showFile(filePath) {
    currentView = 'file';
    currentFile = filePath;

    const dashboard = document.getElementById('dashboard-view');
    const codeView = document.getElementById('code-view');

    if (dashboard) dashboard.style.display = 'none';
    if (codeView) codeView.style.display = 'block';

    // Find file data
    const fileData = window.coverageData.files.find(f => f.relativePath === filePath);
    if (!fileData) return;

    // Update header
    document.getElementById('code-path').textContent = filePath;
    const badge = document.getElementById('code-badge');
    badge.textContent = fileData.percent.toFixed(1) + '%';
    badge.className = 'code-coverage-badge ' + fileData.status;

    // Update code
    const codeContent = document.getElementById('code-content');
    codeContent.innerHTML = generateCodeTable(fileData);

    updateSelection();
  }

  function generateCodeTable(fileData) {
    if (!fileData.sourceLines) {
      return '<div style="padding: 20px; color: var(--color-fg-muted);">Source code not available</div>';
    }

    let html = '<table class="code-table">';
    fileData.sourceLines.forEach((line, index) => {
      const lineNum = index + 1;
      const coverage = fileData.lines[lineNum];

      let lineClass = 'code-line';
      let hitsClass = 'line-hits';
      let hitsText = '';

      if (coverage !== undefined) {
        if (coverage > 0) {
          lineClass += ' covered';
          hitsClass += ' covered';
          hitsText = coverage + 'x';
        } else {
          lineClass += ' uncovered';
          hitsClass += ' uncovered';
          hitsText = '0x';
        }
      }

      html += `<tr class="${lineClass}">`;
      html += `<td class="line-number">${lineNum}</td>`;
      html += `<td class="${hitsClass}">${hitsText}</td>`;
      html += `<td class="line-code">${escapeHtml(line)}</td>`;
      html += '</tr>';
    });
    html += '</table>';
    return html;
  }

  function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  function updateSelection() {
    document.querySelectorAll('.tree-item').forEach(item => {
      item.classList.remove('selected');
    });

    if (currentFile) {
      const selected = document.querySelector(`.tree-item[data-file="${currentFile}"]`);
      if (selected) {
        selected.classList.add('selected');
        expandParents(selected);
      }
    }
  }

  function expandParents(element) {
    let parent = element.parentElement;
    while (parent) {
      if (parent.classList.contains('tree-children')) {
        parent.classList.add('expanded');
      }
      parent = parent.parentElement;
    }
  }

  // Back button
  function initBackButton() {
    const backBtn = document.getElementById('back-btn');
    if (backBtn) {
      backBtn.addEventListener('click', showDashboard);
    }
  }

  // Mobile menu
  window.toggleSidebar = function() {
    const sidebar = document.querySelector('.sidebar');
    if (sidebar) {
      sidebar.classList.toggle('open');
    }
  };
})();
''';
