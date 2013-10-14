_      = require 'underscore'
assert = require 'assert'

Bot = require '../index'

createBot = ->
  new Bot 'irc.datnode.net', 'TestBot',
    autoConnect: false


describe 'Middleware wrapper', ->

  it 'should pass the right arguments all the way to the final function', (done) ->
    bot = createBot()

    mw1 = (res, next) ->
      assert.equal res.a, 1
      next()

    mw2 = (res, next) ->
      assert.equal res.a, 1
      next()

    fn = (res) ->
      assert.equal res.a, 1
      done()

    bot.wrap(fn, [mw1, mw2])
      a: 1
      b: 2

  it 'should pass object through middlewares', (done) ->
    bot = createBot()

    obj =
      foo: 'bar'
      lol: 'cat'

    mw1 = (res, next) ->
      assert.equal res, obj
      next()

    mw2 = (res, next) ->
      assert.equal res, obj
      next()

    fn = (res) ->
      assert.equal res, obj
      done()

    bot.wrap(fn, [mw1, mw2]) obj


  it 'should pass changed res object through middlewares', (done) ->
    bot = createBot()

    mw1 = (res, next) ->
      next()

    mw2 = (res, next) ->
      res.foo = 'bar'
      next()

    fn = (res) ->
      assert.equal res.foo, 'bar'
      done()

    bot.wrap(fn, [mw1, mw2])
      a: 1

  it 'should remain the context', (done) ->
    bot = createBot()

    mw1 = (res, next) -> next()
    mw2 = (res, next) -> next()

    fn = (res) ->
      assert.equal this, bot
      done()

    bot.wrap(fn, [mw1, mw2]) 'hello world'
