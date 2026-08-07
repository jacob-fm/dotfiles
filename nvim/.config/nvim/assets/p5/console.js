// Console-forwarding client for p5.nvim.
//
// Missing from every clone for the same reason as livereload.js: upstream's
// .gitignore excludes `assets/inject/` and then tries to re-include the files
// inside it, which git cannot do. server.py wraps INJECT_CONSOLE in a script
// element unconditionally, so without this the page gets an empty one and
// `:P5 console` shows nothing.
//
// Contract with server.py:
//   - served raw and wrapped in a script element, so emit no tags here
//   - POST JSON to /api/console/log, either one entry or
//     {"type":"console_batch","logs":[...]}
//   - each entry is read for `level`, `message`, `source`; the server stamps
//     `timestamp` itself and renders via format_log_entry()
//   - levels are lowercased before lookup; error/warn/info/log get colours,
//     anything else falls back to log's colour
(function () {
  if (window.__p5NvimConsole) return;
  window.__p5NvimConsole = true;

  var ENDPOINT = location.origin + '/api/console/log';
  var FLUSH_MS = 120;
  var MAX_BATCH = 50;
  // draw() runs 60x/sec; a logging sketch can outrun the network. Drop rather
  // than grow without bound, and tell the user we dropped.
  var MAX_QUEUE = 500;
  var MAX_LEN = 4000;

  var queue = [];
  var dropped = 0;
  var timer = null;
  var sending = false;
  // Re-entrancy guard: our own failures must never route back through console.*.
  var inside = false;

  var native = {
    log: console.log.bind(console),
    info: console.info.bind(console),
    warn: console.warn.bind(console),
    error: console.error.bind(console),
    debug: console.debug.bind(console),
  };

  function stringify(value, seen) {
    if (value === null) return 'null';
    if (value === undefined) return 'undefined';

    var t = typeof value;
    if (t === 'string') return value;
    if (t === 'number' || t === 'boolean' || t === 'bigint') return String(value);
    if (t === 'function') return '[Function: ' + (value.name || 'anonymous') + ']';
    if (t === 'symbol') return value.toString();

    if (value instanceof Error) {
      return value.stack || value.name + ': ' + value.message;
    }
    if (typeof Element !== 'undefined' && value instanceof Element) {
      return '<' + value.tagName.toLowerCase() + '>';
    }

    // Circular structures are common in p5 (objects hold refs back to the sketch),
    // and JSON.stringify throws on them -- so the replacer has to break cycles
    // itself rather than letting the throw fall through to a useless
    // "[object Object]" from Object.prototype.toString.
    seen = seen || [];
    if (seen.indexOf(value) !== -1) return '[Circular]';
    seen.push(value);

    try {
      if (Array.isArray(value)) {
        var parts = [];
        for (var i = 0; i < value.length && i < 100; i++) {
          parts.push(stringify(value[i], seen));
        }
        if (value.length > 100) parts.push('… ' + (value.length - 100) + ' more');
        return '[' + parts.join(', ') + ']';
      }

      var stack = [];
      return JSON.stringify(value, function (key, val) {
        if (typeof val === 'bigint') return String(val);
        if (val === null || typeof val !== 'object') return val;
        // `this` is the container being serialised; unwind once we leave it.
        while (stack.length && stack[stack.length - 1] !== this) stack.pop();
        if (stack.indexOf(val) !== -1) return '[Circular]';
        stack.push(val);
        return val;
      });
    } catch (e) {
      // p5 instances and DOM-adjacent objects can still defeat serialisation.
      try {
        return Object.prototype.toString.call(value);
      } catch (e2) {
        return '[Unserializable]';
      }
    } finally {
      seen.pop();
    }
  }

  function format(args) {
    var out = [];
    for (var i = 0; i < args.length; i++) out.push(stringify(args[i]));
    var msg = out.join(' ');
    if (msg.length > MAX_LEN) msg = msg.slice(0, MAX_LEN) + '… [truncated]';
    return msg;
  }

  function enqueue(level, message, source) {
    if (queue.length >= MAX_QUEUE) {
      dropped++;
      return;
    }
    queue.push({ level: level, message: message, source: source || 'browser' });
    if (!timer) timer = setTimeout(flush, FLUSH_MS);
  }

  function flush() {
    timer = null;
    if (sending || !queue.length) return;

    var batch = queue.splice(0, MAX_BATCH);
    if (dropped) {
      batch.push({
        level: 'warn',
        message: dropped + ' console message(s) dropped (rate limit)',
        source: 'p5.nvim',
      });
      dropped = 0;
    }

    sending = true;
    inside = true;
    var done = function () {
      sending = false;
      inside = false;
      if (queue.length && !timer) timer = setTimeout(flush, FLUSH_MS);
    };

    try {
      fetch(ENDPOINT, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ type: 'console_batch', logs: batch }),
        keepalive: true,
      }).then(done, done);
    } catch (e) {
      done();
    }
  }

  function wrap(name, level) {
    console[name] = function () {
      try {
        native[name].apply(console, arguments);
      } catch (e) {}
      if (!inside) {
        try {
          enqueue(level, format(arguments));
        } catch (e) {}
      }
    };
  }

  wrap('log', 'log');
  wrap('info', 'info');
  wrap('warn', 'warn');
  wrap('error', 'error');
  wrap('debug', 'debug');

  // Uncaught errors are the whole point of a sketch console -- a p5 typo throws
  // from draw() and otherwise never reaches nvim.
  window.addEventListener('error', function (event) {
    var where = '';
    if (event.filename) {
      where =
        ' (' +
        String(event.filename).split('/').pop() +
        ':' +
        (event.lineno || 0) +
        ':' +
        (event.colno || 0) +
        ')';
    }
    var msg = event.error && event.error.stack ? event.error.stack : event.message;
    enqueue('error', String(msg) + where, 'uncaught');
  });

  window.addEventListener('unhandledrejection', function (event) {
    enqueue('error', 'Unhandled promise rejection: ' + stringify(event.reason), 'uncaught');
  });

  // Don't lose the tail of the buffer when the page reloads (live reload does).
  window.addEventListener('pagehide', flush);
})();
