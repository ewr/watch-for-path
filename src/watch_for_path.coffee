debug = require("debug")("watch-for-path")

fs      = require "fs"
path    = require "path"

module.exports = class WatchForPath
    constructor: (tp,cb) ->
        # clean up
        @target_path = path.resolve( process.cwd(), path.normalize(tp) )

        debug "WatchForPath created for #{@target_path}."
        @_watchForDir @target_path, cb

    #----------

    _watchForDir: (target,cb) ->
        # loop our way up until we find something that exists
        lFunc = (d,lcb) =>
            # test this
            fs.exists d, (exists) =>
                if exists
                    lcb?(d)
                else
                    if d == "/"
                        cb new Error("Failed to find a directory to watch.")
                    else
                        d = path.resolve d, ".."
                        lFunc(d,lcb)

        lFunc target, (existing) =>
            if existing == target
                debug "Target #{target} found. Triggering callback."
                cb null, target

            else
                @_pollForDir target, existing, cb

    #----------

    _pollForDir: (target,existing,cb) ->
        # we got here because not all of our target path exists.  Sometimes that's
        # accurate -- the app is still deploying, etc. Sometimes, though, it
        # actually snapped into place in between the point where we checked and
        # the point where we start watching for changes.  We'll watch what we
        # found (existing), but also set up an interval to poll for the full path.

        # -- Watch existing -- #

        debug "Setting a watch on #{existing}. Target is #{target}."
        @dwatcher = fs.watch existing, (type,filename) =>
            debug "Observed change on #{existing}. Checking for target."
            # on any change, just stop our watcher and try again
            @dwatcher.close()
            clearInterval _pInt if _pInt
            @_watchForDir target, cb

            # -- Poll the full target -- #

        _pInt = setInterval =>
            fs.exists target, (exists) =>
                if exists
                    # target acquired...
                    @dwatcher.close()
                    clearInterval _pInt if _pInt
                    cb?()
        , 1000