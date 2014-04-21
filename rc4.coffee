module.exports =
class RC4
  i: 0
  j: 0
  psize: 256
  S: null
  constructor: (key) ->
    @S = new Buffer(@psize)
    i = j = t = 0
    for i in [0...@psize]
      @S[i] = i
    for i in [0...@psize]
      j = (j + @S[i] + key[i%key.length]) & 255
      t = @S[i]
      @S[i] = @S[j]
      @S[j] = t
    @i=0
    @j=0

  next: ->
    @i = (@i+1)&255
    @j = (@j+@S[@i])&255
    t = @S[@i]
    @S[@i] = @S[@j]
    @S[@j] = t
    return @S[(t+@S[@i])&255]

  encrypt: (block) ->
    for i in [0...block.length]
      before = block[i]
      mod = @next()
      block[i] ^= mod
      after = block[i]

  decrypt: (block) ->
    @encrypt block # the beauty of XOR
