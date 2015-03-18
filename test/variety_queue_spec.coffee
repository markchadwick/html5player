require './test_case'

{expect} = require 'chai'

VarietyQueue = require '../src/variety_queue'


describe 'Variety Queue', ->

  beforeEach ->
    @queue = new VarietyQueue()

  context 'when empty', ->

    it 'should have size 0', ->
      expect(@queue.size()).to.equal 0

    it 'should pop undefined', ->
      expect(@queue.pop()).to.be.undefined

  context 'with one item', ->

    beforeEach ->
      @queue.push(1)

    it 'should have size 1', ->
      expect(@queue.size()).to.equal 1

    it 'should pop that item', ->
      expect(@queue.pop()).to.equal 1

    it 'should have no items after popping', ->
      @queue.pop()

      expect(@queue.size()).to.equal 0
      expect(@queue.pop()).to.be.undefined

  context 'with multiple equal items', ->

    beforeEach ->
      @queue.identify = (x) -> x.id
      @queue.push(id: '666', index: 0)
      @queue.push(id: '666', index: 1)
      @queue.push(id: '666', index: 2)

    it 'should be FIFO ordered', ->
      expect(@queue.pop().index).to.equal 0
      expect(@queue.pop().index).to.equal 1
      expect(@queue.pop().index).to.equal 2

  context 'with multiple unequal items', ->

    beforeEach ->
      @queue.identify = (x) -> x.id
      @queue.push(id: 'dog', index: 0)
      @queue.push(id: 'dog', index: 1)
      @queue.push(id: 'cat', index: 2)
      @queue.push(id: 'cat', index: 3)

    it 'should consider recently added items older', ->
      expect(@queue._timeSinceLastPop['dog']).to.equal 0
      expect(@queue._timeSinceLastPop['cat']).to.equal 1

    it 'should re-order for variety', ->
      expect(@queue.pop().index).to.equal 2 # 1st cat
      expect(@queue.pop().index).to.equal 0 # 1st dog
      expect(@queue.pop().index).to.equal 3 # 2nd cat
      expect(@queue.pop().index).to.equal 1 # 2nd dog
      expect(@queue.pop()).to.be.undefined
