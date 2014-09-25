start_ads = function(worker) {
    var items, parameters;
    items = storage["ad_status"];
    console.debug("storage[ad_status]", items);
    if ((items != null) && items.ad_status) {
      parameters = storage["status"];
      if (parameters == null) {
        parameters = {};
      }
      parameters.msg = "startAds";
      console.debug("starting ads ", parameters);
      return worker.port.emit("control", parameters);
    }
  };