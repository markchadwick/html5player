
VarietyQueue = require './variety_queue'

# A pseudo-stream which can feed input (via a pipe) to a stream which applies
# backpressure. It must implement `_identify` (see VarietyQueue for usage) and
# `_next` to generate a new item.
class VarietyStream

  constructor: (@lowWatermark) ->

  _identify: (item) ->
    throw Error('VarietyStream._identify not implemented')

  _next: (callback) ->
    throw Error('VarietyStream._next not implemented')

  pipe: (stream) ->
    queue   = new VarietyQueue(@_identify)
    writing = false

    tick = =>
      if queue.size() < @lowWatermark
        @_next (items) =>
          queue.push(it) for it in items
          tick()

      if not writing
        value = queue.pop()
        unless value? then return # TODO: Tick again?
        stream.write(value, tick)

    tick()



module.exports = VarietyStream
