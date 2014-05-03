http = require 'http'
express = require 'express'
engines = require 'consolidate'
bodyParser = require 'body-parser'
cookieParser = require 'cookie-parser'
session = require 'express-session'
_ = require 'lodash'
secrets = require '../secrets'

anauthenticatedPaths = ['/login', '/logout']

app = express()
app.engine 'html', engines.hogan
app.set 'view engine', 'html'
app.use bodyParser()
app.use cookieParser()
app.use session secret: secrets.sessionSecret
app.use (req, res, next)->
  if _.contains(anauthenticatedPaths, req.path) or req.session.authenticated
    next()
  else
    res.redirect '/login'

app.get '/', (req, res)->
  res.render 'index'

app.get '/login', (req, res)->
  if req.session.authenticated
    res.redirect '/'
  else
    res.render 'login'

app.post '/login', (req, res)->
  if req.body.password and req.body.password is secrets.password
    req.session.authenticated = true
    res.redirect '/'
  else
    res.redirect '/login'

app.get '/logout', (req, res)->
  req.session.authenticated = false
  res.redirect '/login'

app.get '/stream', (req, res)->
  options =
    host:    '10.0.1.52'
    port:    8081
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
