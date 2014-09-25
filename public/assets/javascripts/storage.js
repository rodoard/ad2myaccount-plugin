var storage = {
    get: function(key, callback) {
         console.log("emit storage-get ", key)
          result = {}
          result[key] = $.jStorage.get(key)
          callback( result )
    },
    set: function(data, callback) {
       for (key in data) {
        console.log("emit storage-set ", key, data[key])
         $.jStorage.set(key, data[key])
        }
           callback();
    },
    remove: function(key, callback) {
        console.log("emit storage-delete ", key)
        $.jStorage.deleteKey(key)
         callback()

    }

}