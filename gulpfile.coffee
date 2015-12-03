gulp = require 'gulp'
remove = require 'gulp-rimraf'
streams = require 'streamqueue'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
plumber = require 'gulp-plumber'
htmlace = require 'gulp-html-replace'
htmlify = require 'gulp-minify-html'
jasmine = require 'gulp-jasmine'
connect = require 'gulp-connect'

buildDir = 'dist/'
srcDir = 'app/'
specDir = 'specs/'
modules = 'node_modules/'
coffeeDir = srcDir + 'scripts/'

coffees = '**/*.coffee'
specs = '**/*Spec.js'
htmlFiles = '**/*.html'
jsFiles = '**/*.js'

workers = [srcDir + 'worker.coffee']
vendors = [modules + 'jquery/dist/jquery.min.js']
scripts = [coffeeDir + coffees]
jsScripts = [buildDir + jsFiles]
htmls = [srcDir + htmlFiles]

gulp.task 'clean', ->
  gulp.src buildDir
    .pipe remove force: true

gulp.task 'clean-js', ->
  gulp.src jsScripts
    .pipe remove force: true

gulp.task 'css', ->
  gulp.src modules + 'bootstrap/dist/css/bootstrap.min.css'
    .pipe plumber()
    .pipe concat 'index.css'
    .pipe gulp.dest buildDir

processCoffee = (scripts) ->
  gulp.src scripts
    .pipe plumber()
    .pipe coffee bare: true
      .on 'error', -> console?.log error

gulp.task 'web-workers', ['clean-js'], ->
  processCoffee workers
    .pipe plumber()
    .pipe uglify()
    .pipe gulp.dest buildDir

gulp.task 'js', ['web-workers'], ->
  streams
      objectMode: true,
      gulp.src(vendors),
      processCoffee scripts
    .pipe plumber()
    .pipe concat 'index.js'
    .pipe plumber()
    .pipe uglify()
    .pipe gulp.dest buildDir

gulp.task 'html', ->
  gulp.src htmls
    .pipe plumber()
    .pipe htmlace
      css: '<link rel="stylesheet" href="index.css">'
      js: '<script src="index.js"></script>'
    .pipe plumber()
    .pipe htmlify
      quotes: true
      conditionals: true
      spare: true
    .pipe gulp.dest buildDir

gulp.task 'default', ['css', 'web-workers', 'js', 'html']

gulp.task 'connect', ->
  connect.server
    root: buildDir
    livereload: true

gulp.task 'serve', ['default', 'connect']

gulp.task 'html-dev', ->
  gulp.src htmls
    .pipe gulp.dest buildDir
    .pipe connect.reload()

gulp.task 'css-dev', ->
  gulp.src modules + 'bootstrap/dist/css/bootstrap.css'
    .pipe gulp.dest buildDir

gulp.task 'web-workers-dev', ['clean-js'], ->
  processCoffee workers
    .pipe plumber()
    .pipe uglify()
    .pipe gulp.dest buildDir

vendors = [modules + "jquery/dist/jquery.js"]
coffeeScripts = [srcDir + coffees
                 specDir + coffees]

gulp.task 'js-dev', ['web-workers-dev'], ->
  streams
      objectMode: true,
      gulp.src(vendors),
      processCoffee coffeeScripts
    .pipe gulp.dest buildDir
    .pipe connect.reload()

specScripts = [buildDir + specs]

gulp.task 'jasmine', ['js-dev'], ->
  gulp.src specScripts
    .pipe plumber()
    .pipe jasmine
      coffee: false
      autotest: true

gulp.task 'watch', ['connect'], ->
  gulp.watch coffeeScripts, ['js-dev', 'jasmine']
  gulp.watch htmls, ['html-dev']

gulp.task 'dev', ['css-dev', 'jasmine', 'html-dev', 'jasmine']