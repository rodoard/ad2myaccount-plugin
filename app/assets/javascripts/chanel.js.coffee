modulejs.define "chanel", ->
  subscribe: (_chanel, callback) ->
    console.log "emit subscribe to ", _chanel
    $.jStorage.subscribe _chanel, callback
    return

  publish: (_chanel, payload) ->
    console.log "publish payload onto ", _chanel, payload
    $.jStorage.publish _chanel, payload
    return