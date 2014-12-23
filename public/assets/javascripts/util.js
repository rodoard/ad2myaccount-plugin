var sendParentMessage = function(msg) {
    parent.postMessage(msg, "*")
}

var serializeForm = function(form) {
        var a, o;
        o = {};
        a = form.serializeArray();
        $.each(a, function() {
            if (o[this.name] !== undefined) {
                if (!o[this.name].push) {
                    o[this.name] = [o[this.name]];
                }
                return o[this.name].push(this.value || "");
            } else {
                return o[this.name] = this.value || "";
            }
        });
        return o;
}

var searchEngineFormSubmit = function(id) {
    params = queryParams()
    $('#q').val(params['keyword'])
    console.log($(id))
    $(id).submit()
}
var queryParams = function() {
    var vars = [], hash;
    var q = document.URL.split('?')[1];
    if(q != undefined){
        q = q.split('&');
        for(var i = 0; i < q.length; i++){
            hash = q[i].split('=');
            vars.push(hash[1]);
            vars[hash[0]] = hash[1];
        }
    }
    return vars
}
