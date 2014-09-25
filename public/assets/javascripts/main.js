(function() {
  var checkPos, data_received, disable_scroll, enable_scroll, get_keywords, inject_iframe, interval, keydown, keys, maximize, messageEvent, minimize, muted, preventDefault, remaining, remove_iframe, report_status, reporter, scrollToYPos, url, wheel;

  url = "https://www.ad2myaccount.com";

  scrollToYPos = 0;

  interval = null;

  muted = false;

  remaining = -1;

  messageEvent = "message";

  checkPos = function() {
    if (!($(window).scrollTop() === scrollToYPos)) {
      window.scrollTo(0, scrollToYPos);
      checkPos();
    }
  };

  preventDefault = function(e) {
    e = e || window.event;
    if (e.preventDefault) {
      e.preventDefault();
    }
    e.returnValue = false;
  };

  keydown = function(e) {
    var i;
    i = keys.length;
    while (i--) {
      if (e.keyCode === keys[i]) {
        preventDefault(e);
        return;
      }
    }
  };

  wheel = function(e) {
    preventDefault(e);
  };

  disable_scroll = function() {
    interval = setInterval(checkPos, 0);
    if (window.addEventListener) {
      window.addEventListener("DOMMouseScroll", wheel, false);
    }
    window.onmousewheel = document.onmousewheel = wheel;
    document.onkeydown = keydown;
  };

  enable_scroll = function() {
    clearInterval(interval);
    if (window.removeEventListener) {
      window.removeEventListener("DOMMouseScroll", wheel, false);
    }
    window.onmousewheel = document.onmousewheel = document.onkeydown = null;
  };

  keys = [37, 38, 39, 40];

  get_keywords = function() {
    return $.ajax({
      url: "" + url + "/keywords/common.json",
      dataType: "json",
      contentType: "application/json",
      success: function(data, status, request) {
        var common_word, common_words, count, keyword, keyword_array, keywords, result, text, word, words, _i, _j, _len, _len1;
        common_words = {};
        keywords = {};
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          common_word = data[_i];
          common_words[common_word] = true;
        }
        text = $("body").text();
        words = text.split(" ");
        for (_j = 0, _len1 = words.length; _j < _len1; _j++) {
          word = words[_j];
          word = S(word).toLowerCase().trim();
          if (!common_words[word.s] && word.length > 2 && word.isAlpha()) {
            word = word.s;
            if (keywords[word] == null) {
              keywords[word] = 0;
            }
            keywords[word] = keywords[word] + 1;
          }
        }
        keyword_array = [];
        for (keyword in keywords) {
          count = keywords[keyword];
          keyword_array.push([keyword, count]);
        }
        keyword_array.sort(function(a, b) {
          return b[1] - a[1];
        });
        result = {};
        keyword_array.slice(0, Math.max(30, keyword_array.length)).map(function(tuple) {
          keyword = tuple[0];
          count = tuple[1];
          return result[keyword] = count;
        });
        return local_storage_get("mood", function(items) {
          var emotion_id;
          if ((items.mood != null) && (items.mood.value != null)) {
            emotion_id = items.mood.value;
            return $.ajax({
              type: "POST",
              url: "" + url + "/keywords/activity.json",
              dataType: "json",
              contentType: "application/json",
              data: JSON.stringify({
                emotion_id: emotion_id,
                keywords: result
              }),
              success: function(data, status, request) {
                return alert("keywords logged!");
              }
            });
          }
        });
      }
    });
  };

  inject_iframe = function(parameters) {
    var size, src_url;
    if ($(".a2ma-iframe").length === 0) {
      size = parameters.size;
      remaining = parameters.remaining;
      if (parameters.offering_id != null) {
        src_url = "" + url + "/ads/sample?offering_id=" + parameters.offering_id;
      } else {
        src_url = "" + url + "/ads/sample";
      }
      if (size == null) {
        size = "full";
      }
      $("body").append("<iframe class='a2ma-iframe " + size + "' src='" + src_url + "' style='border:none;' scrolling='no' frameborder=0 allowtransparency='true'> </iframe>");
      $(".a2ma-iframe").load(function() {
        var iframe;
        iframe = $(".a2ma-iframe")[0].contentWindow;
        console.log("posting message to iframe", parameters);
        iframe.postMessage({
          size: parameters.size,
          remaining: parameters.remaining
        }, "*");
        return parameters.remaining = null;
      });
      if (size === "full") {
        return disable_scroll();
      } else {
        return enable_scroll();
      }
    }
  };

  report_status = function() {
    var $iframe;
    $iframe = $(".a2ma-iframe");
    return send_message({
      msg: "status",
      size: $iframe.hasClass("full") ? "full" : "mini",
      offering_id: $iframe.data("offering_id"),
      remaining: $iframe.data("remaining")
    }, function() {});
  };

  remove_iframe = function() {
    if ($(".a2ma-iframe").length > 0) {
      report_status();
      enable_scroll();
      return $(".a2ma-iframe").remove();
    }
  };

  minimize = function() {
    var $iframe;
    $iframe = $(".a2ma-iframe");
    $iframe.removeClass("full");
    $iframe.addClass("mini");
    $iframe.css("height", "");
    return enable_scroll();
  };

  maximize = function() {
    var $iframe;
    $iframe = $(".a2ma-iframe");
    $iframe.removeClass("mini");
    $iframe.addClass("full");
    $iframe.css("height", "100%");
    return disable_scroll();
  };

  data_received = {};

  reporter = function(e) {
    var $iframe, offering_id;
    console.log("parent received message!:  ", e.data, window.location.href);
    $iframe = $(".a2ma-iframe");
    if (e.data === "minimize") {
      return minimize();
    } else if (e.data === "maximize") {
      return maximize();
    } else if (e.data === "close") {
      local_storage_set({
        ad_status: false
      }, function() {
        remove_iframe();
        return refresh_status();
      });
      return remove_iframe();
    } else if (e.data.remaining != null) {
      $iframe.data("remaining", e.data.remaining.time);
      return report_status();
    } else if (e.data.offering != null) {
      offering_id = e.data.offering.id;
      if ((offering_id != null) && offering_id !== "") {
        $iframe.data("offering_id", offering_id);
        return console.log("set offering_id", offering_id);
      }
    }
  };

  send_message = function(msg) {
    //reporter({data:msg})
  }

  if (!window.listener_added) {
    console.log("added window event listener");
    window.removeEventListener(messageEvent, reporter, false);
    window.addEventListener(messageEvent, reporter, false);
    window.listener_added = true;
  }

  $(function() {
    var send_ad_control_message;
    console.log("attached event");
    send_ad_control_message = function(command) {
      var iframe;
      if ($(".a2ma-iframe").length > 0) {
        iframe = $(".a2ma-iframe")[0].contentWindow;
        return iframe.postMessage({
          command: command
        }, "*");
      }
    };
    console.log("setting up a2ma:control listeners");
    return chanel.subscribe("a2ma:control", function(chanel, request) {
      console.log("container: received message: ", request);
      if (request.msg === "startAds") {
        return local_storage_get("user", function(data) {
          if (data.user != null) {
            return inject_iframe(request);
          }
        });
      } else if (request.msg === "detach") {
        console.log("detaching window event listener");
        return window.removeEventListener(messageEvent, reporter, false);
      } else if (request.msg === "stopAds") {
        return remove_iframe();
      } else if (request.msg === "pauseAds") {
        return send_ad_control_message("pauseAds");
      } else if (request.msg === "restartAds") {
        return send_ad_control_message("restartAds");
      }
    });
  });

}).call(this);
