
(function(){
  var saved = localStorage.getItem('cinema-theme') || 'dark';
  document.documentElement.setAttribute('data-theme', saved);
  document.body.setAttribute('data-theme', saved);
})();

function injectLayout(opts){
  opts = opts || {};
  var page        = opts.page        || '';
  var title       = opts.title       || '';
  var sub         = opts.sub         || '';
  var actionLabel = opts.actionLabel || null;

  var navItems = [
    {id:'dashboard', icon:'⬛', label:'Dashboard',  href:'dashboard.html',  section:'Main'},
    {id:'movies',    icon:'🎬', label:'Movies',     href:'movies.html'},
    {id:'showtimes', icon:'🕐', label:'Showtimes',  href:'showtimes.html'},
    {id:'bookings',  icon:'📋', label:'Bookings',   href:'bookings.html'},
    {id:'tickets',   icon:'🎟', label:'Tickets',    href:'tickets.html'},
    {id:'customers', icon:'👤', label:'Customers',  href:'customers.html'},
    {id:'cinemas',   icon:'🏛', label:'Cinemas',    href:'cinemas.html',    section:'Venue'},
    {id:'screens',   icon:'📺', label:'Screens',    href:'screens.html'},
    {id:'seats',     icon:'💺', label:'Seats',      href:'seats.html'},
    {id:'payments',  icon:'💳', label:'Payments',   href:'payments.html',   section:'Finance'},
  ];

  function buildSidebar(activeKey){
    var nav = '';
    PAGES.forEach(function(p){
      if(p.section) nav += '<div class="nav-section">'+p.section+'</div>';
      var cls = 'nav-item' + (p.key===activeKey?' active':'');
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
      '    <a href="profile.html" style="display:flex;align-items:center;gap:10px;padding:8px 10px;border-radius:8px;text-decoration:none;transition:background .15s;" onmouseover="this.style.background=\'var(--primary-light)\'" onmouseout="this.style.background=\'transparent\'">',
      '      <div style="width:30px;height:30px;border-radius:50%;background:linear-gradient(135deg,#2563EB,#0EA5E9);color:#fff;display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:700;flex-shrink:0;">JD</div>',
      '      <div style="min-width:0;">',
      '        <div style="font-size:12px;font-weight:600;color:var(--text-primary);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">Juan Dela Cruz</div>',
      '        <div style="font-size:10px;color:var(--text-muted);">Administrator</div>',
      '      </div>',
      '    </a>',
      '  </div>',
      '</div>',
    ].join('');
  }

  function buildTopbar(title, sub, actionLabel){
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
    '      <div class="confirm-icon">🗑️</div>',
    '      <p class="confirm-msg">Are you sure you want to delete <span class="confirm-name" id="delName"></span>? This action cannot be undone.</p>',
    '    </div>',
    '    <div class="modal-footer"><button class="btn btn-ghost" onclick="CM(\'deleteModal\')">Cancel</button><button class="btn btn-danger" id="delConfirm">Delete</button></div>',
    '  </div>',
    '</div>',
  ].join('');

  window.injectLayout = function(cfg){
    var app = document.getElementById('app');
    var sidebar = buildSidebar(cfg.page);
    var main = [
      '<div class="main">',
      buildTopbar(cfg.title, cfg.sub, cfg.actionLabel||null),
      '<div class="content" id="pageContent"></div>',
      '</div>',
      SHARED_MODALS,
    ].join('');
    app.innerHTML = sidebar + main;
  };
})();
