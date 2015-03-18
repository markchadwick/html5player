
identity = (x) -> String(x)


# A roughly FIFO queue that tries to maximize variety in the items pop'd. That
# is, if possible, it will try to minimize adjacency. This is a relatively simple
# operation that does not look ahead -- if it contains items [A, B, B], it may
# well yield A first, even though yielding B will provide better overall
# results.
#
# This never guarantees that it will not give the same item twice.
class VarietyQueue

  constructor: (@identify=identity) ->
    @_items = []
    @_timeSinceLastPop = {}

  push: (item) ->
    itemId = @identify(item)
    if itemId not of @_timeSinceLastPop
      @_timeSinceLastPop[itemId] = Object.keys(@_timeSinceLastPop).length

    @_items.push(item)

  pop: ->
    @_items.sort (a, b) =>
      idA = @identify(a)
      idB = @identify(b)
      @_timeSinceLastPop[idB] - @_timeSinceLastPop[idA]

    res = @_items.shift()
    unless res? then return

    resId = @identify(res)
    for id, count of @_timeSinceLastPop

      if id is resId
        @_timeSinceLastPop[id] = 0
      else
        @_timeSinceLastPop[id]++

    res

  size: ->
    @_items.length


module.exports = VarietyQueue
