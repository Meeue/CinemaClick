/* layout.js — shared shell injected on every page */

/* ── theme bootstrap (runs before paint) ── */
(function(){
  var saved = localStorage.getItem('cinema-theme') || 'dark';
  document.documentElement.setAttribute('data-theme', saved);
})();

/* ── page definitions ── */
var PAGES = [
  {key:'dashboard',  href:'dashboard.html',  icon:'<i class="fa-solid fa-table-list" style="color: #ff4520;"></i>',  label:'Dashboard',  section:'Main'},
  {key:'movies',     href:'movies.html',     icon:'<i class="fa-solid fa-clapperboard" style="color: #ff4520;"></i>', label:'Movies'},
  {key:'showtimes',  href:'showtimes.html',  icon:'<i class="fa-solid fa-calendar-days" style="color: #ff4520;"></i>', label:'Showtimes'},
  {key:'bookings',   href:'bookings.html',   icon:'<i class="fa-solid fa-film" style="color: #ff4520;"></i>', label:'Bookings'},
  {key:'cinemas',    href:'cinemas.html',    icon:'<i class="fa-solid fa-building" style="color: #ff4520;"></i>', label:'Cinemas',    section:'Venue'},
  {key:'screens',    href:'screens.html',    icon:'<i class="fa-solid fa-tv" style="color: #ff4520;"></i>', label:'Screens'},
  {key:'seats',      href:'seats.html',      icon:'<i class="fa-solid fa-couch" style="color: #ff4520;"></i>', label:'Seats'},
  {key:'payments',   href:'payments.html',   icon:'<i class="fa-solid fa-credit-card" style="color: #ff4520;"></i>', label:'Payments',   section:'Finance'},
  {key:'customers',  href:'customers.html',  icon:'<i class="fa-solid fa-users" style="color: #ff4520;"></i>  ', label:'Customers',  section:'System'},
  {key:'tickets',    href:'tickets.html',    icon:'<i class="fa-solid fa-ticket" style="color: #ff4520;"></i>', label:'Tickets'},
  {key:'audit_logs', href:'audit_logs.html', icon:'<i class="fa-solid fa-file-pen" style="color: #ff4520;"></i>', label:'Audit Logs'},
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
    '        <div class="logo-text">CineClick</div>',
    '        <div class="logo-sub">Admin Portal</div>',
    '      </div>',
    '    </div>',
    '  </div>',
    '  <div class="nav">'+nav+'</div>',
    '  <div style="padding:14px 16px;border-top:1px solid var(--border);">',
    '    <a href="profile.html" style="display:flex;align-items:center;gap:10px;padding:8px 10px;border-radius:8px;text-decoration:none;transition:background .15s;" onmouseover="this.style.background=\'var(--accent-dim)\'" onmouseout="this.style.background=\'transparent\'">',
    '      <div style="width:30px;height:30px;border-radius:50%;background:var(--accent);color:#fff;display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:700;flex-shrink:0;">JD</div>',
    '      <div style="min-width:0;">',
    '        <div style="font-size:12px;font-weight:600;color:var(--text);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">Juan Dela Cruz</div>',
    '        <div style="font-size:10px;color:var(--text-muted);">Administrator</div>',
    '      </div>',
    '    </a>',
    '  </div>',
    '</div>',
  ].join('');
}

function buildTopbar(title, sub, actionLabel){
  var theme = document.documentElement.getAttribute('data-theme') || 'dark';
  var toggleIcon = theme === 'dark'
  ? '<i class="fa-solid fa-sun" style="color: rgb(255, 212, 59);"></i>'
  : '<i class="fa-solid fa-moon" style="color: #C8370A;"></i>';
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
    '    <a href="profile.html" class="avatar" title="My Profile">JD</a>',
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
  '<div class="modal-overlay" id="deleteModal">',
  '  <div class="modal modal-sm">',
  '    <div class="modal-header"><div class="modal-title" id="delTitle">Delete</div><button class="modal-close" onclick="CM(\'deleteModal\')">✕</button></div>',
  '    <div class="modal-body" style="padding:24px 22px">',
  '      <div class="confirm-icon"><i class="fa-solid fa-trash-can" style="color: #ff4520;"></i></div>',
  '      <p class="confirm-msg">Are you sure you want to delete <span class="confirm-name" id="delName"></span>? This action cannot be undone.</p>',
  '    </div>',
  '    <div class="modal-footer"><button class="btn btn-ghost" onclick="CM(\'deleteModal\')">Cancel</button><button class="btn btn-danger" id="delConfirm">Delete</button></div>',
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
};

function toggleTheme(){
  var current = document.documentElement.getAttribute('data-theme') || 'dark';
  var next = current === 'dark' ? 'light' : 'dark';
  document.documentElement.setAttribute('data-theme', next);
  localStorage.setItem('cinema-theme', next);
  var btn = document.getElementById('themeToggle');
  if(btn){
    btn.innerHTML = next === 'dark'
  ? '<i class="fa-solid fa-sun" style="color: rgb(255, 212, 59);"></i>'
  : '<i class="fa-solid fa-moon" style="color: #C8370A;"></i>';
    btn.title        = next === 'dark' ? 'Switch to light mode' : 'Switch to dark mode';
  }
}

/* ── modal helpers ── */
function OM(id){ document.getElementById(id).classList.add('open'); }
function CM(id){ document.getElementById(id).classList.remove('open'); }

/* ── data lookup helpers ── */
function RC(r){
  return {G:'r-G',PG:'r-PG','PG-13':'r-PG13',R:'r-R','R-18':'r-R18'}[r] || '';
}
function MN(mid){
  var m = movies.find(function(x){return x.movie_id===mid;});
  return m ? m.title : mid;
}
function ScrN(sid){
  var s = screens.find(function(x){return x.screen_id===sid;});
  return s ? s.screen_name : sid;
}
function CiN(cid){
  var c = cinemas.find(function(x){return x.cinema_id===cid;});
  return c ? c.cinema_name : cid;
}
function t12(t){
  if(!t) return '';
  var p = t.split(':'), h = +p[0], m = p[1];
  return (h%12||12)+':'+m+' '+(h<12?'AM':'PM');
}
function StL(sid){
  var s = showtimes.find(function(x){return x.showtime_id===sid;});
  if(!s) return sid;
  return MN(s.movie_id)+' · '+t12(s.start_time)+' · '+ScrN(s.screen_id);
}
function ABtns(vFn, eFn, dFn){
  return '<div class="actions">'+
    '<button class="btn btn-ghost btn-sm" onclick="'+vFn+'">View</button>'+
    '<button class="btn btn-ghost btn-sm" onclick="'+eFn+'">Edit</button>'+
    '<button class="btn btn-danger btn-sm" onclick="'+dFn+'">Del</button>'+
  '</div>';
}
function vf(label, value, full){
  return '<div class="vf'+(full?' full':'')+'">'+
    '<div class="vf-label">'+label+'</div>'+
    '<div class="vf-value">'+value+'</div>'+
  '</div>';
}

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

function showDelete(title, name, onConfirm){
  var overlay = document.createElement('div');
  overlay.className = 'modal-overlay';
  overlay.innerHTML =
    '<div class="modal modal-sm">'+
      '<div class="modal-header">'+
        '<div class="modal-title">'+title+'</div>'+
        '<button class="modal-close" onclick="this.closest(\'.modal-overlay\').remove()">✕</button>'+
      '</div>'+
      '<div class="modal-body">'+
        '<div class="confirm-icon"><i class="fa-solid fa-trash-can" style="color: #ff4520;"></i></div>'+
        '<div class="confirm-msg">Are you sure you want to delete <span class="confirm-name">'+name+'</span>? This cannot be undone.</div>'+
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
  if(pag) pag.innerHTML = '';
}