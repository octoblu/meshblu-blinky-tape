_            = require 'lodash'
tinycolor    = require 'tinycolor2'
{SerialPort} = require 'serialport'
debug        = require('debug')('meshblu-blinky-tape:blinky-tape')

LED_COUNT = 60
BUFFER_SIZE = (LED_COUNT * 3) + 1 # 3 bytes per LED + the semaphore

class BlinkyTape
  open: (callback=->) =>
    @close (error) =>
      return callback error if error?
      @serial = new SerialPort '/dev/tty.usbmodemfd121', baudrate: 57600, false
      @serial.open (error) =>
        return callback error if error?
        callback()

  close: (callback=->) =>
    return _.defer callback unless @serial?
    @serial.close callback

  animate: (animation, callback=->) =>
    _.each animation, (frame) =>
      @serial.write @frameToBuffer(frame), callback

  frameToBuffer: (frame) =>
    buffer = new Buffer BUFFER_SIZE
    buffer.fill 0
    buffer.writeUInt8 255, 0 # semaphore

    _.each frame, (led, i) =>
      {r,g,b} = @colorToRgb led

      buffer.writeUInt8 r, (i * 3) + 1
      buffer.writeUInt8 g, (i * 3) + 2
      buffer.writeUInt8 b, (i * 3) + 3

    buffer.writeUInt8 255, BUFFER_SIZE - 1 # semaphore
    return buffer

  colorToRgb: (color) =>
    {r,g,b} = tinycolor(color).toRgb()
    # avoid 255, cause its the semaphore value
    r = 254 if r >= 255
    g = 254 if g >= 255
    b = 254 if b >= 255
    return {r:r, b:b, g:g}

module.exports = BlinkyTape
