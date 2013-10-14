colors = require 'colors'
irc    = require 'irc'
_      = require 'underscore'
util   = require 'util'

class module.exports extends irc.Client
  constructor: ->
    @middlewares = []
    @modules = {}

    super

    @on 'error', (event) -> @error JSON.stringify event.command.toUpperCase()

    @load module for module in @opt.modules if @opt.modules?

  connect: ->
    @info "Connecting to #{@opt.server}"

    super

    @once 'registered', -> @info "Connected to #{@opt.server}"

  log: -> util.log arg, colors: true for arg in arguments

  info: ->
    for arg in arguments
      util.log 'Info: '.green + util.inspect arg, colors: true

  warn: ->
    for arg in arguments
      util.log 'Warn: '.yellow + util.inspect arg, colors: true

  error: ->
    for arg in arguments
      util.log 'Error: '.red + util.inspect arg, colors: true

  load: (moduleName, moduleClass) =>
    unless moduleClass?
      try
        moduleClass = require(moduleName)
      catch err
        msg = if err.code is 'MODULE_NOT_FOUND'
          "Module #{moduleName} not found"
        else
          "Module #{moduleName} cannot be loaded"
        return @error msg, err.message

    if @modules.hasOwnProperty moduleName
      return @error "Module #{moduleName} already loaded"

    @modules[moduleName] = new moduleClass @moduleInstance(moduleName)

    @info "Loaded module #{moduleName}"


  unload: (moduleName, inRequireCache = true) =>
    unless @modules.hasOwnProperty moduleName
      return @error "Module #{mod} not loaded"

    @modules[moduleName].destruct?()

    delete require.cache[require.resolve(moduleName)] if inRequireCache
    delete @modules[moduleName]

    for eventName, events of @._events
      if _.isArray(events)
        @._events[eventName] = _.filter events, (event) ->
          not event.moduleName? or event.moduleName isnt moduleName
        break
      if events.moduleName? and events.moduleName is moduleName
        delete @._events[eventName]


    @info "Unloaded module #{moduleName}"

  moduleInstance: (moduleName) =>
    _.extend _.omit(@, ['on']),
      on: (event, middlewares..., fn) =>
        wrapped = @wrap fn, middlewares
        wrapped.moduleName = moduleName
        @addListener event, wrapped

  on: (event, middlewares..., fn) ->
    @addListener event, @wrap fn, middlewares

  once: (event, middlewares..., fn) -> super event, @wrap fn, middlewares

  wrap: (fn, middlewares) -> (args...) =>
    _.reduceRight(@middlewares.concat(middlewares), (memo, item) =>
      next = => memo.apply @, args
      return -> item.apply @, [args..., next]
    , fn).apply @, arguments

  use: -> @middlewares.push arguments...
