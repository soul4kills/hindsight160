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
  /* Status pill */
  #wlw_status_pill {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    padding: 3px 12px 3px 8px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: bold;
    letter-spacing: 0.5px;
    vertical-align: middle;
    margin-left: 10px;
  }
  #wlw_status_pill.pill_active   { background: #1a3d1a; border: 1px solid #3a7a3a; color: #7fdd7f; }
  #wlw_status_pill.pill_inactive { background: #2e2e2e; border: 1px solid #555;    color: #888888; }
  #wlw_status_dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
  .pill_active   #wlw_status_dot { background: #7fdd7f; box-shadow: 0 0 5px #7fdd7f; }
  .pill_inactive #wlw_status_dot { background: #555555; }

  /* Type badges */
  .wlw_type_badge {
    display: inline-block; padding: 1px 7px; border-radius: 2px;
    font-size: 11px; font-weight: bold; letter-spacing: 0.5px;
  }
  .wlw_type_mac { background: #2a6496; color: #fff; }
  .wlw_type_ip  { background: #5b5ea6; color: #fff; }
  .wlw_type_int { background: #3c763d; color: #fff; }

  /* Whitelist table */
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
    padding: 2px 10px; cursor: pointer; font-size: 11px; border-radius: 2px;
  }
  .wlw_del_btn:hover { background: #7a2020; color: #fff; }

  /* Section labels */
  .wlw_section_label {
    color: #93b0bd; font-size: 11px; font-weight: bold;
    text-transform: uppercase; letter-spacing: 1px; padding: 10px 0 4px 0;
  }

  /* Add entry inputs */
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

  /* Manual control */
  .wlw_ctrl_bar { display: flex; align-items: center; gap: 10px; padding: 8px 4px; flex-wrap: wrap; }
  .wlw_start_btn {
    background: #1a3d1a; border: 1px solid #3a7a3a; color: #7fdd7f;
    padding: 5px 20px; cursor: pointer; font-size: 12px; font-weight: bold;
    border-radius: 2px; letter-spacing: 0.5px;
  }
  .wlw_start_btn:hover { background: #245c24; color: #fff; }
  .wlw_stop_btn {
    background: #3d1a1a; border: 1px solid #7a3a3a; color: #dd7f7f;
    padding: 5px 20px; cursor: pointer; font-size: 12px; font-weight: bold;
    border-radius: 2px; letter-spacing: 0.5px;
  }
  .wlw_stop_btn:hover { background: #5c2424; color: #fff; }

  .wlw_hint { color: #7a9aaa; font-size: 11px; margin-top: 4px; }
  .wlw_empty_row td { color: #556a76; font-style: italic; text-align: center; padding: 12px; }
</style>

<script type="text/javascript" language="JavaScript">

var custom_settings = <% get_custom_settings(); %>;
var wlw_entries = [];

function initial() {
  SetCurrentPage();
  show_menu();
  loadSettings();
  renderTable();
  updateStatusPill();
}

function SetCurrentPage() {
  document.form.next_page.value    = window.location.pathname.substring(1);
  document.form.current_page.value = window.location.pathname.substring(1);
}

/* Status pill 
   wlw_active is written by wl_window.sh into custom_settings.txt
   on every start/stop. "1" = active, anything else = inactive.   */
function updateStatusPill() {
  var pill  = document.getElementById('wlw_status_pill');
  var label = document.getElementById('wlw_status_label');
  var active = (custom_settings.wlw_active === "1");
  pill.className  = active ? 'pill_active' : 'pill_inactive';
  label.innerHTML = active ? 'ACTIVE' : 'INACTIVE';
}

/* Load settings */
function loadSettings() {
  if (custom_settings.wlw_entries !== undefined && custom_settings.wlw_entries !== "") {
    try { wlw_entries = JSON.parse(custom_settings.wlw_entries); }
    catch(e) { wlw_entries = []; }
  } else {
    wlw_entries = [
      { type:"mac", value:"AA:BB:CC:DD:EE:FF" },
      { type:"mac", value:"11:22:33:44:55:66" },
      { type:"int", value:"wl0.1" },
      { type:"int", value:"wl0.2" },
      { type:"ip",  value:"192.168.1.50" },
      { type:"ip",  value:"192.168.1.100" }
    ];
  }

  if (custom_settings.wlw_start_hh !== undefined) document.getElementById('wlw_start_hh').value = custom_settings.wlw_start_hh;
  if (custom_settings.wlw_start_mm !== undefined) document.getElementById('wlw_start_mm').value = custom_settings.wlw_start_mm;
  if (custom_settings.wlw_end_hh   !== undefined) document.getElementById('wlw_end_hh').value   = custom_settings.wlw_end_hh;
  if (custom_settings.wlw_end_mm   !== undefined) document.getElementById('wlw_end_mm').value   = custom_settings.wlw_end_mm;
}

/* Pack custom_settings into amng_custom before any submit 
   This must be called before every form submit so Merlin persists
   the current state regardless of which button was pressed.       */
function packSettings() {
  custom_settings.wlw_entries  = JSON.stringify(wlw_entries);
  custom_settings.wlw_start_hh = document.getElementById('wlw_start_hh').value;
  custom_settings.wlw_start_mm = document.getElementById('wlw_start_mm').value;
  custom_settings.wlw_end_hh   = document.getElementById('wlw_end_hh').value;
  custom_settings.wlw_end_mm   = document.getElementById('wlw_end_mm').value;
  document.getElementById('amng_custom').value = JSON.stringify(custom_settings);
}

/* Apply / Save */
function applySettings() {
  packSettings();
  document.form.action_script.value = "restart_wlwindow";
  document.form.action_wait.value   = "5";
  showLoading();
  document.form.submit();
}

/* Manual start / stop 
   action_script = "restart_wlwindow_start" means Merlin calls:
     /jffs/scripts/service-event restart wlwindow_start
   action_script = "restart_wlwindow_stop" means Merlin calls:
     /jffs/scripts/service-event restart wlwindow_stop           */
function manualControl(action) {
  var label = (action === 'start') ? 'activate' : 'deactivate';
  if (!confirm("Manually " + label + " the block now?")) return;
  packSettings();
  document.form.action_script.value = "restart_wlwindow_" + action;
  document.form.action_wait.value   = "3";
  showLoading();
  document.form.submit();
}

/* Render whitelist table */
function renderTable() {
  var tbody = document.getElementById('wlw_tbody');
  tbody.innerHTML = "";

  if (wlw_entries.length === 0) {
    var tr = document.createElement('tr');
    tr.className = 'wlw_empty_row';
    tr.innerHTML = '<td colspan="3">No entries Ã¢â‚¬â€ use the form below to add MACs, IPs, or interfaces.</td>';
    tbody.appendChild(tr);
    return;
  }

  var order  = { mac:0, ip:1, int:2 };
  var sorted = wlw_entries.slice().sort(function(a,b){ return order[a.type] - order[b.type]; });

  for (var i = 0; i < sorted.length; i++) {
    var entry   = sorted[i];
    var realIdx = wlw_entries.indexOf(entry);
    var badge;
    if      (entry.type === 'mac') badge = '<span class="wlw_type_badge wlw_type_mac">MAC</span>';
    else if (entry.type === 'ip')  badge = '<span class="wlw_type_badge wlw_type_ip">IP</span>';
    else                           badge = '<span class="wlw_type_badge wlw_type_int">IFACE</span>';

    var tr = document.createElement('tr');
    tr.innerHTML =
      '<td style="width:70px;">' + badge + '</td>' +
      '<td style="font-family:monospace;">' + escapeHtml(entry.value) + '</td>' +
      '<td style="width:70px;text-align:right;">' +
        '<button class="wlw_del_btn" onclick="deleteEntry(' + realIdx + ');return false;">Remove</button>' +
      '</td>';
    tbody.appendChild(tr);
  }
}

/* Add entry */
function addEntry() {
  var type  = document.getElementById('wlw_new_type').value;
  var value = document.getElementById('wlw_new_value').value.trim().toLowerCase();
  if (value === "") { alert("Please enter a value."); return; }

  if (type === "mac" && !value.match(/^([0-9a-f]{2}:){5}[0-9a-f]{2}$/)) {
    alert("Invalid MAC address.\nExpected: xx:xx:xx:xx:xx:xx"); return;
  }
  if (type === "ip") {
    var v4 = /^(\d{1,3}\.){3}\d{1,3}$/.test(value);
    var v6 = /^[0-9a-f:]+$/.test(value) && value.indexOf(':') !== -1;
    if (!v4 && !v6) { alert("Invalid IP address."); return; }
  }
  if (type === "int" && !value.match(/^[a-z0-9._-]+$/i)) {
    alert("Invalid interface name.\nExpected: eth0, wl0.1, br0, etc."); return;
  }
  for (var i = 0; i < wlw_entries.length; i++) {
    if (wlw_entries[i].value === value) { alert("Already in the whitelist."); return; }
  }
  wlw_entries.push({ type: type, value: value });
  document.getElementById('wlw_new_value').value = "";
  renderTable();
}

/*  Delete entry */
function deleteEntry(idx) {
  if (!confirm('Remove "' + wlw_entries[idx].value + '" from the whitelist?')) return;
  wlw_entries.splice(idx, 1);
  renderTable();
}

/*  Utility */
function escapeHtml(s) {
  return String(s).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;");
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

        <!-- Title + status pill -->
        <div style="display:flex;align-items:center;flex-wrap:wrap;gap:6px;">
          <span class="formfonttitle">Whitelist Window &mdash; Internet Access Scheduler</span>
          <span id="wlw_status_pill" class="pill_inactive">
            <span id="wlw_status_dot"></span>
            <span id="wlw_status_label">INACTIVE</span>
          </span>
        </div>

        <div style="margin:10px 0 10px 5px;" class="splitLine"></div>
        <div class="formfontdesc">
          Blocks all internet access outside the scheduled window, except for whitelisted
          MACs, IPs, and interfaces. Settings are stored in
          <code>/jffs/addons/custom_settings.txt</code> and override the script's
          built-in defaults at runtime.
        </div>

        <!-- Â SCHEDULE Â -->
        <div class="wlw_section_label" style="margin-top:16px;">Block Schedule</div>
        <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0"
               bordercolor="#6b8fa3" class="FormTable">
          <tr>
            <th style="width:160px;">Block Start (HH:MM)</th>
            <td>
              <input type="text" id="wlw_start_hh" maxlength="2" class="input_6_table"
                     value="22" style="width:38px;text-align:center;" autocorrect="off">
              &nbsp;:&nbsp;
              <input type="text" id="wlw_start_mm" maxlength="2" class="input_6_table"
                     value="00" style="width:38px;text-align:center;" autocorrect="off">
              <span class="wlw_hint">&nbsp;24-hour Ã¢â‚¬â€ block activates at this time nightly</span>
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
              <span class="wlw_hint">&nbsp;24-hour Ã¢â‚¬â€ block is lifted at this time</span>
            </td>
          </tr>
        </table>

        <!-- Â WHITELIST TABLE Â -->
        <div class="wlw_section_label" style="margin-top:20px;">Whitelisted Entries</div>
        <table width="100%" border="1" align="center" cellpadding="0" cellspacing="0"
               bordercolor="#6b8fa3" class="FormTable">
          <tr>
            <td colspan="2" style="padding:0;">
              <table id="wlw_entry_table">
                <thead>
                  <tr>
                    <th style="width:70px;">Type</th>
                    <th>Value</th>
                    <th style="width:70px;text-align:right;">Action</th>
                  </tr>
                </thead>
                <tbody id="wlw_tbody"></tbody>
              </table>
            </td>
          </tr>
          <tr>
            <th style="width:160px;">Add Entry</th>
            <td style="padding:8px 10px;">
              <select id="wlw_new_type" class="wlw_type_sel">
                <option value="mac">MAC Address</option>
                <option value="ip">IP Address</option>
                <option value="int">Interface</option>
              </select>
              <input type="text" id="wlw_new_value" class="wlw_value_input"
                     placeholder="e.g. aa:bb:cc:dd:ee:ff  /  192.168.1.x  /  wl0.2"
                     autocorrect="off" autocapitalize="off" autocomplete="off"
                     onkeydown="wlw_keydown(event);">
              <button class="wlw_add_btn" onclick="addEntry();return false;">+ Add</button>
              <div class="wlw_hint">
                MAC: <code>xx:xx:xx:xx:xx:xx</code> &nbsp;|&nbsp;
                IP: IPv4 or IPv6 &nbsp;|&nbsp;
                Interface: <code>wl0.1</code>, <code>eth0</code>, <code>br0</code>&hellip;
              </div>
            </td>
          </tr>
        </table>

        <!-- MANUAL CONTROL -->
        <div class="wlw_section_label" style="margin-top:20px;">Manual Control</div>
        <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0"
               bordercolor="#6b8fa3" class="FormTable">
          <tr>
            <th style="width:160px;">Firewall Block</th>
            <td>
              <div class="wlw_ctrl_bar">
                <button class="wlw_start_btn" onclick="manualControl('start');return false;">&#9654;&nbsp;Activate Block</button>
                <button class="wlw_stop_btn"  onclick="manualControl('stop');return false;">&#9632;&nbsp;Deactivate Block</button>
                <span class="wlw_hint">Takes effect immediately. Reload the page after to see updated status.</span>
              </div>
            </td>
          </tr>
        </table>

        <!--  APPLY  -->
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
