Watch   = require "../"

rimraf  = require "rimraf"
mkdirp  = require "mkdirp"
path    = require "path"
fs      = require "fs"

expect  = (require "chai").expect

$tmppath = (spec="") -> path.resolve(__dirname,"tmp",spec)

describe "Watch for Path", ->
    before (done) ->
        # clean up our tmp dir
        rimraf $tmppath(), (err) ->
            throw err if err

            # make a new one
            fs.mkdir $tmppath(), (err) ->
                throw err if err
                done()

    it "should return immediately on a path that exists", (done) ->
        # make our path
        p = $tmppath("this/path/exists")
        mkdirp p, (err) ->
            throw err if err

            start_ts = Number(new Date())
            w = new Watch p, (err,pp) ->
                throw err if err

                done_ts = Number(new Date())

                expect(done_ts - start_ts).to.be.lt 50

                done()

    it "should return quickly after a watched path is created", (done) ->
        p = $tmppath("this/path/does/not")

        mkdir_called    = false
        mkdir_ts        = null

        w = new Watch p, (err,pp) ->
            throw err if err

            done_ts = Number(new Date())

            expect(mkdir_called).to.be.true
            expect(done_ts-mkdir_ts).to.be.lt 250
            expect(done_ts-mkdir_ts).to.be.gt 0

            done()

        setTimeout ->
            mkdir_ts = Number(new Date())
            mkdirp p, (err) ->
                throw err if err
                mkdir_called = true

        , 100

    it "should accept a relative path", (done) ->
        p = $tmppath("my/awesome/path")

        relative = path.relative(process.cwd(),p)

        w = new Watch relative, (err,pp) ->
            throw err if err

            done()

        mkdirp p, (err) ->
            throw err if err

        done()