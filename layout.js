
(function(){
  var PAGES = [
    {key:'dashboard',   href:'dashboard.html',   icon:'▦',  label:'Dashboard',   section:'Main'},
    {key:'movies',      href:'movies.html',      icon:'🎞', label:'Movies'},
    {key:'showtimes',   href:'showtimes.html',   icon:'🗓', label:'Showtimes'},
    {key:'bookings',    href:'bookings.html',    icon:'🎟', label:'Bookings'},
    {key:'cinemas',     href:'cinemas.html',     icon:'🏛', label:'Cinemas',     section:'Venue'},
    {key:'screens',     href:'screens.html',     icon:'📺', label:'Screens'},
    {key:'seats',       href:'seats.html',       icon:'💺', label:'Seats'},
    {key:'payments',    href:'payments.html',    icon:'💳', label:'Payments',    section:'Finance'},
    {key:'customers',   href:'customers.html',   icon:'👤', label:'Customers',   section:'System'},
    {key:'tickets',     href:'tickets.html',     icon:'🎫', label:'Tickets'},
    {key:'audit_logs',  href:'audit_logs.html',  icon:'📋', label:'Audit Logs'},
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
