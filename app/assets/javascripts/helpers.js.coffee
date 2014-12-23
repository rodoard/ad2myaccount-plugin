modulejs.define "helpers", ["storage", "chanel", "findit"], (Storage, Chanel, Findit) ->
  serializeForm: (form) ->
    o = {}
    a = form.serializeArray()
    $.each a, ->
      if o[@name] isnt `undefined`
        o[@name] = [o[@name]]  unless o[@name].push
        o[@name].push @value or ""
      else
        o[@name] = @value or ""
    o
  local_storage_get: (key, callback) ->
    Storage.get key, callback

  show_tube_spinner: ->
    $('#tube-spinner img').show()

  hide_tube_spinner: ->
    $('#tube-spinner img').hide()
  
  local_storage_set: (data, callback) ->
    Storage.set data, callback
    return

  local_storage_remove: (key, callback) ->
    Storage.remove key, callback
    return

  send_message_to_control: (msg) ->
    Chanel.publish(
      "a2ma:control"
      msg: msg
    )
    return

  a2ma_iframe: ->
    $(".a2ma-iframe")

  a2ma_iframe_exists: ->
    console.log($(".a2ma-iframe"))
    @a2ma_iframe().length > 0

  ads_running: (status) ->
    console.log(status? + " ::" + status + " ::" + @a2ma_iframe_exists())
    status? and status and @a2ma_iframe_exists()

  findIt:
    showResults: (resultsId) ->
      Findit.show resultsId
  refresh_status: ->
    console.log "Refreshing Status"
    self = @
    @local_storage_get "ad_status", (items) ->
      status = items.ad_status
      if self.ads_running(status)
        console.log "Ads RUNNING"
        $(".ad-status").text "RUNNING"
        $(".ad-status").removeClass "inactive"
        $(".ad-status").addClass "active"
        $(".toggle-ads").addClass "started"
        $(".toggle-ads").removeClass "stopped"
      else
        console.log "Ads STOPPED"
        $(".ad-status").text "STOPPED"
        $(".ad-status").removeClass "active"
        $(".ad-status").addClass "inactive"
        $(".toggle-ads-control").addClass "toggle-ads"
        $(".toggle-ads").addClass "stopped"
        $(".toggle-ads").removeClass "started"
        $(".toggle-ads").fadeIn()