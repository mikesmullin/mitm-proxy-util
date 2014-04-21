RC4 = require './rc4'

module.exports =
class Protocol
  buf: ''
  cipher: null
  constructor: (cipherKey) ->
    @cipher = new RC4 new Buffer cipherKey, "hex"
  parse: (data, cb) ->
    @buf += data
    len = parseInt(@buf.substr(0, 2*4), 16) # first four bytes is a 32-bit integer representing the total length of the message
    if @buf.length >= len*2 # if we have the complete message
      msgId = parseInt(@buf.substr(2*4, 2), 16) # next byte represents the command id
      data = @buf.substr(2*5, (len*2)-(2*5)) # remaining bytes contain encrypted data
      @buf = @buf.substr(len*2) # remaining bytes are partial next message and should remain in buffer

      _data = new Buffer data, "hex"
      @cipher.decrypt _data
      msg = _data.toString "hex"

      cb msgId, msg
      return
