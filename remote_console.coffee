Server = require './server'
log = require './log'

module.exports =
class RemoteConsole
  @delim: '\n'
  server: null
  prompt: ''
  buf: ''
  constructor: (@ip, @port, @prompt) ->
    @server = new Server @ip, @port, 1, 'utf8'
  listen: (app) ->
    @server.listen
      accepted: (req, res) =>
        res.send req.socket, "welcome. paste hex.\n#{@prompt}> "
        return
      data: (req, res) =>
        @buf += req.data
        while (pos = @buf.indexOf(RemoteConsole.delim)) isnt -1
          msg = @buf.substr 0, pos
          @buf = @buf.substr pos+RemoteConsole.delim.length
          if msg.length % 2 isnt 0 or /^[a-fA-F0-9]+$/.exec(msg) is null
            res.send req.socket, "INVALID HEX!\n#{@prompt}> "
            continue
          app.msg {
            socket: req.socket
            msg: msg
          }, {
            send: (data, cb) -> res.send req.socket, data, cb
          }
          res.send req.socket, "INJECTED.\n#{@prompt}> "
        return
    return
