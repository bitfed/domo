var colors, irc, util, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __slice = [].slice;

colors = require('colors');

irc = require('irc');

_ = require('underscore');

util = require('util');

module.exports = (function(_super) {
  __extends(exports, _super);

  function exports() {
    this.moduleInstance = __bind(this.moduleInstance, this);
    this.unload = __bind(this.unload, this);
    this.load = __bind(this.load, this);
    var module, _i, _len, _ref;
    this.middlewares = [];
    this.modules = {};
    exports.__super__.constructor.apply(this, arguments);
    this.on('error', function(event) {
      return this.error(JSON.stringify(event.command.toUpperCase()));
    });
    if (this.opt.modules != null) {
      _ref = this.opt.modules;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        module = _ref[_i];
        this.load(module);
      }
    }
  }

  exports.prototype.connect = function() {
    this.info("Connecting to " + this.opt.server);
    exports.__super__.connect.apply(this, arguments);
    return this.once('registered', function() {
      return this.info("Connected to " + this.opt.server);
    });
  };

  exports.prototype.log = function() {
    var arg, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = arguments.length; _i < _len; _i++) {
      arg = arguments[_i];
      _results.push(util.log(arg, {
        colors: true
      }));
    }
    return _results;
  };

  exports.prototype.info = function() {
    var arg, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = arguments.length; _i < _len; _i++) {
      arg = arguments[_i];
      _results.push(util.log('Info: '.green + util.inspect(arg, {
        colors: true
      })));
    }
    return _results;
  };

  exports.prototype.warn = function() {
    var arg, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = arguments.length; _i < _len; _i++) {
      arg = arguments[_i];
      _results.push(util.log('Warn: '.yellow + util.inspect(arg, {
        colors: true
      })));
    }
    return _results;
  };

  exports.prototype.error = function() {
    var arg, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = arguments.length; _i < _len; _i++) {
      arg = arguments[_i];
      _results.push(util.log('Error: '.red + util.inspect(arg, {
        colors: true
      })));
    }
    return _results;
  };

  exports.prototype.load = function(moduleName, moduleClass) {
    var err, msg;
    if (moduleClass == null) {
      try {
        moduleClass = require(moduleName);
      } catch (_error) {
        err = _error;
        msg = err.code === 'MODULE_NOT_FOUND' ? "Module " + moduleName + " not found" : "Module " + moduleName + " cannot be loaded";
        return this.error(msg, err.message);
      }
    }
    if (this.modules.hasOwnProperty(moduleName)) {
      return this.error("Module " + moduleName + " already loaded");
    }
    this.modules[moduleName] = new moduleClass(this.moduleInstance(moduleName));
    return this.info("Loaded module " + moduleName);
  };

  exports.prototype.unload = function(moduleName, inRequireCache) {
    var eventName, events, _base, _ref;
    if (inRequireCache == null) {
      inRequireCache = true;
    }
    if (!this.modules.hasOwnProperty(moduleName)) {
      return this.error("Module " + mod + " not loaded");
    }
    if (typeof (_base = this.modules[moduleName]).destruct === "function") {
      _base.destruct();
    }
    if (inRequireCache) {
      delete require.cache[require.resolve(moduleName)];
    }
    delete this.modules[moduleName];
    _ref = this._events;
    for (eventName in _ref) {
      events = _ref[eventName];
      if (_.isArray(events)) {
        this._events[eventName] = _.filter(events, function(event) {
          return (event.moduleName == null) || event.moduleName !== moduleName;
        });
        break;
      }
      if ((events.moduleName != null) && events.moduleName === moduleName) {
        delete this._events[eventName];
      }
    }
    return this.info("Unloaded module " + moduleName);
  };

  exports.prototype.moduleInstance = function(moduleName) {
    var _this = this;
    return _.extend(_.omit(this, ['on']), {
      on: function() {
        var event, fn, middlewares, wrapped, _i;
        event = arguments[0], middlewares = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), fn = arguments[_i++];
        wrapped = _this.wrap(fn, middlewares);
        wrapped.moduleName = moduleName;
        return _this.addListener(event, wrapped);
      }
    });
  };

  exports.prototype.on = function() {
    var event, fn, middlewares, _i;
    event = arguments[0], middlewares = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), fn = arguments[_i++];
    return this.addListener(event, this.wrap(fn, middlewares));
  };

  exports.prototype.once = function() {
    var event, fn, middlewares, _i;
    event = arguments[0], middlewares = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), fn = arguments[_i++];
    return exports.__super__.once.call(this, event, this.wrap(fn, middlewares));
  };

  exports.prototype.wrap = function(fn, middlewares) {
    var _this = this;
    return function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return _.reduceRight(_this.middlewares.concat(middlewares), function(memo, item) {
        var next;
        next = function() {
          return memo.apply(_this, args);
        };
        return function() {
          return item.apply(this, __slice.call(args).concat([next]));
        };
      }, fn).apply(_this, arguments);
    };
  };

  exports.prototype.use = function() {
    var _ref;
    return (_ref = this.middlewares).push.apply(_ref, arguments);
  };

  return exports;

})(irc.Client);
