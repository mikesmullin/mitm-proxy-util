Color = require './color'
module.exports = (s) ->
  d = new Date
  console.log "#{Color.bright_white}#{d.getHours()}:#{d.getMinutes()}:#{d.getSeconds()}.#{d.getMilliseconds()}#{Color.reset} "+s
