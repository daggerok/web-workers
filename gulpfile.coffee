srcDir    = 'src/'
specDir   = 'test/'
buildDir  = 'dist/'
modules   = 'node_modules/'
coffeeDir = srcDir + 'scripts/'

coffees   = '**/*.coffee'
specs     = '**/*Test.js'
htmlFiles = '**/*.html'
jsFiles   = '**/*.js'

workers   = [srcDir + 'worker.coffee']
vendors   = [modules + 'jquery/dist/jquery.min.js']
scripts   = [coffeeDir + coffees]
jsScripts = [buildDir + jsFiles]
htmls     = [srcDir + htmlFiles]

newVer    = new Date().toISOString().replace(/\..+$|[^\d]/g, '').substr 0, 12
cssVer    = "?v=#{undefined ? newVer}"
jsVer     = "?v=#{undefined ? newVer}"

gulp      = require 'gulp'
remove    = require 'gulp-rimraf'
streams   = require 'streamqueue'
coffee    = require 'gulp-coffee'
concat    = require 'gulp-concat'
uglify    = require 'gulp-uglify'
plumber   = require 'gulp-plumber'
htmlace   = require 'gulp-html-replace'
htmlify   = require 'gulp-minify-html'
jasmine   = require 'gulp-jasmine'
connect   = require 'gulp-connect'

require 'colors'
log = (error) ->
  console.log [
    "BUILD FAILED: #{error.name ? ''}".red.underline
    '\u0007' # beep
    "#{error.code ? ''}"
    "#{error.message ? error}"
    "in #{error.filename ? ''}"
    "gulp plugin: #{error.plugin ? ''}"
  ].join '\n'
  this.end()

gulp.task 'clean', ->
  gulp.src(buildDir, read: false)
    .pipe remove force: true

gulp.task 'clean-js', ->
  gulp.src(jsScripts, read: false)
    .pipe remove force: true

gulp.task 'css', ['js'], ->
  gulp.src(modules + 'bootstrap/dist/css/bootstrap.min.css')
    .pipe(plumber())
    .pipe(concat 'index.css')
    .pipe gulp.dest buildDir

processCoffee = (scripts) ->
  gulp.src(scripts)
    .pipe(plumber())
    .pipe(coffee bare: true)
      .on 'error', log

gulp.task 'web-workers', ['clean-js'], ->
  processCoffee workers
    .pipe(plumber())
    .pipe(uglify())
    .pipe gulp.dest buildDir

gulp.task 'js', ['web-workers'], ->
  streams
      objectMode: true,
      gulp.src(vendors),
      processCoffee scripts
    .pipe(plumber())
    .pipe(concat 'index.js')
    .pipe(plumber())
    .pipe(uglify())
    .pipe gulp.dest buildDir

gulp.task 'html', ->
  gulp.src(htmls)
    .pipe(plumber())
    .pipe htmlace
      css: "index.css#{cssVer}"
      js: "index.js#{jsVer}"
    .pipe(plumber())
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
  gulp.src(htmls)
    .pipe(gulp.dest buildDir)
    .pipe connect.reload()

gulp.task 'css-dev', ->
  gulp.src(modules + 'bootstrap/dist/css/bootstrap.css')
    .pipe(gulp.dest buildDir)
    .pipe connect.reload()

vendors       = [modules + "jquery/dist/jquery.js"]
coffeeScripts = [srcDir + coffees
                 specDir + coffees]

gulp.task 'js-dev', ['clean-js'], ->
  streams
      objectMode: true,
      gulp.src(vendors),
      processCoffee coffeeScripts
    .pipe(gulp.dest buildDir)
    .pipe connect.reload()

specScripts = [buildDir + specs]

gulp.task 'test', ['js-dev'], ->
  gulp.src(specScripts)
    .pipe(plumber())
    .pipe jasmine
      coffee: false # test compiled js
      autotest: true

gulp.task 'watch', ['dev', 'connect'], ->
  gulp.watch coffeeScripts, ['js-dev', 'test']
  gulp.watch htmls, ['html-dev']

gulp.task 'dev', ['js-dev', 'css-dev', 'html-dev', 'test']
