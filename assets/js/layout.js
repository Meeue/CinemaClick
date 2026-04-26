/* layout.js — shared shell injected on every page */

/* ── theme bootstrap (runs before paint) ── */
(function(){
  var saved = localStorage.getItem('cinema-theme') || 'dark';
  document.documentElement.setAttribute('data-theme', saved);
})();

/* ── page definitions (updated to .php) ── */
var PAGES = [
  {key:'dashboard',  href:'dashboard.php',  icon:'▦',  label:'Dashboard',  section:'Main'},
  {key:'movies',     href:'movies.php',     icon:'🎞', label:'Movies'},
  {key:'showtimes',  href:'showtimes.php',  icon:'🗓', label:'Showtimes'},
  {key:'bookings',   href:'bookings.php',   icon:'🎟', label:'Bookings'},
  {key:'cinemas',    href:'cinemas.php',    icon:'🏛', label:'Cinemas',    section:'Venue'},
  {key:'screens',    href:'screens.php',    icon:'📺', label:'Screens'},
  {key:'seats',      href:'seats.php',      icon:'💺', label:'Seats'},
  {key:'payments',   href:'payments.php',   icon:'💳', label:'Payments',   section:'Finance'},
  {key:'customers',  href:'customers.php',  icon:'👤', label:'Customers',  section:'System'},
  {key:'tickets',    href:'tickets.php',    icon:'🎫', label:'Tickets'},
  {key:'audit_logs', href:'audit_logs.php', icon:'📋', label:'Audit Logs'},
];

function buildSidebar(activeKey){
  var nav = '';
  PAGES.forEach(function(p){
    if(p.section) nav += '<div class="nav-section">'+p.section+'</div>';
    var cls = 'nav-item' + (p.key === activeKey ? ' active' : '');
    nav += '<a class="'+cls+'" href="'+p.href+'"><span class="nav-icon">'+p.icon+'</span> '+p.label+'</a>';
  });
  return [
    '<div class="sidebar">',
    '  <div class="sidebar-logo">',
    '    <div class="logo-mark">',
    '      <div class="logo-icon">🎬</div>',
    '      <div>',
    '        <div class="logo-text">CineAdmin</div>',
    '        <div class="logo-sub">Admin Portal</div>',
    '      </div>',
    '    </div>',
    '  </div>',
    '  <div class="nav">'+nav+'</div>',
    '  <div style="padding:14px 16px;border-top:1px solid var(--border);">',
    '    <a href="profile.php" style="display:flex;align-items:center;gap:10px;padding:8px 10px;border-radius:8px;text-decoration:none;transition:background .15s;" onmouseover="this.style.background=\'var(--accent-dim)\'" onmouseout="this.style.background=\'transparent\'">',
    '      <div style="width:30px;height:30px;border-radius:50%;background:var(--accent);color:#fff;display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:700;flex-shrink:0;" id="sidebarAvatar">JD</div>',
    '      <div style="min-width:0;">',
    '        <div style="font-size:12px;font-weight:600;color:var(--text);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;" id="sidebarName">Juan Dela Cruz</div>',
    '        <div style="font-size:10px;color:var(--text-muted);">Administrator</div>',
    '      </div>',
    '    </a>',
    '  </div>',
    '</div>',
  ].join('');
}

function buildTopbar(title, sub, actionLabel){
  var theme = document.documentElement.getAttribute('data-theme') || 'dark';
  var toggleIcon  = theme === 'dark' ? '☀️' : '🌙';
  var toggleTitle = theme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode';
  var btn = actionLabel
    ? '<button class="btn btn-primary" id="topbarAction">'+actionLabel+'</button>'
    : '';
  return [
    '<div class="topbar">',
    '  <div class="topbar-left">',
    '    <div class="page-title">'+title+'</div>',
    '    <div class="breadcrumb">'+sub+'</div>',
    '  </div>',
    '  <div class="topbar-right">',
    '    '+btn,
    '    <button class="theme-toggle" id="themeToggle" title="'+toggleTitle+'">'+toggleIcon+'</button>',
    '    <a href="profile.php" class="avatar" title="My Profile" id="topbarAvatar">JD</a>',
    '  </div>',
    '</div>',
  ].join('');
}

var SHARED_MODALS = [
  '<div class="modal-overlay" id="viewModal">',
  '  <div class="modal">',
  '    <div class="modal-header"><div class="modal-title" id="vwTitle">Details</div><button class="modal-close" onclick="CM(\'viewModal\')">✕</button></div>',
  '    <div class="modal-body"><div class="view-grid" id="vwBody"></div></div>',
  '    <div class="modal-footer"><button class="btn btn-ghost" onclick="CM(\'viewModal\')">Close</button><button class="btn btn-primary" id="vwEditBtn" style="display:none">Edit</button></div>',
  '  </div>',
  '</div>',
].join('');

window.injectLayout = function(cfg){
  var app = document.getElementById('app');
  app.innerHTML =
    buildSidebar(cfg.page) +
    '<div class="main">' +
      buildTopbar(cfg.title, cfg.sub || '', cfg.actionLabel || null) +
      '<div class="content" id="pageContent"></div>' +
    '</div>' +
    SHARED_MODALS;

  document.getElementById('themeToggle').addEventListener('click', toggleTheme);

  // Sync sidebar name/avatar from localStorage if profile was set
  var pName = localStorage.getItem('cinema-profile-name');
  var pInitials = localStorage.getItem('cinema-profile-initials');
  if(pName){
    var sn = document.getElementById('sidebarName');
    if(sn) sn.textContent = pName;
  }
  if(pInitials){
    var sa = document.getElementById('sidebarAvatar');
    var ta = document.getElementById('topbarAvatar');
    if(sa) sa.textContent = pInitials;
    if(ta) ta.textContent = pInitials;
  }
};

function toggleTheme(){
  var current = document.documentElement.getAttribute('data-theme') || 'dark';
  var next = current === 'dark' ? 'light' : 'dark';
  document.documentElement.setAttribute('data-theme', next);
  localStorage.setItem('cinema-theme', next);
  var btn = document.getElementById('themeToggle');
  if(btn){
    btn.textContent  = next === 'dark' ? '☀️' : '🌙';
    btn.title        = next === 'dark' ? 'Switch to light mode' : 'Switch to dark mode';
  }
}

/* ── modal helpers ── */
function OM(id){ document.getElementById(id).classList.add('open'); }
function CM(id){ document.getElementById(id).classList.remove('open'); }

/* ── centered delete confirm modal (replaces browser confirm) ── */
function showDelete(title, name, onConfirm){
  var overlay = document.createElement('div');
  overlay.className = 'modal-overlay';
  overlay.innerHTML =
    '<div class="modal modal-sm">'+
      '<div class="modal-header">'+
        '<div class="modal-title">'+title+'</div>'+
        '<button class="modal-close" onclick="this.closest(\'.modal-overlay\').remove()">✕</button>'+
      '</div>'+
      '<div class="modal-body" style="padding:28px 22px;text-align:center">'+
        '<div class="confirm-icon">🗑️</div>'+
        '<div class="confirm-msg">Are you sure you want to delete <span class="confirm-name">'+name+'</span>?<br>This action cannot be undone.</div>'+
      '</div>'+
      '<div class="modal-footer">'+
        '<button class="btn btn-ghost" onclick="this.closest(\'.modal-overlay\').remove()">Cancel</button>'+
        '<button class="btn btn-danger" id="confirmDelBtn">Delete</button>'+
      '</div>'+
    '</div>';
  document.body.appendChild(overlay);
  requestAnimationFrame(function(){ overlay.classList.add('open'); });
  overlay.addEventListener('click', function(e){ if(e.target===overlay) overlay.remove(); });
  overlay.querySelector('#confirmDelBtn').addEventListener('click', function(){
    overlay.remove(); onConfirm();
  });
}

/* ── centered update confirm modal ── */
function showUpdateConfirm(title, name, onConfirm){
  var overlay = document.createElement('div');
  overlay.className = 'modal-overlay';
  overlay.innerHTML =
    '<div class="modal modal-sm">'+
      '<div class="modal-header">'+
        '<div class="modal-title">'+title+'</div>'+
        '<button class="modal-close" onclick="this.closest(\'.modal-overlay\').remove()">✕</button>'+
      '</div>'+
      '<div class="modal-body" style="padding:28px 22px;text-align:center">'+
        '<div class="confirm-icon">✏️</div>'+
        '<div class="confirm-msg">Save changes to <span class="confirm-name">'+name+'</span>?</div>'+
      '</div>'+
      '<div class="modal-footer">'+
        '<button class="btn btn-ghost" onclick="this.closest(\'.modal-overlay\').remove()">Cancel</button>'+
        '<button class="btn btn-primary" id="confirmUpdBtn">Save Changes</button>'+
      '</div>'+
    '</div>';
  document.body.appendChild(overlay);
  requestAnimationFrame(function(){ overlay.classList.add('open'); });
  overlay.addEventListener('click', function(e){ if(e.target===overlay) overlay.remove(); });
  overlay.querySelector('#confirmUpdBtn').addEventListener('click', function(){
    overlay.remove(); onConfirm();
  });
}

/* ── view detail modal ── */
function showView(title, bodyHtml, onEdit){
  var overlay = document.createElement('div');
  overlay.className = 'modal-overlay';
  overlay.innerHTML =
    '<div class="modal" style="width:480px">'+
      '<div class="modal-header">'+
        '<div class="modal-title">'+title+'</div>'+
        '<button class="modal-close" onclick="this.closest(\'.modal-overlay\').remove()">✕</button>'+
      '</div>'+
      '<div class="modal-body"><div class="view-grid">'+bodyHtml+'</div></div>'+
      '<div class="modal-footer">'+
        '<button class="btn btn-ghost" onclick="this.closest(\'.modal-overlay\').remove()">Close</button>'+
        (onEdit ? '<button class="btn btn-primary" id="viewEditBtn">Edit</button>' : '')+
      '</div>'+
    '</div>';
  document.body.appendChild(overlay);
  requestAnimationFrame(function(){ overlay.classList.add('open'); });
  overlay.addEventListener('click', function(e){ if(e.target===overlay) overlay.remove(); });
  if(onEdit){
    overlay.querySelector('#viewEditBtn').addEventListener('click', function(){
      overlay.remove(); onEdit();
    });
  }
}

/* ── toast ── */
function showToast(msg, type){
  type = type || 'success';
  var t = document.createElement('div');
  t.style.cssText = 'position:fixed;bottom:24px;right:24px;z-index:9999;padding:10px 18px;border-radius:8px;font-size:13px;font-weight:500;color:#fff;animation:fadeIn .25s ease;box-shadow:0 4px 16px rgba(0,0,0,.3);';
  t.style.background = type === 'success' ? 'var(--success)' : type === 'error' ? 'var(--danger)' : 'var(--accent)';
  t.textContent = msg;
  document.body.appendChild(t);
  setTimeout(function(){ t.style.opacity='0'; t.style.transition='opacity .3s'; }, 2500);
  setTimeout(function(){ t.remove(); }, 2900);
}

/* ── data helpers ── */
function RC(r){
  return {G:'r-G',PG:'r-PG','PG-13':'r-PG13',R:'r-R','R-18':'r-R18'}[r] || '';
}
function t12(t){
  if(!t) return '';
  var p = t.split(':'), h = +p[0], m = p[1];
  return (h%12||12)+':'+m+' '+(h<12?'AM':'PM');
}
function vf(label, value, full){
  return '<div class="vf'+(full?' full':'')+'">'+
    '<div class="vf-label">'+label+'</div>'+
    '<div class="vf-value">'+value+'</div>'+
  '</div>';
}

/* ── paginated table renderer ── */
function makeTable(data, colCount, rowFn, bodyId, countId, pagId, perPage, pgObj){
  var total = data.length;
  var pages = Math.max(1, Math.ceil(total / perPage));
  if(pgObj.v > pages) pgObj.v = 1;
  var start = (pgObj.v - 1) * perPage;
  var slice = data.slice(start, start + perPage);
  var body = document.getElementById(bodyId);
  if(!slice.length){
    body.innerHTML = '<tr><td colspan="'+colCount+'" style="text-align:center;padding:32px;color:var(--text-muted);font-size:13px;">No results found</td></tr>';
  } else {
    body.innerHTML = slice.map(function(item){ return '<tr>'+rowFn(item)+'</tr>'; }).join('');
  }
  var count = document.getElementById(countId);
  if(count) count.textContent = total + ' record' + (total !== 1 ? 's' : '');
  var pag = document.getElementById(pagId);
  if(!pag) return;
  if(pages <= 1){ pag.innerHTML = ''; return; }
  var btns = '';
  for(var i = 1; i <= pages; i++){
    btns += '<button class="page-btn'+(i===pgObj.v?' active':'')+'" data-pg="'+i+'">'+i+'</button>';
  }
  pag.innerHTML = btns;
  pag.querySelectorAll('.page-btn').forEach(function(btn){
    btn.addEventListener('click', function(){
      pgObj.v = +this.dataset.pg;
      btn.dispatchEvent(new Event('repage', {bubbles:true}));
    });
  });
}
