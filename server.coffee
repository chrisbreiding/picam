express = require 'express'

app = express()

app.get '/', (req, res)->
  res.send '200', { all: 'good' }

app.listen 3000, ->
  console.log 'listening on 3000...'
