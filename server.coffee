net = require 'net'
log = require './log'
Color = require './color'

module.exports =
class Server
  server: null
  server_sockets: []
  constructor: (@LISTEN_IP, @LISTEN_PORT, @BACKLOG, @ENCODING) ->
  listen: (app) ->
    @server = net.createServer (socket) =>
      socket.id = "client-side socket #{socket.remoteAddress}:#{socket.remotePort}"
      log "#{Color.yellow}#{socket.id} accepted.#{Color.reset}"
      socket.setNoDelay true # disable Nagle's algorithm
      socket.setEncoding @ENCODING
      #socket.setTimeout 1000*30 # ms to wait before receiving notice of idle user
      socket.on 'error', (err) ->
        log "#{Color.red}#{socket.id} error #{err}.#{Color.reset}"
        socket.destroy()
        return
      socket.on 'data', (data) =>
        log "#{Color.blue}#{socket.id} recv: #{data}#{Color.reset}"
        app.data {
          socket: socket
          data: data
        }, {
          send: @send
        }
        return
      socket.on 'timeout', ->
        log "#{Color.red}#{socket.id} idle.#{Color.reset}"
        return
      socket.on 'end', ->
        log "#{Color.yellow}#{socket.id} end.#{Color.reset}"
        return
      socket.on 'close', (had_err) ->
        log "#{Color.yellow}#{socket.id} close#{if had_err then " due to error" else ""}.#{Color.reset}"
        delete socket.remoteAddr
        app?.close?()
        return
      @server_sockets.push socket
      app.accepted {
        socket: socket
      }, {
        send: @send
      }
      return
    @server.on 'error', (err) =>
      log "#{Color.red}listen #{@LISTEN_IP}:#{@LISTEN_PORT} error #{err}#{Color.reset}"
      return
    @server.on 'close', =>
      log "#{Color.yellow}listen #{@LISTEN_IP}:#{@LISTEN_PORT} close.#{Color.reset}"
      return
    @server.listen @LISTEN_PORT, @LISTEN_IP, @BACKLOG, =>
      log "#{Color.yellow}listening #{@LISTEN_IP}:#{@LISTEN_PORT}...#{Color.reset}"
      return
    return

  send: (socket, data, cb) =>
    #log "#{Color.yellow}#{socket.id} send: #{data}#{Color.reset}"
    socket.write data, @ENCODING, cb

  close: ->
    log "#{Color.yellow}closing listener...#{Color.reset}"
    @server?.close()
    @server = null
    for socket, i in @server_sockets when socket isnt null
      log "#{Color.yellow}#{socket.id} ending...#{Color.reset}"
      socket.end()
      log "#{Color.yellow}#{socket.id} closing...#{Color.reset}"
      socket.destroy()
      @server_sockets[i] = null
    return
