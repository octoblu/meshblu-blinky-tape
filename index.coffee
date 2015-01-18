'use strict';
util           = require 'util'
{EventEmitter} = require 'events'
debug          = require('debug')('meshblu-blinky-tape:index')
BlinkyTape     = require './blinky-tape'

MESSAGE_SCHEMA =
  type: 'object'
  properties:
    animation:
      type: 'array'
      required: true

OPTIONS_SCHEMA =
  type: 'object'
  properties:
    ledCound:
      type: 'integer'
      default: 60
    framesPerSecond:
      type: 'integer'
      default: 30
      required: true
    interuptable:
      type: 'boolean'
      default: true
      required: true

class Plugin extends EventEmitter
  constructor: ->
    @options = {}
    @messageSchema = MESSAGE_SCHEMA
    @optionsSchema = OPTIONS_SCHEMA
    @blinkyTape    = new BlinkyTape

  onMessage: (message, callback=->) =>
    debug 'onMessage'
    @blinkyTape.setAnimation message.animation
    callback()

  onConfig: (device) =>
    @setOptions device.options

  setOptions: (options={}) =>
    @options = options
    @blinkyTape.setOptions options
    @blinkyTape.open (error) =>
      return debug error if error?
      debug 'blinky-tape open'
      @blinkyTape.start()

module.exports =
  messageSchema: MESSAGE_SCHEMA
  optionsSchema: OPTIONS_SCHEMA
  Plugin: Plugin
