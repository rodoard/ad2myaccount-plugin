modulejs.define "user", ["helpers", "config", "storage"], (Helpers, Config, Storage) ->
  checkLogin: ->
    $('a.signout').click (e) ->
      e.preventDefault()
      Helpers.local_storage_remove "user"
      $.ajax
        type: "GET"
        url: "" + Config.url + "/users/sign_out.json"
        dataType: "json"
        contentType: "application/json"
        success: ->
          console.log "signout successful"
        error: ->
          console.log "signout failed"
      window.location = "/"

    Helpers.local_storage_get "user", (data)->
      console.log(data)
      if data.user
        $('a.signin').hide()
        $('a.signout').show()
      else
        $('a.signout').hide()
        $('a.signin').show()

  signin: (redirect_url) ->
    $("#sign-in").submit (e) ->
      console.log "submitting form"
      $this = $(this)
      data = user: Helpers.serializeForm($this)
      e.preventDefault()
      $.ajax
        crossDomain: true
        xhrFields:
          withCredentials: true
        type: "POST"
        url: "" + Config.url + "/users/sign_in.json"
        data: JSON.stringify(data)
        dataType: "json"
        contentType: "application/json"
        error: (request, status, error) ->
          console.log "request: ", request
          message = "An error occurred while signing in. Please try again. " + status + error + request.status
          message = request.responseJSON.error  if (request.responseJSON?) and (request.responseJSON.error?)
          $(".error").html message
        success: (data, status, request) ->
          $(".error").text ""
          $("#sign-in").find("input[type='password']").val ""
          Helpers.local_storage_set user: data, ->
            window.location = if redirect_url
                redirect_url
              else
                "/"
      return false