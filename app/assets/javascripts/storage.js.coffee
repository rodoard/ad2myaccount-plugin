modulejs.define "storage", ["jStorage"], (jStorage) ->
  get: (key, callback) ->
    console.log "emit storage-get ", key
    result = {}
    result[key] = jStorage.get(key)
    callback(result) if callback
    result

  clear: ->
    jStorage.flush()

  set: (data, callback) ->
    for key of data
      console.log "emit storage-set ", key, data[key]
      jStorage.set key, data[key]
    callback()
    return

  remove: (key, callback) ->
    console.log "emit storage-delete ", key
    jStorage.deleteKey key
    callback() if callback
    return