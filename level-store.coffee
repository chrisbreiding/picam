level = require 'level'
db = level './db/session', valueEncoding: 'json'

module.exports = (session)->

  class LevelStore extends session.Store

    get: (sid, callback)->
      db.get sid, (err, data)->
        return callback() if err
        callback null, data

    set: (sid, session, callback)->
      db.put sid, session, callback

    destroy: (sid, callback)->
      db.del sid, callback
