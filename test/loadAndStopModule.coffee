_      = require 'underscore'
assert = require 'assert'
Domo   = require '../index'

describe 'route', ->
  it 'should be created when domo.route is used', ->
    domo = new Domo
    domo.route 'hello', ->
    assert.ok domo.router.routeMap.hasOwnProperty('hello') and
    _.findWhere(domo.router.routes, src: 'hello')?

  it 'should be destructed when domo.restructRoute is used', ->
    domo = new Domo
    domo.route 'hello', ->

    domo.destructRoute 'hello'

    console.log _.findWhere(domo.router.routes, src: 'hello')
    assert.ok not domo.router.routeMap.hasOwnProperty('hello') and
    not _.findWhere(domo.router.routes, src: 'hello')?



