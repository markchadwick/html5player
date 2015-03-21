require './test_case'

{Transform} = require 'stream'
{expect}    = require 'chai'

VarietyStream = require '../src/variety_stream'


class SlowReader extends Transform

  consturctor: ->
    super(highWaterMark: 0, objectMode: true)

  _transform: (o, enc, callback) ->
    console.log 'SlowReader peeping', String(o)
    setTimeout(callback, 200)


class NumberStream extends VarietyStream

  constructor: ->
    super
    @n = 0

  _identify: (n) -> n

  _next: (callback) ->
    @n += 1
    value = String(@n)
    ticked = => callback([value, value, value])
    setTimeout(ticked, 100)


describe.only 'Variety Pipe', ->

  it 'should do a thing??', (done) ->
    numbers = new NumberStream(5)
    reader  = new SlowReader()

    numbers.pipe(reader)
    setTimeout(done, 1500)
