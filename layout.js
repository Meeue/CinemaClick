/**
 * layout.js — Injects the shared sidebar, topbar, and modal overlays into each page.
 */

(function(){
  var PAGES = [
    {key:'dashboard',  href:'dashboard.html',  icon:'▦',  label:'Dashboard',  section:'Main'},
    {key:'movies',     href:'movies.html',     icon:'🎞', label:'Movies'},
    {key:'showtimes',  href:'showtimes.html',  icon:'🗓', label:'Showtimes'},
    {key:'bookings',   href:'bookings.html',   icon:'🎟', label:'Bookings'},
    {key:'cinemas',    href:'cinemas.html',    icon:'🏛', label:'Cinemas',    section:'Venue'},
    {key:'screens',    href:'screens.html',    icon:'📺', label:'Screens'},
    {key:'seats',      href:'seats.html',      icon:'💺', label:'Seats'},
    {key:'payments',   href:'payments.html',   icon:'💳', label:'Payments',   section:'Finance'},
    {key:'customers',  href:'customers.html',  icon:'👤', label:'Customers',  section:'System'},
    {key:'tickets',    href:'tickets.html',    icon:'🎫', label:'Tickets'},
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
      '      <div><div class="logo-text">Cinema Title</div><div class="logo-sub">Admin Portal</div></div>',
      '    </div>',
      '  </div>',
      '  <div class="nav">'+nav+'</div>',
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
      '  <div class="topbar-right">'+btn+'<div class="avatar">JD</div></div>',
      '</div>',
    ].join('');
  }

  var SHARED_MODALS = [
    // VIEW MODAL
    '<div class="modal-overlay" id="viewModal">',
    '  <div class="modal">',
    '    <div class="modal-header"><div class="modal-title" id="vwTitle">Details</div><button class="modal-close" onclick="CM(\'viewModal\')">✕</button></div>',
    '    <div class="modal-body"><div class="view-grid" id="vwBody"></div></div>',
    '    <div class="modal-footer"><button class="btn btn-ghost" onclick="CM(\'viewModal\')">Close</button><button class="btn btn-primary" id="vwEditBtn" style="display:none">Edit</button></div>',
    '  </div>',
    '</div>',
    // DELETE MODAL
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

  // Public API
  window.injectLayout = function(cfg){
    // cfg: { page, title, sub, actionLabel }
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
