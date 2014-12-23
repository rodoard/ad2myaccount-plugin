modulejs.define "main", ["helpers", "config", "a2ma"], (Helpers, Config, A2ma) ->
  a2maInit: ->
    $ ->
      url = Config.url
      refresh_user_state = ->
        Helpers.local_storage_get "user", (items) ->
          console.log "User callback, %o, %o", items, items.user
          $signed_out_area = $("#user-not-signed-in")
          $signed_in_area = $("#user-signed-in, .account-info")
          if items.user?
            console.log "should be visible"
            $signed_in_area.show()
            $(".account-info .name").text items.user.name
            $signed_out_area.hide()
          else
            console.log "should be hidden"
            $signed_in_area.hide()
            $signed_out_area.show()

      populate_emotions = ->
        $.ajax
          url: "" + url + "/emotions.json"
          dataType: "json"
          contentType: "application/json"
          success: (data, status, request) ->
            arr = [
              val: 1
              text: "One"
            ,

              val: 2
              text: "Two"
            ,

              val: 3
              text: "Three"

            ]
            sel = $("<select>")
            $(".mood .lists").html(sel)
            sel.append $("<option>").attr("value", "").text("Select your mood...")
            $(data.emotions).each ->
              sel.append $("<option>").attr("value", @id).text(@name)

            Helpers.local_storage_get "mood", (items) ->
              console.log "mood: %o", items
              if (items.mood?) and (items.mood.value?) and (items.mood.update_time?)
                sel.val items.mood.value
                update_time = new Date(items.mood.update_time)
                update_time.setTime update_time.getTime() + (2 * 60 * 60 * 1000)
                if update_time > Date.now()
                  sel.val items.mood.value
                else
                  Helpers.local_storage_remove "mood"

      send_ad_message = (msg) ->
        console.log "send_ad_message", msg
        Helpers.send_message_to_control msg

      $(".toggle-ads").click (event) ->
        toggleAds = $(this)
        Helpers.local_storage_get "ad_status", (items) ->
          console.log "ad_status: ", items
          running = Helpers.ads_running items.ad_status
          if !running
            msg = "startAds"
          else
            msg = "stopAds"
          if $(".mood select").val() is ""
            console.log($(".mood .error"))
            $(".mood .error").html("<p>You need to select a mood before starting ads.</p>")
            return false
          else
            toggleAds.fadeOut()
            Helpers.show_tube_spinner()
            $(".mood").find(".error").remove()
            send_ad_message msg
            Helpers.local_storage_set
              ad_status: !running
            , ->

            Helpers.local_storage_set
              mood:
                value: $(".mood select").val()
                update_time: Date.now()
            , ->

      console.log "Popup Ready"
      Helpers.refresh_status()
      refresh_user_state()
      populate_emotions()
      A2ma.init()
    return 