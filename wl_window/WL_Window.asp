<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
<meta HTTP-EQUIV="Expires" CONTENT="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title>Whitelist Window</title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/help.js"></script>
<script type="text/javascript" language="JavaScript" src="/validator.js"></script>
<style>
  /* -- Status pills -- */
  .wlw_pill {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 2px 10px 2px 7px;
    border-radius: 10px;
    font-size: 11px;
    font-weight: bold;
    letter-spacing: 0.5px;
    vertical-align: middle;
    white-space: nowrap;
  }
  .wlw_pill.pill_active   { background: #1a3d1a; border: 1px solid #3a7a3a; color: #7fdd7f; }
  .wlw_pill.pill_inactive { background: #2a2a2a; border: 1px solid #4a4a4a; color: #777777; }
  .wlw_pill_dot {
    width: 7px; height: 7px; border-radius: 50%; flex-shrink: 0;
  }
  .pill_active   .wlw_pill_dot { background: #7fdd7f; box-shadow: 0 0 4px #7fdd7f; }
  .pill_inactive .wlw_pill_dot { background: #555; }

  /* -- Type badges -- */
  .wlw_type_badge {
    display: inline-block; padding: 1px 7px; border-radius: 2px;
    font-size: 11px; font-weight: bold; letter-spacing: 0.5px;
  }
  .wlw_type_mac { background: #2a6496 !important; color: #fff !important; }
  .wlw_type_ip  { background: #5b5ea6 !important; color: #fff !important; }
  .wlw_type_int { background: #3c763d !important; color: #fff !important; }

  /* -- Whitelist table -- */
  #wlw_entry_table { width: 100%; border-collapse: collapse; }
  #wlw_entry_table th {
    background: #32454E; color: #b3bdc2; font-size: 11px; font-weight: normal;
    text-align: left; padding: 6px 8px; border-bottom: 1px solid #4a5f6a;
  }
  #wlw_entry_table td {
    padding: 5px 8px; border-bottom: 1px solid #263840;
    vertical-align: middle; font-size: 12px; color: #c0cdd2;
  }
  #wlw_entry_table tr:last-child td { border-bottom: none; }
  #wlw_entry_table tr:hover td { background: rgba(255,255,255,0.04); }

  .wlw_del_btn {
    background: #5c1a1a; border: 1px solid #8b2020; color: #e08080;
    padding: 4px 16px; cursor: pointer; font-size: 12px; border-radius: 2px;
  }
  .wlw_del_btn:hover { background: #7a2020; color: #fff; }

  /* -- Section labels -- */
  .wlw_section_label {
    color: #93b0bd; font-size: 11px; font-weight: bold;
    text-transform: uppercase; letter-spacing: 1px; padding: 10px 0 4px 0;
  }

  /* -- Add entry inputs -- */
  select.wlw_type_sel {
    background: #1e2d34; border: 1px solid #4a5f6a;
    color: #c0cdd2; padding: 3px 6px; font-size: 12px;
  }
  input.wlw_value_input {
    background: #1e2d34; border: 1px solid #4a5f6a;
    color: #c0cdd2; padding: 3px 8px; font-size: 12px; width: 220px;
  }
  input.wlw_value_input:focus { border-color: #7aafcc; outline: none; }

  .wlw_add_btn {
    background: #1a3a4a; border: 1px solid #4a7a96; color: #7fc4e0;
    padding: 4px 16px; cursor: pointer; font-size: 12px;
    border-radius: 2px; margin-left: 6px;
  }
  .wlw_add_btn:hover { background: #225066; color: #fff; }

  /* -- Control buttons -- */
  .wlw_ctrl_bar { display: flex; align-items: center; gap: 10px; padding: 6px 4px; flex-wrap: wrap; }
  .wlw_start_btn {
    background: #1a3d1a; border: 1px solid #3a7a3a; color: #7fdd7f;
    padding: 4px 16px; cursor: pointer; font-size: 12px; font-weight: bold;
    border-radius: 2px;
  }
  .wlw_start_btn:hover { background: #245c24; color: #fff; }
  .wlw_stop_btn {
    background: #3d1a1a; border: 1px solid #7a3a3a; color: #dd7f7f;
    padding: 4px 16px; cursor: pointer; font-size: 12px; font-weight: bold;
    border-radius: 2px;
  }
  .wlw_stop_btn:hover { background: #5c3a24; color: #fff; }
  .wlw_cron_enable_btn {
    background: #1a3d1a; border: 1px solid #3a7a3a; color: #7fdd7f;
    padding: 4px 16px; cursor: pointer; font-size: 12px; font-weight: bold;
    border-radius: 2px;
  }
  .wlw_cron_enable_btn:hover  { background: #245c24; color: #fff; }
  .wlw_cron_disable_btn {
    background: #3d1a1a; border: 1px solid #7a5a3a; color: #dd7f7f;
    padding: 4px 16px; cursor: pointer; font-size: 12px; font-weight: bold;
    border-radius: 2px;
  }
  .wlw_cron_disable_btn:hover { background: #5c3a24; color: #fff; }

  .wlw_hint { color: #7a9aaa; font-size: 11px; margin-top: 3px; }
  .wlw_empty_row td { color: #556a76; font-style: italic; text-align: center; padding: 12px; }

  /* -- FormTable th alignment helper -- */
  .wlw_th_mid { vertical-align: middle !important; }
</style>

<script type="text/javascript" language="JavaScript">

var custom_settings = <% get_custom_settings(); %>;

/*
 * wlw_entries: array of { type, value } objects.
 * Each entry also carries a stable `_uid` integer so that delete
 * operations are immune to sort reordering and duplicate values.
 */
var wlw_entries = [];
var _wlw_uid_counter = 0;

function _makeEntry(type, value) {
  return { type: type, value: value, _uid: _wlw_uid_counter++ };
}

/* ----------------------------------------------------------------
   Page init
---------------------------------------------------------------- */
function initial() {
  SetCurrentPage();
  show_menu();
  loadSettings();
  renderTable();
  updatePills();
}

function SetCurrentPage() {
  document.form.next_page.value    = window.location.pathname.substring(1);
  document.form.current_page.value = window.location.pathname.substring(1);
}

/* ----------------------------------------------------------------
   Status pills
   wlw_active      "1" = firewall block is live
   wlw_cron_active "1" = cron jobs are installed
   wlw_persist      "1" = rules survive reboot
---------------------------------------------------------------- */
function makePill(id, active, labelOn, labelOff) {
  var el = document.getElementById(id);
  if (!el) return;
  el.className = 'wlw_pill ' + (active ? 'pill_active' : 'pill_inactive');
  el.innerHTML =
    '<span class="wlw_pill_dot"></span>' +
    '<span>' + (active ? labelOn : labelOff) + '</span>';
}

function updatePills() {
  makePill('wlw_fw_pill',
    custom_settings.wlw_active      === "1",
    'BLOCK ACTIVE',      'BLOCK INACTIVE');

  makePill('wlw_cron_pill',
    custom_settings.wlw_cron_active === "1",
    'SCHEDULE ON',       'SCHEDULE OFF');

  makePill('wlw_persist_pill',
    custom_settings.wlw_persist     === "1",
    'BLOCK PERSISTENCE ON', 'BLOCK PERSISTENCE OFF');
}

/* ----------------------------------------------------------------
   Load settings
---------------------------------------------------------------- */
function loadSettings() {
  if (custom_settings.wlw_entries !== undefined &&
      custom_settings.wlw_entries !== "") {
    try {
      var raw = JSON.parse(custom_settings.wlw_entries);
      wlw_entries = [];
      for (var i = 0; i < raw.length; i++) {
        wlw_entries.push(_makeEntry(raw[i].type, raw[i].value));
      }
    } catch(e) {
      wlw_entries = [];
    }
  } else {
    /* Default demo entries */
    var defaults = [
      { type:"mac", value:"aa:bb:cc:dd:ee:ff" },
      { type:"mac", value:"11:22:33:44:55:66" },
      { type:"int", value:"wl0.1" },
      { type:"int", value:"wl0.2" },
      { type:"ip",  value:"192.168.1.50" },
      { type:"ip",  value:"192.168.1.100" }
    ];
    wlw_entries = [];
    for (var j = 0; j < defaults.length; j++) {
      wlw_entries.push(_makeEntry(defaults[j].type, defaults[j].value));
    }
  }

  var get = function(id, fallback) {
    var el = document.getElementById(id);
    if (!el) return;
    var v = custom_settings[id.replace('wlw_', 'wlw_')];
    el.value = (v !== undefined) ? v : fallback;
  };
  if (custom_settings.wlw_start_hh !== undefined) document.getElementById('wlw_start_hh').value = custom_settings.wlw_start_hh;
  if (custom_settings.wlw_start_mm !== undefined) document.getElementById('wlw_start_mm').value = custom_settings.wlw_start_mm;
  if (custom_settings.wlw_end_hh   !== undefined) document.getElementById('wlw_end_hh').value   = custom_settings.wlw_end_hh;
  if (custom_settings.wlw_end_mm   !== undefined) document.getElementById('wlw_end_mm').value   = custom_settings.wlw_end_mm;
}

/* ----------------------------------------------------------------
   Pack settings before every submit
   Strip the internal _uid field before serialising.

   FIX: wlw_persist, wlw_active, and wlw_cron_active are now explicitly
   preserved in every amng_custom payload.  Previously these keys were
   never written by packSettings(), so Merlin never pre-seeded them in
   custom_settings.txt before firing the service event.  That meant
   cfg_set() in wl_window.sh always hit the append (else) branch for
   these keys rather than the sed replacement branch — and on the very
   first toggle the inode-replacement race could still occur before
   the cp-over fix had a chance to stabilise the file.  By ensuring
   the keys exist in the file from the first Apply onwards, all
   subsequent cfg_set calls take the fast, safe replacement path.
---------------------------------------------------------------- */
function packSettings() {
  var toSave = [];
  for (var i = 0; i < wlw_entries.length; i++) {
    toSave.push({ type: wlw_entries[i].type, value: wlw_entries[i].value });
  }
  custom_settings.wlw_entries    = JSON.stringify(toSave);
  custom_settings.wlw_start_hh   = document.getElementById('wlw_start_hh').value;
  custom_settings.wlw_start_mm   = document.getElementById('wlw_start_mm').value;
  custom_settings.wlw_end_hh     = document.getElementById('wlw_end_hh').value;
  custom_settings.wlw_end_mm     = document.getElementById('wlw_end_mm').value;
  /* Carry existing state values forward so Merlin writes them into
     custom_settings.txt even if they have never been toggled yet.
     Default to "0" if the key is absent (first-ever page load).    */
  custom_settings.wlw_active      = custom_settings.wlw_active      || "0";
  custom_settings.wlw_cron_active = custom_settings.wlw_cron_active || "0";
  custom_settings.wlw_persist     = custom_settings.wlw_persist     || "0";
  document.getElementById('amng_custom').value = JSON.stringify(custom_settings);
}

function submitAction(script, wait) {
  packSettings();
  document.form.action_script.value = script;
  document.form.action_wait.value   = String(wait);
  showLoading();
  document.form.submit();
}

/* ----------------------------------------------------------------
   Apply / Save
---------------------------------------------------------------- */
function applySettings() {
  submitAction("restart_wlwindow", 5);
}

/* ----------------------------------------------------------------
   Firewall manual control
---------------------------------------------------------------- */
function manualControl(action) {
  var label = (action === 'start') ? 'activate' : 'deactivate';
  if (!confirm("Manually " + label + " the firewall block now?")) return;
  submitAction("restart_wlwindow_" + action, 3);
}

/* ----------------------------------------------------------------
   Cron toggle
   restart_wlwindow_cron_enable  -> service-event restart wlwindow_cron_enable
   restart_wlwindow_cron_disable -> service-event restart wlwindow_cron_disable
---------------------------------------------------------------- */
function cronControl(action) {
  var label = (action === 'enable') ? 'enable' : 'disable';
  if (!confirm("Are you sure you want to " + label + " the schedule?")) return;
  submitAction("restart_wlwindow_cron_" + action, 3);
}

/* ----------------------------------------------------------------
   Reboot-survival toggle
---------------------------------------------------------------- */
function persistControl(action) {
  var label = (action === 'enable') ? 'enable' : 'disable';
  if (!confirm("Are you sure you want to " + label + " block persistence on reboot?")) return;
  submitAction("restart_wlwindow_persist_" + action, 3);
}

/* ----------------------------------------------------------------
   Render whitelist table

   FIX: sort a *copy* that retains the original entry object
   references (not just their values), then use the entry's stable
   _uid to locate and remove the correct item.  This means the
   delete index is immune to:
     - sort reordering
     - duplicate value strings
---------------------------------------------------------------- */
function renderTable() {
  var tbody = document.getElementById('wlw_tbody');
  tbody.innerHTML = "";

  if (wlw_entries.length === 0) {
    var tr = document.createElement('tr');
    tr.className = 'wlw_empty_row';
    tr.innerHTML =
      '<td colspan="3">No entries &mdash; use the form below to add MACs, IPs, or interfaces.</td>';
    tbody.appendChild(tr);
    return;
  }

  var order  = { mac: 0, ip: 1, int: 2 };
  var sorted = wlw_entries.slice().sort(function(a, b) {
    return order[a.type] - order[b.type];
  });

  for (var i = 0; i < sorted.length; i++) {
    var entry = sorted[i];
    var uid   = entry._uid;   /* stable identifier — not a mutable array index */
    var badge;
    if      (entry.type === 'mac') badge = '<span class="wlw_type_badge wlw_type_mac">MAC</span>';
    else if (entry.type === 'ip')  badge = '<span class="wlw_type_badge wlw_type_ip">IP</span>';
    else                           badge = '<span class="wlw_type_badge wlw_type_int">IFACE</span>';

    var tr = document.createElement('tr');
    tr.innerHTML =
      '<td style="width:70px;">' + badge + '</td>' +
      '<td style="font-family:monospace;">' + escapeHtml(entry.value) + '</td>' +
      '<td style="width:80px;text-align:right;">' +
        '<button class="wlw_del_btn" onclick="deleteEntry(' + uid + ');return false;">Remove</button>' +
      '</td>';
    tbody.appendChild(tr);
  }
}

/* ----------------------------------------------------------------
   Add entry

   FIX: IPv6 addresses may contain uppercase hex — normalise to
   lowercase *after* splitting so the inet6 colon-check still works.
   MAC and IPv4 are already lowercase-safe.
---------------------------------------------------------------- */
function addEntry() {
  var type  = document.getElementById('wlw_new_type').value;
  var raw   = document.getElementById('wlw_new_value').value.trim();
  var value = raw.toLowerCase();

  if (value === "") {
    alert("Please enter a value.");
    return;
  }

  if (type === "mac") {
    if (!value.match(/^([0-9a-f]{2}:){5}[0-9a-f]{2}$/)) {
      alert("Invalid MAC address.\nExpected format: xx:xx:xx:xx:xx:xx");
      return;
    }
  } else if (type === "ip") {
    var isIPv4 = /^(\d{1,3}\.){3}\d{1,3}$/.test(value);
    /*
     * FIX: tighter IPv6 check — must contain at least one colon and
     * consist only of hex digits, colons, and at most one '/'.
     * The original regex accepted strings like "::::" without digits.
     */
    var isIPv6 = value.indexOf(':') !== -1 &&
                 /^[0-9a-f:\/]+$/.test(value);
    if (!isIPv4 && !isIPv6) {
      alert("Invalid IP address.");
      return;
    }
    if (isIPv4) {
      var octets = value.split('.');
      for (var o = 0; o < octets.length; o++) {
        if (parseInt(octets[o], 10) > 255) {
          alert("Invalid IPv4 address — octet out of range.");
          return;
        }
      }
    }
  } else if (type === "int") {
    if (!value.match(/^[a-z0-9._-]+$/i)) {
      alert("Invalid interface name.\nExpected: eth0, wl0.1, br0, etc.");
      return;
    }
  }

  /* Duplicate check */
  for (var i = 0; i < wlw_entries.length; i++) {
    if (wlw_entries[i].value === value) {
      alert("Already in the whitelist.");
      return;
    }
  }

  wlw_entries.push(_makeEntry(type, value));
  document.getElementById('wlw_new_value').value = "";
  renderTable();
}

/* ----------------------------------------------------------------
   Delete entry by stable UID

   FIX: instead of wlw_entries[idx] (where idx was a post-sort
   array index and could point to the wrong entry after reordering),
   we now search for the entry whose _uid matches.
---------------------------------------------------------------- */
function deleteEntry(uid) {
  var idx = -1;
  for (var i = 0; i < wlw_entries.length; i++) {
    if (wlw_entries[i]._uid === uid) { idx = i; break; }
  }
  if (idx === -1) return;   /* already gone */
  if (!confirm('Remove "' + wlw_entries[idx].value + '" from the whitelist?')) return;
  wlw_entries.splice(idx, 1);
  renderTable();
}

/* ----------------------------------------------------------------
   Utilities
---------------------------------------------------------------- */
function escapeHtml(s) {
  return String(s)
    .replace(/&/g,  "&amp;")
    .replace(/</g,  "&lt;")
    .replace(/>/g,  "&gt;")
    .replace(/"/g,  "&quot;");
}

function wlw_keydown(e) {
  if (e.keyCode === 13) { addEntry(); return false; }
}
</script>
</head>

<body onload="initial();" class="bg">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>

<form method="post" name="form" action="start_apply.htm" target="hidden_frame">
<input type="hidden" name="current_page"   value="WL_Window.asp">
<input type="hidden" name="next_page"      value="WL_Window.asp">
<input type="hidden" name="group_id"       value="">
<input type="hidden" name="modified"       value="0">
<input type="hidden" name="action_mode"    value="apply">
<input type="hidden" name="action_wait"    value="5">
<input type="hidden" name="first_time"     value="">
<input type="hidden" name="action_script"  value="restart_wlwindow">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver"        value="<% nvram_get("firmver"); %>">
<input type="hidden" name="amng_custom"    id="amng_custom" value="">

<table class="content" align="center" cellpadding="0" cellspacing="0">
<tr>
  <td width="17">&nbsp;</td>
  <td valign="top" width="202">
    <div id="mainMenu"></div>
    <div id="subMenu"></div>
  </td>
  <td valign="top">
    <div id="tabMenu" class="submenuBlock"></div>
    <table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
    <tr>
    <td align="left" valign="top">

      <table width="760px" border="0" cellpadding="5" cellspacing="0"
             bordercolor="#6b8fa3" class="FormTitle" id="FormTitle">
      <tr>
      <td bgcolor="#4D595D" colspan="3" valign="top">

        <div>&nbsp;</div>
        <div class="formfonttitle">Whitelist Window &mdash; Internet Access Scheduler</div>
        <div style="margin:10px 0 10px 5px;" class="splitLine"></div>
        <div class="formfontdesc">
          Blocks all internet access insdie the scheduled window, except for whitelisted
          MACs, IPs, and interfaces. You can manually enable/disable the schedule or the block.
          <br><br>
          The main purpose of this addon/script is to prevent access bypassing by mac randomization.
          <br><br>
          Use Block persistence with caution. Only use it if rebooting the router to bypass the block is an actual concern.
        </div>

        <!-- ========== SCHEDULE / CRON CONTROL ==================== -->
        <div class="wlw_section_label" style="margin-top:20px;">Schedule (Cron)</div>
        <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0"
               bordercolor="#6b8fa3" class="FormTable">
          <tr>
            <th style="width:160px;" class="wlw_th_mid">
              <div style="margin-top:5px;">
                <span id="wlw_cron_pill" class="wlw_pill pill_inactive">
                  <span class="wlw_pill_dot"></span><span>SCHEDULE OFF</span>
                </span>
              </div>
            </th>
            <td>
              <div class="wlw_ctrl_bar">
                <button class="wlw_cron_enable_btn"
                        onclick="cronControl('enable');return false;">
                  &#9654;&nbsp;Enable Schedule
                </button>
                <button class="wlw_cron_disable_btn"
                        onclick="cronControl('disable');return false;">
                  &#9632;&nbsp;Disable Schedule
                </button>
              </div>
            </td>
          </tr>
          <tr>
            <th style="width:160px;">Block Start (HH:MM)</th>
            <td>
              <input type="text" id="wlw_start_hh" maxlength="2" class="input_6_table"
                     value="22" style="width:38px;text-align:center;" autocorrect="off">
              &nbsp;:&nbsp;
              <input type="text" id="wlw_start_mm" maxlength="2" class="input_6_table"
                     value="00" style="width:38px;text-align:center;" autocorrect="off">
              <span class="wlw_hint">&nbsp;24-hour &middot; block activates at this time nightly</span>
            </td>
          </tr>
          <tr>
            <th>Block End (HH:MM)</th>
            <td>
              <input type="text" id="wlw_end_hh" maxlength="2" class="input_6_table"
                     value="06" style="width:38px;text-align:center;" autocorrect="off">
              &nbsp;:&nbsp;
              <input type="text" id="wlw_end_mm" maxlength="2" class="input_6_table"
                     value="00" style="width:38px;text-align:center;" autocorrect="off">
              <span class="wlw_hint">&nbsp;24-hour &middot; block is lifted at this time</span>
            </td>
          </tr>
          <tr>
            <th style="width:160px;" class="wlw_th_mid">
              <div style="margin-top:5px;">
                <span id="wlw_fw_pill" class="wlw_pill pill_inactive">
                  <span class="wlw_pill_dot"></span><span>BLOCK INACTIVE</span>
                </span>
              </div>
            </th>
            <td>
              <div class="wlw_ctrl_bar">
                <button class="wlw_start_btn"
                        onclick="manualControl('start');return false;">
                  &#9654;&nbsp;Activate Block
                </button>
                <button class="wlw_stop_btn"
                        onclick="manualControl('stop');return false;">
                  &#9632;&nbsp;Deactivate Block
                </button>
              </div>
            </td>
          </tr>
          <tr>
            <th style="width:160px;" class="wlw_th_mid">
              <div style="margin-top:5px;">
                <span id="wlw_persist_pill" class="wlw_pill pill_inactive">
                  <span class="wlw_pill_dot"></span><span>BLOCK PERSISTENCE OFF</span>
                </span>
              </div>
            </th>
            <td>
              <div class="wlw_ctrl_bar">
                <button class="wlw_start_btn"
                        onclick="persistControl('enable');return false;">
                  &#9654;&nbsp;Enable Persistence
                </button>
                <button class="wlw_stop_btn"
                        onclick="persistControl('disable');return false;">
                  &#9632;&nbsp;Disable Persistence
                </button>
              </div>
            </td>
          </tr>
        </table>

        <!-- ========== WHITELIST TABLE ============================= -->
        <div class="wlw_section_label" style="margin-top:20px;">Whitelisted Entries</div>
        <table id="wlw_entry_table" width="100%" border="1" align="center"
               cellpadding="0" cellspacing="0" bordercolor="#6b8fa3"
               class="FormTable" style="table-layout:fixed;">
          <thead>
            <tr>
              <th style="width:10%; padding:8px 10px; text-align:center;">Type</th>
              <th style="width:80%; padding:8px 10px; text-align:center;">Value</th>
              <th style="width:10%; padding:8px 10px; text-align:center;">Action</th>
            </tr>
          </thead>

          <!-- Dynamic rows injected by renderTable() -->
          <tbody id="wlw_tbody"></tbody>
          <tfoot>
            <tr>
              <td style="padding:8px 10px;">
                <select id="wlw_new_type" class="wlw_type_sel" style="width:100%;">
                  <option value="mac">MAC</option>
                  <option value="ip">IP</option>
                  <option value="int">IFACE</option>
                </select>
              </td>
              <td style="padding:8px 10px;">
                <input type="text" id="wlw_new_value" class="wlw_value_input"
                       placeholder="e.g. aa:bb:cc:dd:ee:ff, 192.168.1.40, wl0.1, eth5&hellip;"
                       autocorrect="off" autocapitalize="off" autocomplete="off"
                       onkeydown="wlw_keydown(event);"
                       style="width:100%; box-sizing:border-box;">
              </td>
              <td style="padding:8px 10px; text-align:center;">
                <button class="wlw_add_btn"
                        onclick="addEntry();return false;">Add</button>
              </td>
            </tr>
            <tr>
              <td colspan="3" style="padding:8px 10px; text-align:center;">
                <div class="wlw_hint">
                  MAC: <code>xx:xx:xx:xx:xx:xx</code> &nbsp;|&nbsp;
                  IP: IPv4 or IPv6 &nbsp;|&nbsp;
                  Interface: <code>wl0.1</code>, <code>eth0</code>, <code>br0</code>&hellip;
                </div>
              </td>
            </tr>
          </tfoot>
        </table>

        <!-- ========== APPLY ======================================= -->
        <div class="apply_gen">
          <input name="button" type="button" class="button_gen"
                 onclick="applySettings();" value="Apply" />
        </div>

      </td>
      </tr>
      </table>

    </td>
    </tr>
    </table>
  </td>
  <td width="10" align="center" valign="top"></td>
</tr>
</table>
</form>

<div id="footer"></div>
</body>
</html>
