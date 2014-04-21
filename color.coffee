module.exports =
  reset:   '\u001b[0m'
  black:   '\u001b[30m'
  red:     '\u001b[31m'
  green:   '\u001b[32m'
  yellow:  '\u001b[33m'
  blue:    '\u001b[34m'
  magenta: '\u001b[35m'
  cyan:    '\u001b[36m'
  white:   '\u001b[37m'
  grey:    '\u001b[1m\u001b[30m'
  bright_red:     '\u001b[1m\u001b[31m'
  bright_green:   '\u001b[1m\u001b[32m'
  bright_yellow:  '\u001b[1m\u001b[33m'
  bright_blue:    '\u001b[1m\u001b[34m'
  bright_magenta: '\u001b[1m\u001b[35m'
  bright_cyan:    '\u001b[1m\u001b[36m'
  bright_white:   '\u001b[1m\u001b[37m'

#class RainbowIndex
#  @rainbow: [ 'blue', 'magenta', 'cyan', 'red', 'green', 'yellow',
#    'bright_yellow', 'bright_blue', 'bright_magenta',
#    'bright_cyan', 'bright_red', 'bright_green' ]
#  constructor: (s) ->
#    s = s.toString()
#    sum = ((sum || 0) + s.charCodeAt i) % 12 for i in [0...s.length]
#    return Color[RainbowIndex.rainbow[sum]]
