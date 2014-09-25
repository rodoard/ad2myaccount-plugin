var local_storage_remove, local_storage_set, send_message_to_control;

function local_storage_get(key, callback) {
    storage.get(key, callback)
};

function local_storage_set(data, callback) {
    storage.set(data, callback)
};

function local_storage_remove(key, callback) {
    storage.remove(key, callback)
  };

function send_message_to_control(msg) {
    chanel.publish("a2ma:control", {msg:msg})
}

 refresh_status = function() {
      console.log("Refreshing Status");
      return local_storage_get("ad_status", function(items) {
        var status;
        status = items.ad_status;
        if ((status != null) && status) {
          console.log("Ads RUNNING");
          $(".ad-status").text("RUNNING");
          $(".ad-status").removeClass("inactive");
          $(".ad-status").addClass("active");
          $(".toggle-ads").addClass("started");
          return $(".toggle-ads").removeClass("stopped");
        } else {
          console.log("Ads STOPPED");
          $(".ad-status").text("STOPPED");
          $(".ad-status").removeClass("active");
          $(".ad-status").addClass("inactive");
          $(".toggle-ads").addClass("stopped");
          return $(".toggle-ads").removeClass("started");
        }
      });
    };