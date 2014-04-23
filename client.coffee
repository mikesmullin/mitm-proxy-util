net = require 'net'
log = require './log'
Color = require './color'

module.exports =
class Client
  socket: null
  constructor: (@host, @port, @encoding) ->
  connect: (app) ->
    @socket = new net.Socket allowHalfOpen: false
    @socket.id = "server-side socket #{@host}:#{@port}"
    @socket.setEncoding @encoding
    #@socket.setTimeout 10*1000 # 10sec
    @socket.connected = false
    @socket.on 'end', =>
      @socket.connected = false
      log "#{Color.yellow}#{@socket.id} ended#{Color.reset}"
      return
    @socket.on 'close', (err) =>
      @socket.connected = false
      if err
        log "#{Color.yellow}#{@socket.id} closed due to a transmission error.#{Color.reset}"
      log "#{Color.yellow}#{@socket.id} closed#{Color.reset}"
      app.close()
      return
    @socket.on 'error', (err) =>
      log "#{Color.yellow}#{@socket.id} error: "+ JSON.stringify err
      return
    @socket.on 'timeout', =>
      log "#{Color.red}#{@socket.id} idle.#{Color.reset}"
      return
    @socket.on 'data', (data) =>
      log "#{Color.red}#{@socket.id} recv: #{data}#{Color.reset}"
      app.data {
        socket: @socket
        data: data
      }, {
        send: @send
      }
    log  "#{Color.yellow}#{@socket.id} connecting...#{Color.reset}"
    @socket.connect host: @host, port: @port, allowHalfOpen: false, =>
      @socket.connected = true
      log "#{Color.yellow}#{@socket.id} connected.#{Color.reset}"
      app.connected {
        socket: @socket
      }, {
        send: @send
      }
      return
    return

  send: (data, cb) =>
    log "#{Color.yellow}#{@socket.id} send: #{data}#{Color.reset}"
    @socket.write data, @encoding, cb
    return

  close: ->
    if @socket?.connected
      log "#{Color.yellow}#{@socket.id} ending...#{Color.reset}"
      @socket.end()
      log "#{Color.yellow}#{@socket.id} closing...#{Color.reset}"
      @socket.destroy()
      @socket.connected = false
    return
