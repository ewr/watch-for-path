module.exports = (grunt) ->
    grunt.initConfig
        coffee:
            compile:
                files:
                    'index.js': ['src/*.coffee']
        mochaTest:
            src: ["test/watch_for_path.coffee"]

    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-mocha-test'

    grunt.registerTask 'default', ['coffee','mochaTest']