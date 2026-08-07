// Live-reload client for p5.nvim.
//
// Upstream ships this path in .gitignore behind negation patterns that git
// cannot honour (a file can't be re-included once its parent dir is excluded),
// so `assets/inject/livereload.js` is missing from every clone and server.py's
// injection silently no-ops. This is our replacement, installed into the plugin
// by the p5 block in lua/custom/plugins/init.lua.
//
// Contract with server.py:
//   - served raw and wrapped in a script element, so emit no tags here
//   - `__LR_PORT__` is substituted with the port the ws server actually bound
//     (it falls back upward when the configured port is taken)
//   - messages are JSON; {"type":"reload"} means re-fetch the page
(function () {
  if (window.__p5NvimLiveReload) return;
  window.__p5NvimLiveReload = true;

  var PORT = '__LR_PORT__';
  var URL = 'ws://' + (location.hostname || 'localhost') + ':' + PORT;

  var ws;
  var attempt = 0;
  var timer;

  function schedule() {
    clearTimeout(timer);
    attempt = Math.min(attempt + 1, 10);
    // Back off to a 5s ceiling so a stopped server doesn't spin the tab.
    timer = setTimeout(connect, Math.min(500 * attempt, 5000));
  }

  function connect() {
    try {
      ws = new WebSocket(URL);
    } catch (e) {
      schedule();
      return;
    }

    ws.onopen = function () {
      attempt = 0;
    };

    ws.onmessage = function (event) {
      var msg;
      try {
        msg = JSON.parse(event.data);
      } catch (e) {
        return;
      }
      if (msg && msg.type === 'reload') {
        location.reload();
      }
    };

    // Server restarts land here; reconnect so reload survives `:P5 server` cycles.
    ws.onclose = function () {
      schedule();
    };

    ws.onerror = function () {
      try {
        ws.close();
      } catch (e) {}
    };
  }

  connect();
})();
