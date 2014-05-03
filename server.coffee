http = require 'http'
express = require 'express'

app = express()

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
