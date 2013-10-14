_      = require 'underscore'
assert = require 'assert'

Bot = require '../index'

createBot = ->
  new Bot 'irc.datnode.net', 'TestBot',
    autoConnect: false

describe 'Module', ->
  it 'should be possible to be loaded with "load" method', (done) ->
    bot = createBot()
    bot.load 'testModule', class TestModule
      constructor: (bot) ->
        done()

  it 'should be stored to bot.modules', () ->
    bot = createBot()
    bot.load 'testModule', class TestModule
      constructor: (bot) ->

    assert.ok bot.modules['testModule']?

  it 'should removed from bot.modules with bot.unload', () ->
    bot = createBot()
    bot.load 'testModule', class TestModule
      constructor: (bot) ->

    bot.unload 'testModule', false
    assert.ok not bot.modules['testModule']?

describe 'Modules registered events', ->
  it 'should work', (done) ->
    bot = createBot()

    bot.load 'testModule', class TestModule
      constructor: (bot) ->
        bot.on 'testing', done

    bot.emit 'testing'

  it 'should be cleared on unload', () ->

    bot = createBot()

    bot.load 'testModule', class TestModule
      constructor: (bot) ->
        bot.on 'testing', ->

    bot.unload 'testModule', false

    assert.ok not _.findWhere(bot.listeners('testing'), moduleName: 'testModule')?

  it 'shouldnt mess with other handlers after unload', (done) ->
    bot = createBot()

    bot.on 'testing', done

    bot.load 'testModule', class TestModule
      constructor: (bot) ->
        bot.on 'testing', ->

    bot.unload 'testModule', false
    bot.emit 'testing'

  it 'shouldnt mess with other module handlers after unload', (done) ->
    bot = createBot()

    bot.load 'testModule1', class TestModule
      constructor: (bot) ->
        bot.on 'testing', done

    bot.load 'testModule2', class TestModule
      constructor: (bot) ->
        bot.on 'testing', ->

    bot.unload 'testModule2', false
    bot.emit 'testing'

