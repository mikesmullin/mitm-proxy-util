Proxy = require './proxy'
log = require './log'
Color = require './color'
Protocol = require './protocol'
cmds = require './const-cmds'
d = (i) -> ("000"+i).substr(-3)
h = (s, i) -> parseInt s.substr(i, 2), 16

# e.g., coffee main.coffee 127.0.0.1 2051 1.0.0.1 2050 # nexus
# e.g., coffee main.coffee 127.0.0.1 2052 1.0.0.2 2050 # game world: Medusa?
# e.g., coffee main.coffee 127.0.0.1 2050 127.0.0.1 2051 # localhost debugging
[nil, nil, listen_ip, listen_port, remote_ip, remote_port] = process.argv
proxy = new Proxy listen_ip, listen_port, remote_ip, remote_port, 'hex'
client_protocol = new Protocol "311f80691451c71b09a13a2a6e"
server_protocol = new Protocol "72c5583cafb6818995cbd74b80"
proxy.start
  intercept_out: (req, out_res, in_res) ->
    client_protocol.parse req.data, (msgId, msg) ->
      msgName = cmds[msgId] or "UNDEFINED"
      # TODO: use decoder ring view here
      log "#{Color.bright_blue}interpreted send: #{Color.bright_white}#{msgName}#{Color.bright_blue} #{d msgId} msg: #{msg}#{Color.reset}"
      return
    in_res.send req.data, -> # proxy client -> server
    return

  intercept_in: (req, in_res, out_res) ->
    server_protocol.parse req.data, (msgId, msg) ->
      msgName = cmds[msgId] or "UNDEFINED"
      log "#{Color.bright_red}interpreted recv: #{Color.bright_white}#{msgName}#{Color.bright_red} #{d msgId} msg: #{msg}#{Color.reset}"
      return
    out_res.send req.data, -> # proxy server -> client
    return
