var chanel = {
    subscribe: function(_chanel, callback) {
       console.log("emit subscribe to ", _chanel)
        $.jStorage.subscribe(_chanel, callback)
    },
    publish: function(_chanel, payload) {
        console.log("publish payload onto ", _chanel, payload)
        $.jStorage.publish(_chanel, payload);
    }
}