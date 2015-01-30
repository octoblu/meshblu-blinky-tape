async        = require 'async'
glob         = require 'glob'
_            = require 'lodash'
tinycolor    = require 'tinycolor2'
{SerialPort} = require 'serialport'
debug        = require('debug')('meshblu-blinky-tape:blinky-tape')

class BlinkyTape
  constructor: (options={}) ->
    @setOptions options

  setOptions: (options={}) =>
    @framesPerSecond = options.framesPerSecond ? 30
    @interuptable    = options.interuptable ? true

    @ledCount        = options.ledCount ? 60
    @bufferSize      = (@ledCount * 3) + 2

  findSerialPort: (callback=->) =>
    glob '/dev/tty.usbmodem*', (error, files) =>
      return callback error if error?
      if _.size(files) == 0
        return callback new Error "Could not find a BlinkyTape"
      if _.size(files) > 1
        return callback new Error "Found #{_.size files}. Cannot decide which one is right"

      callback null, _.first files

  open: (callback=->) =>
    @close (error) =>
      return callback error if error?
      @findSerialPort (error, serialPortPath) =>
        return callback error if error?

        @serial = new SerialPort serialPortPath, baudrate: 57600, false
        @serial.open (error) =>
          return callback error if error?
          callback()

  close: (callback=->) =>
    return _.defer callback unless @serial?
    @serial.close callback

  setAnimation: (animation) =>
    @animation = animation
    @interupt  = true

  start: =>
    return if @animating
    @animating = true
    @animate()

  animate: (callback=->) =>
    debug('animate')
    animation = _.clone(@animation ? [])
    async.eachSeries animation, @animateFrame, =>
      @interupt = false
      _.delay @animate, 1

  animateFrame: (frame, callback=->) =>
    return callback() if @interupt && @interuptable

    @serial.write @frameToBuffer(frame), =>
      _.delay callback, (1000 / @framesPerSecond)

  frameToBuffer: (frame) =>
    buffer = new Buffer @bufferSize
    buffer.fill 0
    buffer.writeUInt8 255, 0 # semaphore

    _.each frame, (led, i) =>
      {r,g,b} = @colorToRgb led

      buffer.writeUInt8 r, (i * 3) + 1
      buffer.writeUInt8 g, (i * 3) + 2
      buffer.writeUInt8 b, (i * 3) + 3

    buffer.writeUInt8 255, @bufferSize - 1 # semaphore
    return buffer

  colorToRgb: (color) =>
    {r,g,b} = tinycolor(color).toRgb()
    # avoid 255, cause its the semaphore value
    r = 254 if r >= 255
    g = 254 if g >= 255
    b = 254 if b >= 255
    return {r:r, b:b, g:g}

module.exports = BlinkyTape
