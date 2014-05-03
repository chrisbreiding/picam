http = require 'http'
express = require 'express'
engines = require 'consolidate'
bodyParser = require 'body-parser'
cookieParser = require 'cookie-parser'
session = require 'express-session'
flash = require 'express-flash'
_ = require 'lodash'
config = require '../config'

anauthenticatedPaths = ['/login', '/logout']

app = express()
app.engine 'html', engines.hogan
app.set 'view engine', 'html'
app.use bodyParser()
app.use cookieParser()
app.use session secret: config.sessionSecret
app.use flash()
app.use (req, res, next)->
  if _.contains(anauthenticatedPaths, req.path) or req.session.authenticated
    next()
  else
    req.flash 'must_login', true
    res.redirect '/login'

app.get '/', (req, res)->
  res.render 'index'

app.get '/login', (req, res)->
  if req.session.authenticated
    res.redirect '/'
  else
    res.render 'login'

app.post '/login', (req, res)->
  if req.body.password and req.body.password is config.password
    req.session.authenticated = true
    res.redirect '/'
  else
    req.flash 'incorrect_password', true
    res.redirect '/login'

app.get '/logout', (req, res)->
  req.session.authenticated = false
  req.flash 'logout_success', true
  res.redirect '/login'

app.get '/stream', (req, res)->
  options =
    host:    config.stream.host
    port:    config.stream.port
    path:    '/'
    method:  'GET'
    headers: req.headers

  streamReq = http.request options, (streamRes)->
    res.set
      'Content-Type':  'multipart/x-mixed-replace;boundary="BoundaryString"'
      'Connection':    'close'
      'Pragma':        'no-cache'
      'Cache-Control': 'no-cache, private'
      'Expires':       0
      'Max-Age':       0

    streamRes.on 'data', (chunk)->
      res.write chunk

    streamRes.on 'close', ->
      res.writeHead streamRes.statusCode
      res.end()

  streamReq.on 'error', (e)->
    console.log e.message
    res.writeHead 500
    res.end()

  streamReq.end()

app.listen 3000, ->
  console.log 'listening on 3000...'
