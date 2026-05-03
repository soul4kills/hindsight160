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
  /* -- Toggle switches -- */
  .wlw_toggle_wrap {
    display: inline-flex;
    align-items: center;
    gap: 10px;
    padding: 4px 0;
  }
  .wlw_toggle {
    position: relative;
    width: 44px;
    height: 24px;
    flex-shrink: 0;
  }
  .wlw_toggle input {
    opacity: 0;
    width: 0;
    height: 0;
    position: absolute;
  }
  .wlw_toggle_track {
    position: absolute;
    inset: 0;
    border-radius: 12px;
    background: #2a2a2a;
    border: 1px solid #434343;
    cursor: pointer;
    transition: background 0.2s, border-color 0.2s;
  }
  .wlw_toggle_track:before {
    content: "";
    position: absolute;
    width: 16px;
    height: 16px;
    left: 3px;
    top: 3px;
    border-radius: 50%;
    background: #434343;
    transition: transform 0.2s, background 0.2s;
  }
  .wlw_toggle input:checked + .wlw_toggle_track {
    background: #1a3d1a;
    border-color: #3a7a3a;
  }
  .wlw_toggle input:checked + .wlw_toggle_track:before {
    transform: translateX(20px);
    background: #7fdd7f;
    box-shadow: 0 0 4px #7fdd7f;
  }
  .wlw_toggle_label {
    font-size: 12px;
    font-weight: bold;
    min-width: 140px;
    transition: color 0.2s;
  }
  .wlw_toggle_label.tog_on  { color: #7fdd7f; }
  .wlw_toggle_label.tog_off { color: #434343; }

  /* -- Type badges -- */
  .wlw_type_badge {
    display: inline-block; padding: 1px 7px; border-radius: 2px;
    font-size: 11px; font-weight: bold; letter-spacing: 0.5px;
  }
  .wlw_type_mac { background: #2a6496 !important; color: #fff !important; }
  .wlw_type_ip  { background: #5b5ea6 !important; color: #fff !important; }
  .wlw_type_int { background: #3c763d !important; color: #fff !important; }

  /* -- Whitelist table -- */
  #wlw_entry_table {
    font-size: 12px;
    font-family: Arial, Helvetica, MS UI Gothic, MS P Gothic, Microsoft Yahei UI, sans-serif;
    border: 1px solid #000000;
    border-collapse: collapse;
  }
  #wlw_entry_table th {
    color: #b3bdc2; font-size: 11px; font-weight: normal;
    text-align: left; padding: 6px 8px;
  }
  #wlw_entry_table td {
    padding: 5px 8px;
    vertical-align: middle; font-size: 12px; color: #c0cdd2;
  }
  #wlw_entry_table tr:last-child td { border-bottom: none; }
  #wlw_entry_table tr:hover td { background: rgba(255,255,255,0.04); }

  /* Resolved name cells */
  .wlw_name_assigned   { background-color: unset !important; color: #c0cdd2; font-size: 11px; }
  .wlw_name_associated { background-color: unset !important; color: #7a9aaa; font-size: 11px; }
  .wlw_name_none       { background-color: unset !important; color: #445a66; font-style: italic; }

  .wlw_del_btn { width: 75px;
    background: #5c1a1a; border: 1px solid #8b2020; color: #e08080;
    padding: 4px 16px; cursor: pointer; font-size: 12px; border-radius: 2px;
  }
  .wlw_del_btn:hover { background: #7a2020; color: #fff; }

  /* -- Section labels --
     border-bottom removed to avoid double-border with the FormTable below. */
  .wlw_section_label {
    line-height: 180%;
    color: #FFF;
    font-size: 12px;
    text-align: left;
    font-weight: bolder;
    border: 1px solid #222;
    border-bottom: none;
    padding: 3px;
    padding-left: 10px;
    background: #92A0A5;
    background: -moz-linear-gradient(top, #92A0A5 0%, #66757C 100%);
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#92A0A5), color-stop(100%,#66757C));
    background: -webkit-linear-gradient(top, #92A0A5 0%, #66757C 100%);
    background: -o-linear-gradient(top, #92A0A5 0%, #66757C 100%);
    background: -ms-linear-gradient(top, #92A0A5 0%, #66757C 100%);
    background: linear-gradient(to bottom, #92A0A5 0%, #66757C 100%);
  }

  /* -- Add / Remove icon buttons -- */
  .wlw_icon_btn {
    position: relative;
    width: 28px;
    height: 28px;
    border-radius: 50%;
    border: 1px solid;
    cursor: pointer;
    font-size: 18px;
    line-height: 1;
    font-weight: bold;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    transition: background 0.2s, border-color 0.2s, color 0.2s;
    padding: 0 0 2px 0;
    flex-shrink: 0;
  }
  .wlw_icon_btn.btn_add {
    background: #1a3a4a;
    border-color: #4a7a96;
    color: #7fc4e0;
  }
  .wlw_icon_btn.btn_add:hover {
    background: #225066;
    border-color: #7aafcc;
    color: #fff;
  }
  .wlw_icon_btn.btn_remove {
    background: #3a1a1a;
    border-color: #7a3a3a;
    color: #dd7f7f;
  }
  .wlw_icon_btn.btn_remove:hover {
    background: #5c2020;
    border-color: #aa4444;
    color: #fff;
  }

  /* -- Add entry inputs -- */
  select.wlw_type_sel {
    background: #1e2d34; border: 1px solid #4a5f6a;
    color: #c0cdd2; padding: 3px 6px; font-size: 12px;
  }
  input.wlw_value_input {
    background: #1e2d34; border: 1px solid #4a5f6a;
    color: #c0cdd2; padding: 3px 8px; font-size: 12px;
  }
  input.wlw_value_input:focus { border-color: #7aafcc; outline: none; }

  select.wlw_client_sel {
    background: #1e2d34; border: 1px solid #4a5f6a;
    color: #c0cdd2; padding: 3px 6px; font-size: 12px;
    max-width: 50% !important; box-sizing: border-box; min-width: 50% !important;
  }
  option.wlw_opt_active   { color: #7fdd7f; }
  option.wlw_opt_inactive { color: #7a9aaa; }

  .wlw_add_btn { width: 75px;
    background: #1a3a4a; border: 1px solid #4a7a96; color: #7fc4e0;
    padding: 4px 16px; cursor: pointer; font-size: 12px;
    border-radius: 2px;
  }
  .wlw_add_btn:hover { background: #225066; color: #fff; }

  .wlw_add_row_inner {
    display: flex;
    gap: 6px;
    align-items: center;
    width: 100%;
    box-sizing: border-box;
  }
  .wlw_add_row_inner input  { flex: 1; min-width: 0; }
  .wlw_add_row_inner select { flex: 1; min-width: 0; }

  .wlw_hint { color: #7a9aaa; font-size: 11px; margin-top: 3px; }
  .wlw_empty_row td { color: #556a76; font-style: italic; text-align: center; padding: 12px; }
  .wlw_th_mid { vertical-align: middle !important; }

  /* -- Day-of-week picker -- */
  .wlw_day_picker {
    display: flex; gap: 4px; align-items: center; flex-wrap: wrap; padding: 4px 0;
  }
  .wlw_day_btn {
    display: inline-block; width: 38px; padding: 5px 0; text-align: center;
    font-size: 11px; font-weight: bold; letter-spacing: 0.3px; cursor: pointer;
    border-radius: 3px; border: 1px solid #3a5060; background: #1e2d34; color: #7a9aaa;
    user-select: none; -webkit-user-select: none;
    transition: background 0.15s, color 0.15s, border-color 0.15s;
  }
  .wlw_day_btn.day_on {
    background: #1a4a6a; border-color: #4a9acc; color: #7fc4e0;
    box-shadow: 0 0 4px rgba(74,154,204,0.35);
  }
  .wlw_day_btn:hover { border-color: #6abadc; color: #b0dcf0; }

  .wlw_day_shortcut_bar {
    display: flex; gap: 6px; margin-top: 6px; flex-wrap: wrap; align-items: center;
  }
  .wlw_day_shortcut {
    font-size: 11px; color: #7aafcc; cursor: pointer; text-decoration: underline;
    background: none; border: none; padding: 0;
  }
  .wlw_day_shortcut:hover { color: #b0dcf0; }

  #wlw_days_summary {
    font-size: 11px; color: #93b0bd; margin-left: 4px; font-style: italic;
  }
</style>

<script type="text/javascript" language="JavaScript">

var custom_settings = <% get_custom_settings(); %>;

/*
 * Runtime state
 *   wlw_entries  — current whitelist: [{ type, value, _uid }]
 *   wlw_days     — selected block nights: [0-6] (0=Sun)
 *
 * Loaded from custom_settings on page load (written by wlwindow_service.sh):
 *   wlw_resolve  — { "mac-or-ip": { assigned, associated } }
 *   wlw_clients  — [{ value, ip, assigned, associated, status }]
 *   wlw_ifaces   — [{ value, label }]
 *
 * All three are space-encoded (\u0020) in custom_settings.txt so they
 * survive the "key<space>value" line format.  JSON.parse decodes \u0020
 * back to spaces automatically — no manual decode needed.
 *
 * packSettings() must NOT write resolve/clients/ifaces back — they are
 * owned by the service script and must not be overwritten with stale values.
 */
var wlw_entries      = [];
var wlw_days         = [];
var wlw_resolve      = {};
var wlw_clients      = [];
var wlw_ifaces       = [];
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
  renderDayPicker();
  updateDaysSummary();
  syncAllToggles();
  onTypeChange();
}

function SetCurrentPage() {
  document.form.next_page.value    = window.location.pathname.substring(1);
  document.form.current_page.value = window.location.pathname.substring(1);
}

/* ----------------------------------------------------------------
   Toggle helpers
---------------------------------------------------------------- */
function _syncToggle(id, active, labelOn, labelOff) {
  var chk   = document.getElementById(id);
  var label = document.getElementById(id + '_label');
  if (!chk || !label) return;
  chk.checked     = active;
  label.className = 'wlw_toggle_label ' + (active ? 'tog_on' : 'tog_off');
  label.innerHTML = active ? labelOn : labelOff;
}

function syncAllToggles() {
  _syncToggle('tog_cron',
    custom_settings.wlw_cron_active === "1",
    'SCHEDULER ON',   'SCHEDULER OFF');
  _syncToggle('tog_fw',
    custom_settings.wlw_active      === "1",
    'BLOCK ACTIVE',   'BLOCK INACTIVE');
  _syncToggle('tog_persist',
    custom_settings.wlw_persist     === "1",
    'PERSISTENCE ON', 'PERSISTENCE OFF');
}

/* ----------------------------------------------------------------
   Load settings
---------------------------------------------------------------- */
function loadSettings() {
  /* Whitelist entries */
  if (custom_settings.wlw_entries !== undefined && custom_settings.wlw_entries !== "") {
    try {
      var raw = JSON.parse(custom_settings.wlw_entries);
      wlw_entries = [];
      for (var i = 0; i < raw.length; i++) {
        wlw_entries.push(_makeEntry(raw[i].type, raw[i].value));
      }
    } catch(e) { wlw_entries = []; }
  } else {
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

  /* Time fields */
  if (custom_settings.wlw_start_hh !== undefined) document.getElementById('wlw_start_hh').value = custom_settings.wlw_start_hh;
  if (custom_settings.wlw_start_mm !== undefined) document.getElementById('wlw_start_mm').value = custom_settings.wlw_start_mm;
  if (custom_settings.wlw_end_hh   !== undefined) document.getElementById('wlw_end_hh').value   = custom_settings.wlw_end_hh;
  if (custom_settings.wlw_end_mm   !== undefined) document.getElementById('wlw_end_mm').value   = custom_settings.wlw_end_mm;

  /* Days */
  wlw_days = _parseDays(custom_settings.wlw_days);

  /* Resolve map — read-only, written by service script.
     \u0020 in names is decoded automatically by JSON.parse. */
  try {
    if (custom_settings.wlw_resolve && custom_settings.wlw_resolve !== "")
      wlw_resolve = JSON.parse(custom_settings.wlw_resolve);
  } catch(e) { wlw_resolve = {}; }

  /* Client list — read-only, written by service script */
  try {
    if (custom_settings.wlw_clients && custom_settings.wlw_clients !== "")
      wlw_clients = JSON.parse(custom_settings.wlw_clients);
  } catch(e) { wlw_clients = []; }

  /* Interface list — read-only, written by service script */
  try {
    if (custom_settings.wlw_ifaces && custom_settings.wlw_ifaces !== "")
      wlw_ifaces = JSON.parse(custom_settings.wlw_ifaces);
  } catch(e) { wlw_ifaces = []; }
}

/* ----------------------------------------------------------------
   Day parsing / serialisation
---------------------------------------------------------------- */
function _parseDays(stored) {
  if (!stored || stored === "*" || stored === "0,1,2,3,4,5,6") {
    return [0,1,2,3,4,5,6];
  }
  var parts = stored.split(','), result = [];
  for (var i = 0; i < parts.length; i++) {
    var n = parseInt(parts[i], 10);
    if (!isNaN(n) && n >= 0 && n <= 6) result.push(n);
  }
  return result;
}

function _serialiseDays(days) {
  if (!days || days.length === 0 || days.length === 7) return "*";
  return days.slice().sort(function(a,b){return a-b;}).join(',');
}

/* ----------------------------------------------------------------
   Day-of-week picker
---------------------------------------------------------------- */
var DAY_LABELS = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];

function renderDayPicker() {
  var container = document.getElementById('wlw_day_picker_btns');
  if (!container) return;
  container.innerHTML = '';
  for (var d = 0; d < 7; d++) {
    (function(day) {
      var btn       = document.createElement('span');
      btn.className = 'wlw_day_btn' + (isDaySelected(day) ? ' day_on' : '');
      btn.id        = 'wlw_day_' + day;
      btn.title     = DAY_LABELS[day];
      btn.appendChild(document.createTextNode(DAY_LABELS[day]));
      btn.onclick   = function() { toggleDay(day); };
      container.appendChild(btn);
    })(d);
  }
}

function isDaySelected(d) {
  for (var i = 0; i < wlw_days.length; i++) {
    if (wlw_days[i] === d) return true;
  }
  return false;
}

function toggleDay(d) {
  if (isDaySelected(d)) {
    if (wlw_days.length === 1) {
      alert("At least one night must be selected.\nUse 'Every day' to re-select all.");
      return;
    }
    wlw_days = wlw_days.filter(function(x){ return x !== d; });
  } else {
    wlw_days.push(d);
  }
  var btn = document.getElementById('wlw_day_' + d);
  if (btn) btn.className = 'wlw_day_btn' + (isDaySelected(d) ? ' day_on' : '');
  updateDaysSummary();
}

function selectDays(preset) {
  switch (preset) {
    case 'all':      wlw_days = [0,1,2,3,4,5,6]; break;
    case 'weekdays': wlw_days = [1,2,3,4,5];      break;
    case 'weekends': wlw_days = [0,6];             break;
    case 'offset_weekdays': wlw_days = [0,1,2,3,4];             break;
    case 'offset_weekends': wlw_days = [5,6];             break;
  }
  renderDayPicker();
  updateDaysSummary();
}

function updateDaysSummary() {
  var el = document.getElementById('wlw_days_summary');
  if (!el) return;
  var s = _serialiseDays(wlw_days);
  if (s === '*') {
    el.innerHTML = 'Every day';
  } else {
    var names = wlw_days.slice().sort(function(a,b){return a-b;}).map(function(d){ return DAY_LABELS[d]; });
    el.innerHTML = names.join(', ');
  }
}

/* ----------------------------------------------------------------
   Pack settings
   NOTE: wlw_resolve, wlw_clients, wlw_ifaces are NOT packed.
   They are owned by the service script — packing them would
   overwrite fresh data with the stale values from this page load.
---------------------------------------------------------------- */
function packSettings() {
  var toSave = [];
  for (var i = 0; i < wlw_entries.length; i++) {
    toSave.push({ type: wlw_entries[i].type, value: wlw_entries[i].value });
  }
  custom_settings.wlw_entries     = JSON.stringify(toSave);
  custom_settings.wlw_start_hh    = document.getElementById('wlw_start_hh').value;
  custom_settings.wlw_start_mm    = document.getElementById('wlw_start_mm').value;
  custom_settings.wlw_end_hh      = document.getElementById('wlw_end_hh').value;
  custom_settings.wlw_end_mm      = document.getElementById('wlw_end_mm').value;
  custom_settings.wlw_days        = _serialiseDays(wlw_days);
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
   Actions — each reverts the toggle visually on cancel
---------------------------------------------------------------- */
function applySettings() {
  submitAction("restart_wlwindow", 5);
}

function cronControl(action) {
  if (!confirm("Are you sure you want to " + (action === 'enable' ? 'enable' : 'disable') + " the schedule?")) {
    _syncToggle('tog_cron', custom_settings.wlw_cron_active === "1", 'SCHEDULER ON', 'SCHEDULER OFF');
    return;
  }
  submitAction("restart_wlwindow_cron_" + action, 3);
}

function manualControl(action) {
  if (!confirm("Manually " + (action === 'start' ? 'activate' : 'deactivate') + " the firewall block now?")) {
    _syncToggle('tog_fw', custom_settings.wlw_active === "1", 'BLOCK ACTIVE', 'BLOCK INACTIVE');
    return;
  }
  submitAction("restart_wlwindow_" + action, 3);
}

function persistControl(action) {
  if (!confirm("Are you sure you want to " + (action === 'enable' ? 'enable' : 'disable') + " block persistence on reboot?")) {
    _syncToggle('tog_persist', custom_settings.wlw_persist === "1", 'PERSISTENCE ON', 'PERSISTENCE OFF');
    return;
  }
  submitAction("restart_wlwindow_persist_" + action, 3);
}

/* ----------------------------------------------------------------
   Name resolution helper
---------------------------------------------------------------- */
function _resolveEntry(type, value) {
  if (type === 'int') return { assigned: '', associated: '' };
  var r = wlw_resolve[value];
  return r ? r : { assigned: '', associated: '' };
}

/* ----------------------------------------------------------------
   Whitelist table
---------------------------------------------------------------- */
function renderTable() {
  var tbody = document.getElementById('wlw_tbody');
  tbody.innerHTML = "";

  if (wlw_entries.length === 0) {
    var tr = document.createElement('tr');
    tr.className = 'wlw_empty_row';
    tr.innerHTML = '<td colspan="4">No entries &mdash; use the form below to add MACs, IPs, or interfaces.</td>';
    tbody.appendChild(tr);
    return;
  }

  var order  = { mac: 0, ip: 1, int: 2 };
  var sorted = wlw_entries.slice().sort(function(a,b){ return order[a.type] - order[b.type]; });

  for (var i = 0; i < sorted.length; i++) {
    var entry   = sorted[i];
    var resolve = _resolveEntry(entry.type, entry.value);

    var badge;
    if      (entry.type === 'mac') badge = '<span class="wlw_type_badge wlw_type_mac">MAC</span>';
    else if (entry.type === 'ip')  badge = '<span class="wlw_type_badge wlw_type_ip">IP</span>';
    else                           badge = '<span class="wlw_type_badge wlw_type_int">IFACE</span>';

    var nameHtml = '';
    if (resolve.assigned && resolve.associated) {
      nameHtml = '<span class="wlw_name_assigned">'
               + escapeHtml(resolve.assigned)
               + ' <span class="wlw_name_associated">(' + escapeHtml(resolve.associated) + ')</span>'
               + '</span>';
    } else if (resolve.assigned) {
      nameHtml = '<span class="wlw_name_assigned">' + escapeHtml(resolve.assigned) + '</span>';
    } else if (resolve.associated) {
      nameHtml = '<span class="wlw_name_associated">' + escapeHtml(resolve.associated) + '</span>';
    } else {
      nameHtml = '<span class="wlw_name_none">&mdash;</span>';
    }

    var tr = document.createElement('tr');
    tr.innerHTML =
      '<td style="width:60px; text-align:center;">' + badge + '</td>' +
      '<td style="font-family:monospace;">'          + escapeHtml(entry.value) + '</td>' +
      '<td>'                                         + nameHtml + '</td>' +
      '<td style="width:80px; text-align:right;">' +
        '<button class="wlw_icon_btn btn_remove" title="Remove" onclick="deleteEntry(' + entry._uid + ');return false;">&minus;</button>' +
      '</td>';
    tbody.appendChild(tr);
  }
}

/* ----------------------------------------------------------------
   Add-entry dropdown
---------------------------------------------------------------- */
function onTypeChange() {
  var type = document.getElementById('wlw_new_type').value;
  var sel  = document.getElementById('wlw_client_sel');
  var inp  = document.getElementById('wlw_new_value');

  sel.innerHTML     = '';
  sel.style.display = 'none';
  inp.value         = '';

  if (type === 'int') {
    _populateInterfaceDropdown(sel, inp);
  } else {
    _populateClientDropdown(sel, inp, type);
  }
}

function _isWhitelisted(val) {
  for (var k = 0; k < wlw_entries.length; k++) {
    if (wlw_entries[k].value === val) return true;
  }
  return false;
}

function _populateInterfaceDropdown(sel, inp) {
  inp.placeholder = 'e.g. wl0.1, wl0.2, eth5, eth6 \u2026';
  if (wlw_ifaces.length === 0) return;

  var ph = document.createElement('option');
  ph.value = ''; ph.textContent = '\u2014 pick interface \u2014';
  sel.appendChild(ph);

  var added = 0;
  for (var i = 0; i < wlw_ifaces.length; i++) {
    if (_isWhitelisted(wlw_ifaces[i].value)) continue;
    var opt = document.createElement('option');
    opt.value       = wlw_ifaces[i].value;
    opt.textContent = wlw_ifaces[i].label;
    sel.appendChild(opt);
    added++;
  }

  if (added > 0) sel.style.display = '';
}

function _populateClientDropdown(sel, inp, type) {
  inp.placeholder = type === 'mac'
    ? 'e.g. aa:bb:cc:dd:ee:ff \u2026'
    : 'e.g. 192.168.1.40 or 2001:0db8:85a3:0000:0000:8a2e:0370:7334 \u2026';
  if (wlw_clients.length === 0) return;

  var ph = document.createElement('option');
  ph.value = ''; ph.textContent = '\u2014 pick client \u2014';
  sel.appendChild(ph);

  var sorted = wlw_clients.slice().sort(function(a, b) {
    if (a.status !== b.status) return a.status === 'ACTIVE' ? -1 : 1;
    var na = a.assigned || a.associated || a.value;
    var nb = b.assigned || b.associated || b.value;
    return na.localeCompare(nb);
  });

  var added = 0;
  for (var j = 0; j < sorted.length; j++) {
    var c   = sorted[j];
    var val = (type === 'mac') ? c.value : c.ip;
    if (!val || _isWhitelisted(val)) continue;

    var displayName = c.assigned || c.associated || val;
    var subName     = (c.assigned && c.associated) ? ' (' + c.associated + ')' : '';
    var label       = displayName + subName + ' \u2014 ' + c.status + ' [' + val + ']';

    var opt = document.createElement('option');
    opt.value       = val;
    opt.textContent = label;
    opt.className   = (c.status === 'ACTIVE') ? 'wlw_opt_active' : 'wlw_opt_inactive';
    sel.appendChild(opt);
    added++;
  }

  if (added > 0) sel.style.display = '';
}

function onClientSelect(val) {
  if (!val) return;
  document.getElementById('wlw_new_value').value = val;
}

/* ----------------------------------------------------------------
   Add / delete entries
---------------------------------------------------------------- */
function addEntry() {
  var type  = document.getElementById('wlw_new_type').value;
  var value = document.getElementById('wlw_new_value').value.trim().toLowerCase();
  if (value === "") { alert("Please enter or select a value."); return; }

  if (type === "mac") {
    if (!value.match(/^([0-9a-f]{2}:){5}[0-9a-f]{2}$/)) {
      alert("Invalid MAC address.\nExpected format: xx:xx:xx:xx:xx:xx"); return;
    }
  } else if (type === "ip") {
    var isIPv4 = /^(\d{1,3}\.){3}\d{1,3}$/.test(value);
    var isIPv6 = value.indexOf(':') !== -1 && /^[0-9a-f:\/]+$/.test(value);
    if (!isIPv4 && !isIPv6) { alert("Invalid IP address."); return; }
    if (isIPv4) {
      var octets = value.split('.');
      for (var o = 0; o < octets.length; o++) {
        if (parseInt(octets[o], 10) > 255) { alert("Invalid IPv4 address \u2014 octet out of range."); return; }
      }
    }
  } else if (type === "int") {
    if (!value.match(/^[a-z0-9._-]+$/i)) {
      alert("Invalid interface name.\nExpected: eth5, wl0.1, wl0.2, etc."); return;
    }
  }

  if (_isWhitelisted(value)) { alert("Already in the whitelist."); return; }

  wlw_entries.push(_makeEntry(type, value));
  document.getElementById('wlw_new_value').value = "";

  renderTable();
  onTypeChange();
}

function deleteEntry(uid) {
  var idx = -1;
  for (var i = 0; i < wlw_entries.length; i++) {
    if (wlw_entries[i]._uid === uid) { idx = i; break; }
  }
  if (idx === -1) return;
  if (!confirm('Remove "' + wlw_entries[idx].value + '" from the whitelist?')) return;
  wlw_entries.splice(idx, 1);

  renderTable();
  onTypeChange();
}

/* ----------------------------------------------------------------
   Utilities
---------------------------------------------------------------- */
function escapeHtml(s) {
  return String(s)
    .replace(/&/g,"&amp;").replace(/</g,"&lt;")
    .replace(/>/g,"&gt;").replace(/"/g,"&quot;");
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
          Blocks all internet access inside the scheduled window<strong> except for whitelisted
          MACs, IPs, and interfaces</strong>.
          <br>
          The purpose of this addon/script is to prevent <strong>clients</strong> from <strong>bypassing</strong> internet access restrictions with <strong>MAC randomization</strong>.
        </div>


        <!-- ========== SCHEDULE / CRON CONTROL ==================== -->
        <div class="wlw_section_label" style="margin-top:16px;">Internet Access Management</div>
        <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0"
               bordercolor="#6b8fa3" class="FormTable">

          <tr>
            <th style="width:160px;" class="wlw_th_mid">Scheduler (Cron)</th>
            <td>
              <div class="wlw_toggle_wrap">
                <label class="wlw_toggle">
                  <input type="checkbox" id="tog_cron"
                         onchange="cronControl(this.checked ? 'enable' : 'disable');">
                  <span class="wlw_toggle_track"></span>
                </label>
                <span class="wlw_toggle_label tog_off" id="tog_cron_label">SCHEDULER OFF</span>
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
              <span class="wlw_hint">&nbsp;24-hour &middot; block activates at this time</span>
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
              <span class="wlw_hint">&nbsp;24-hour &middot; block lifts at this time</span>
            </td>
          </tr>

          <tr>
            <th class="wlw_th_mid">Days (<span id="wlw_days_summary"></span> )
              <div style="margin-top:8px; padding:8px 10px; background:#2a1f0a; border:1px solid #7a5a1a; border-radius:3px;">
                <span style="background:#2a1f0a; color:#e0a840; font-size:11px; font-weight:bold; letter-spacing:0.5px;">&#9888;&nbsp;MIDNIGHT SCHEDULE NOTE</span>
                <div style="color:#c0944a; font-size:11px; margin-top:4px; line-height:1.6;">
                  If the block schedule crosses midnight, be mindful of when the overlapping day starts/ends.
                </div>
              </div>
            </th>
            <td>
              <div id="wlw_day_picker_btns" class="wlw_day_picker"></div>
              <div class="wlw_day_shortcut_bar">
                <button class="wlw_day_shortcut" onclick="selectDays('all');return false;">Every day</button>
                <button class="wlw_day_shortcut" onclick="selectDays('weekdays');return false;">Weekdays (Mon&ndash;Fri)</button>
                <button class="wlw_day_shortcut" onclick="selectDays('weekends');return false;">Weekends (Sat&ndash;Sun)</button>
              </div>
              <div class="wlw_day_shortcut_bar">
                <button class="wlw_day_shortcut" onclick="selectDays('offset_weekdays');return false;">Midnight Weekdays (Mon&ndash;Fri)</button>
                <button class="wlw_day_shortcut" onclick="selectDays('offset_weekends');return false;">Midnight Weekends (Sat&ndash;Sun)</button>
              </div>
              <div class="wlw_hint" style="margin-top:4px;">
                Click a day to toggle it. Changes take effect after Apply.
              </div>
            </td>
          </tr>

          <tr>
            <th style="width:160px;" class="wlw_th_mid">Internet Access Block (Manual Control)</th>
            <td>
              <div class="wlw_toggle_wrap">
                <label class="wlw_toggle">
                  <input type="checkbox" id="tog_fw"
                         onchange="manualControl(this.checked ? 'start' : 'stop');">
                  <span class="wlw_toggle_track"></span>
                </label>
                <span class="wlw_toggle_label tog_off" id="tog_fw_label">BLOCK INACTIVE</span>
              </div>
            </td>
          </tr>

          <tr>
            <th style="width:160px;" class="wlw_th_mid">Block Persistence (Survives Reboot)</th>
            <td>
              <div class="wlw_toggle_wrap">
                <label class="wlw_toggle">
                  <input type="checkbox" id="tog_persist"
                         onchange="persistControl(this.checked ? 'enable' : 'disable');">
                  <span class="wlw_toggle_track"></span>
                </label>
                <span class="wlw_toggle_label tog_off" id="tog_persist_label">PERSISTENCE OFF</span>
              </div>
            </td>
          </tr>

        </table>

        <div style="margin-top:8px; padding:8px 10px; background:#2a1f0a; border:1px solid #7a5a1a; border-radius:3px;">
          <span style="color:#e0a840; font-size:11px; font-weight:bold; letter-spacing:0.5px;">&#9888;&nbsp;BLOCK PERSISTENCE</span>
          <div style="color:#c0944a; font-size:11px; margin-top:4px; line-height:1.6;">
            Only use this if rebooting the router to bypass the block is an actual concern.
            If clients are configured incorrectly it can cause a permanent lockout requiring a hard reset.
            Test your settings thoroughly before enabling.
          </div>
        </div>

        <!-- ========== WHITELIST TABLE ============================= -->
        <div class="wlw_section_label" style="margin-top:8px;">Whitelist Management ( <span style="font-weight: normal;">Press Apply to populate/refresh dropdown with existing clients</span> )</div>
        <table id="wlw_entry_table" width="100%" border="1" align="center"
               cellpadding="0" cellspacing="0" bordercolor="#6b8fa3"
               class="FormTable" style="table-layout:fixed;">
          <thead>
          </thead>
            <tr style="background:#3a5060 !important; color:#7a9aaa; font-size:12px;">
              <td style="width: max-content;  padding:8px 10px; text-align:center;">
                <select id="wlw_new_type" class="wlw_type_sel" style="width:100%;"
                        onchange="onTypeChange();">
                  <option value="mac">MAC</option>
                  <option value="ip">IP</option>
                  <option value="int">IFACE</option>
                </select>
              </td>
              <td colspan="2" style="width:80%; padding:8px 10px; text-align:center;">
                <div class="wlw_add_row_inner">
                  <input type="text" id="wlw_new_value" class="wlw_value_input"
                         placeholder="e.g. aa:bb:cc:dd:ee:ff ..."
                         autocorrect="off" autocapitalize="off" autocomplete="on"
                         onkeydown="wlw_keydown(event);">
                  <select id="wlw_client_sel" class="wlw_client_sel"
                          style="display:none;"
                          onchange="onClientSelect(this.value);">
                  </select>
                </div>
              </td>
              <td style="width: max-content; text-align:right;">
                <button class="wlw_icon_btn btn_add" title="Add" onclick="addEntry();return false;">+</button>
              </td>
            </tr>

          <tbody id="wlw_tbody"></tbody>

          <tfoot>
            
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
