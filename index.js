(function() {
  var WatchForPath, debug, fs, path;

  debug = require("debug")("watch-for-path");

  fs = require("fs");

  path = require("path");

  module.exports = WatchForPath = (function() {
    function WatchForPath(tp, cb) {
      this.target_path = path.resolve(process.cwd(), path.normalize(tp));
      debug("WatchForPath created for " + this.target_path + ".");
      this._watchForDir(this.target_path, cb);
    }

    WatchForPath.prototype._watchForDir = function(target, cb) {
      var lFunc;
      lFunc = (function(_this) {
        return function(d, lcb) {
          return fs.exists(d, function(exists) {
            if (exists) {
              return typeof lcb === "function" ? lcb(d) : void 0;
            } else {
              if (d === "/") {
                return cb(new Error("Failed to find a directory to watch."));
              } else {
                d = path.resolve(d, "..");
                return lFunc(d, lcb);
              }
            }
          });
        };
      })(this);
      return lFunc(target, (function(_this) {
        return function(existing) {
          if (existing === target) {
            debug("Target " + target + " found. Triggering callback.");
            return cb(null, target);
          } else {
            return _this._pollForDir(target, existing, cb);
          }
        };
      })(this));
    };

    WatchForPath.prototype._pollForDir = function(target, existing, cb) {
      var _pInt;
      debug("Setting a watch on " + existing + ". Target is " + target + ".");
      this.dwatcher = fs.watch(existing, (function(_this) {
        return function(type, filename) {
          debug("Observed change on " + existing + ". Checking for target.");
          _this.dwatcher.close();
          if (_pInt) {
            clearInterval(_pInt);
          }
          return _this._watchForDir(target, cb);
        };
      })(this));
      return _pInt = setInterval((function(_this) {
        return function() {
          return fs.exists(target, function(exists) {
            if (exists) {
              _this.dwatcher.close();
              if (_pInt) {
                clearInterval(_pInt);
              }
              return typeof cb === "function" ? cb() : void 0;
            }
          });
        };
      })(this), 1000);
    };

    return WatchForPath;

  })();

}).call(this);
