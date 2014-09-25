var a2maInit = function() {
  $.fn.serializeObject = function() {
    var a, o;
    o = {};
    a = this.serializeArray();
    $.each(a, function() {
      if (o[this.name] !== undefined) {
        if (!o[this.name].push) {
          o[this.name] = [o[this.name]];
        }
        o[this.name].push(this.value || "");
      } else {
        o[this.name] = this.value || "";
      }
    });
    return o;
  };

  $(function() {
    var populate_emotions, refresh_user_state, send_ad_message, url;
    url = "https://www.ad2myaccount.com";
    refresh_user_state = function() {
      return local_storage_get("user", function(items) {
        var $signed_in_area, $signed_out_area;
        console.log("User callback, %o, %o", items, items.user);
        $signed_out_area = $("#user-not-signed-in");
        $signed_in_area = $("#user-signed-in, .account-info");
        if (items.user != null) {
          console.log("should be visible");
          $signed_in_area.show();
          $(".account-info .name").text(items.user.name);
          return $signed_out_area.hide();
        } else {
          console.log("should be hidden");
          $signed_in_area.hide();
          return $signed_out_area.show();
        }
      });
    };

    populate_emotions = function() {
      return $.ajax({
        url: "" + url + "/emotions.json",
        dataType: "json",
        contentType: "application/json",
        success: function(data, status, request) {
          var arr, sel;
          arr = [
            {
              val: 1,
              text: "One"
            }, {
              val: 2,
              text: "Two"
            }, {
              val: 3,
              text: "Three"
            }
          ];
          sel = $("<select>").appendTo(".mood");
          sel.append($("<option>").attr("value", "").text("Select one"));
          $(data.emotions).each(function() {
            return sel.append($("<option>").attr("value", this.id).text(this.name));
          });
          return local_storage_get("mood", function(items) {
            var update_time;
            console.log("mood: %o", items);
            if ((items.mood != null) && (items.mood.value != null) && (items.mood.update_time != null)) {
              sel.val(items.mood.value);
              update_time = new Date(items.mood.update_time);
              update_time.setTime(update_time.getTime() + (2 * 60 * 60 * 1000));
              if (update_time > Date.now()) {
                return sel.val(items.mood.value);
              } else {
                return local_storage_remove("mood");
              }
            }
          });
        }
      });
    };
    $("#sign-in").submit(function(e) {
      var $this, data;
      console.log("submitting form");
      data = {
        user: $(this).serializeObject()
      };
      $this = $(this);
      e.preventDefault();
      $.ajax({
        crossDomain: true,
        xhrFields: {
          withCredentials: true
        },
        type: "POST",
        url: "" + url + "/users/sign_in.json",
        data: JSON.stringify(data),
        dataType: "json",
        contentType: "application/json",
        error: function(request, status, error) {
          var message;
          console.log("request: ", request);
          message = "An error occurred while signing in. Please try again. " + status + error + request.status;
          if ((request.responseJSON != null) && (request.responseJSON.error != null)) {
            message = request.responseJSON.error;
          }
          return $(".error").text(message);
        },
        success: function(data, status, request) {
          $(".error").text("");
          $("#sign-in").find("input[type='password']").val("");
          return local_storage_set({
            user: data
          }, function() {
            refresh_user_state();
          });
        }
      });
      return e.preventDefault();
    });
    send_ad_message = function(msg) {
      console.log("send_ad_message", msg);
      return send_message_to_control(msg);
    };
    $(".toggle-ads").click(function() {
      return local_storage_get("ad_status", function(items) {
        var msg, status;
        console.log("ad_status: ", items);
        status = items.ad_status;
        if ((status != null) && status) {
          status = false;
        } else {
          status = true;
        }
        if (status) {
          msg = "startAds";
        } else {
          msg = "stopAds";
        }
        if ($(".mood select").val() === "" && status === true) {
          if ($(".mood .error").length === 0) {
            return $(".mood").prepend($("<p>You need to select a mood before starting ads.</p>").addClass("error"));
          }
        } else {
          $(".mood").find(".error").remove();
          send_ad_message(msg);
          local_storage_set({
            ad_status: status
          }, function() {
            return refresh_status();
          });
          return local_storage_set({
            mood: {
              value: $(".mood select").val(),
              update_time: Date.now()
            }
          }, function() {});
        }
      });
    });
    $("#signout-button").click(function() {
      return $.ajax({
        type: "GET",
        url: "" + url + "/users/sign_out.json",
        dataType: "json",
        contentType: "application/json",
        success: function() {
          return local_storage_remove("user", function() {
            return refresh_user_state();
          });
        }
      });
    });
    console.log("Popup Ready");
    refresh_status();
    refresh_user_state();
    return populate_emotions();
  });

}