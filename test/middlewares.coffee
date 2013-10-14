_      = require 'underscore'
assert = require 'assert'

Bot = require '../index'

createBot = ->
  new Bot 'irc.datnode.net', 'TestBot',
    autoConnect: false

describe 'Middleware', ->
  it 'should be used after its registed', (done) ->
    bot = createBot()

    middleware = (args..., next) -> done()
    bot.use middleware

    bot.on 'test', ->
    bot.emit 'test'

  it 'should be able to receive X amoung of arguments', (done) ->
    bot = createBot()

    middleware = (args..., next) ->
      assert.equal args.length, 4
      done()

    bot.use middleware

    bot.on 'test', ->

    bot.emit 'test', 1, 2, 3, 4


  it 'should be possible to register during event handler registeration', (done) ->
    bot = createBot()

    middleware = (args..., next) -> done()

    bot.on 'test', middleware, ->
    bot.emit 'test'

describe 'Multiple middlewares', ->
  it 'should be used after they are registed', (done) ->
    bot = createBot()

    i = 0

    middleware1 = (args..., next) ->
      i += 1
      return done() if i is 2
      next()
    middleware2 = (args..., next) ->
      i += 1
      return done() if i is 2
      next()

    bot.use middleware1
    bot.use middleware2

    bot.on 'test', ->
    bot.emit 'test'

  it 'should be used after they are registed during event registeration', (done) ->
    bot = createBot()

    i = 0

    middleware1 = (args..., next) ->
      i += 1
      return done() if i is 2
      next()
    middleware2 = (args..., next) ->
      i += 1
      return done() if i is 2
      next()

    bot.on 'test', middleware1, middleware2, ->
    bot.emit 'test'

  it 'should be used in the registeration order', (done) ->
    bot = createBot()
    i = 0
    middleware1 = (args..., next) ->
      i = 1
      next()

    middleware2 = (args..., next) ->
      done() if i is 1

    bot.use middleware1
    bot.use middleware2

    bot.on 'test', ->
    bot.emit 'test'

  it 'should be used in the registeration order when registered during event registeration', (done) ->
    bot = createBot()
    i = 0
    middleware1 = (args..., next) ->
      i = 1
      next()

    middleware2 = (args..., next) ->
      done() if i is 1

    bot.on 'test', middleware1, middleware2, ->
    bot.emit 'test'
