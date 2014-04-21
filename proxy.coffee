Server = require './server'
Client = require './client'
RemoteConsole = require './remote_console'
log = require './log'
Color = require './color'

module.exports =
class Proxy # InjectableProxy
  server: null
  client: null
  app: null
  closed: true
  constructor: (@from_ip, @from_port, @to_ip, @to_port, @encoding, @delimiter) ->
  start: (@app) ->
    @closed = false
    @server = new Server @from_ip, @from_port, 1, @encoding
    @client = new Client @to_ip, @to_port, @encoding
    @client_console = new RemoteConsole @from_ip, "1#{@from_port}", 'TO:CLIENT'
    @server_console = new RemoteConsole @from_ip, "1#{parseInt(@from_port,10)+1}", 'TO:SERVER'
    server_socket = null
    @server.listen
      accepted: (req, res) =>
        server_socket = req.socket
        log "proxy: welcome client."
        @client_console.listen msg: (creq, cres) ->
          log "#{Color.bright_red}inject client data: #{creq.msg}#{Color.reset}"
          res.send req.socket, creq.msg, -> # inject to client
          return
        `this.data(req, res);` # kick-start remote link
        return
      close: @close
      data: (out_req, out_res) =>
        if @client?.socket?.connected
          if out_req.data isnt undefined
            app.intercept_out out_req, out_res, { send: @client.send }
          return
        else
          log "proxy: establishing remote link with first client request..."
          @client.connect
            connected: (req, res) =>
              log "proxy: remote link established."
              @server_console.listen msg: (creq, cres) =>
                log "#{Color.bright_blue}inject server data: #{creq.msg}#{Color.reset}"
                res.send creq.msg, -> # inject to server
                return
              if out_req.data isnt undefined
                app.intercept_out out_req, out_res, { send: @client.send } # delayed; first time only
              return
            close: @close
            data: (in_req, in_res) =>
              app.intercept_in in_req, in_res, { send: (data, cb) => @server.send server_socket, data, cb }
              return
          return

  close: =>
    unless @closed
      @closed = true
      log "proxy: closing..."
      @server.close()
      @client.close()
      @client_console.server.close()
      @server_console.server.close()
      flapTimer = setTimeout((=>
        log "proxy: will auto-restart..."
        @start @app
      ), 500)
    return
