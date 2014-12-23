modulejs.define "a2ma", ["config", "helpers", "chanel"], (Config, Helpers, Chanel) ->
  init: ->
    url = Config.url
    scrollToYPos = 0
    muted = false
    interval = 0
    remaining = -1
    messageEvent = "message"
    checkPos = ->
      unless $(window).scrollTop() is scrollToYPos
        window.scrollTo 0, scrollToYPos
        checkPos()
      return

    preventDefault = (e) ->
      e = e or window.event
      e.preventDefault()  if e.preventDefault
      e.returnValue = false
      return
    send_ad_control_message = (message, data=false) ->
      if $(".a2ma-iframe").length > 0
        iframe = $(".a2ma-iframe")[0].contentWindow
        if data
          params = message
        else
          params =
            command:message

        iframe.postMessage params, "*"

    keydown = (e) ->
      i = keys.length
      while i--
        if e.keyCode is keys[i]
          preventDefault e
        return
      return

    wheel = (e) ->
      preventDefault e
      return

    disable_scroll = ->
      interval = window.setInterval(checkPos, 0)
      window.addEventListener "DOMMouseScroll", wheel, false  if window.addEventListener
      window.onmousewheel = document.onmousewheel = wheel
      document.onkeydown = keydown
      return

    enable_scroll = ->
      window.clearInterval interval
      window.removeEventListener "DOMMouseScroll", wheel, false  if window.removeEventListener
      window.onmousewheel = document.onmousewheel = document.onkeydown = null
      return

    keys = [
      37
      38
      39
      40
    ]
    get_keywords = ->
      $.ajax
        url: "" + url + "/keywords/common.json"
        dataType: "json"
        contentType: "application/json"
        success: (data, status, request) ->
          common_words = {}
          keywords = {}
          _i = 0
          _len = data.length

          while _i < _len
            common_word = data[_i]
            common_words[common_word] = true
            _i++
          text = $("body").text()
          words = text.split(" ")
          _j = 0
          _len1 = words.length

          while _j < _len1
            word = words[_j]
            word = S(word).toLowerCase().trim()
            if not common_words[word.s] and word.length > 2 and word.isAlpha()
              word = word.s
              keywords[word] = 0  unless keywords[word]?
              keywords[word] = keywords[word] + 1
            _j++
          keyword_array = []
          for keyword of keywords
            count = keywords[keyword]
            keyword_array.push [
              keyword
              count
            ]
          keyword_array.sort (a, b) ->
            b[1] - a[1]

          result = {}
          keyword_array.slice(0, Math.max(30, keyword_array.length)).map (tuple) ->
            keyword = tuple[0]
            count = tuple[1]
            result[keyword] = count

          Helpers.local_storage_get "mood", (items) ->
            if (items.mood?) and (items.mood.value?)
              emotion_id = items.mood.value
              $.ajax
                type: "POST"
                url: "" + url + "/keywords/activity.json"
                dataType: "json"
                contentType: "application/json"
                data: JSON.stringify(
                  emotion_id: emotion_id
                  keywords: result
                )
                success: (data, status, request) ->
                  alert "keywords logged!"


    auth_token_param = ->
      userData = Helpers.local_storage_get "user", ->
      "user_email=" + encodeURIComponent( userData.user.email ) +  "&user_token=" + userData.user.authentication_token + "&authentication_token=" + userData.user.authentication_token

    surveyResponse = (params) ->
      data = params['survey']
      respondUrl = url + "/survey/respond.json?authenticity_token=" + data.authenticity_token + "&" +  auth_token_param()
      $.ajax
        url     : "/survey/response"
        type    : "POST"
        dataType: 'json'
        data    :
          url: respondUrl
          survey: data
        success : (data) ->
          console.log('success!')
          showNextAd()
        error   : ( xhr, err ) ->
          console.log('errors!')
          console.log(arguments)

    showSurvey = (offerId) ->
      skipped = false
      src_url = url + "/survey?offering_id=" + offerId + "&skipped=" + skipped + "&" + auth_token_param()
      $.ajax
        type: "GET"
        url: "/ads/survey"
        dataType: "json"
        data:
          url: src_url
          skipped: skipped
        success: (data) ->
          $(".a2ma-iframe").load ->
            params =
              survey:true
              content:data.survey
            console.log "posting message to survey iframe", params
            send_ad_control_message(params, true)
          adTitle = $('#ad-title').text()
          $(".a2ma-iframe").attr('src', "survey.html?offerId="+offerId+"&adId="+ data.ad_id + "&title=" + adTitle + "&skipped=" + skipped +   "&auth_token="+data.auth_token)
          $(".a2ma-iframe").attr('scrolling', "yes")


    inject_iframe = (parameters) ->
      if $(".a2ma-iframe").length is 0
        size = parameters.size
        remaining = parameters.remaining
        authentication_token = auth_token_param()
        if parameters.offering_id?
          sample = "/ads/sample?offering_id=" + parameters.offering_id  + "&" + authentication_token
        else
          sample =  "/ads/sample?" + authentication_token
        src_url =  url + sample
        $.ajax
          type: "GET"
          url: "/ads/sample"
          dataType: "json"
          data:
            url: src_url
          success: (data) ->
            mp4 = data.mp4
            webm = data.webm
            goToUrl = data.go_to_site_url
            contentUrl = data.content_container_url
            offerId = data.offer_id
            adTitle = data.title
            duration = data.duration
            adId = data.ad_id
            queryString = "mp4="+ mp4 + "&webm="+ webm + "&contentUrl=" + contentUrl + "&duration="+duration+"&offerId="+offerId
            iframe = "<iframe class='a2ma-iframe' wmode='Opaque' src='" + "sample.html?" + queryString+ "" + "' style='border:none;position:relative' scrolling='no' frameborder=0 width='100%' height='100%' allowfullscreen='true' webkitallowfullscreen='true' mozallowfullscreen='true'> </iframe>"
            console.log(data)
            console.log(iframe)
            Helpers.hide_tube_spinner()
            $("#ad-tube .tube .frame").html iframe
            $('a.go_to_site').attr('href', goToUrl)
            $('#ad_id').val(adId)
            $('#ad-title').text(adTitle)
            Helpers.refresh_status()
            $(".a2ma-iframe").load ->
              iframe = $(".a2ma-iframe")[0].contentWindow
              console.log "posting message to iframe", parameters
              iframe.postMessage
                size: parameters.size
                remaining: parameters.remaining
              , "*"
              parameters.remaining = null

            if size is "full"
              disable_scroll()
            else
              enable_scroll()

    clearCurrentAd = ->
      $('a.go_to_site').attr('href', '')
      $('#ad_id').val('')
      $('#ad-title').text('')

    report_status = ->
      $iframe = $(".a2ma-iframe")
      send_message
        msg: "status"
        size: (if $iframe.hasClass("full") then "full" else "mini")
        offering_id: $iframe.data("offering_id")
        remaining: $iframe.data("remaining")
      , ->


    remove_iframe = ->
      if $(".a2ma-iframe").length > 0
        report_status()
        enable_scroll()
        clearCurrentAd()
        $(".a2ma-iframe").remove()

    minimize = ->
      $iframe = $(".a2ma-iframe")
      $iframe.removeClass "full"
      $iframe.addClass "mini"
      $iframe.css "height", ""
      enable_scroll()

    maximize = ->
      $iframe = $(".a2ma-iframe")
      $iframe.removeClass "mini"
      $iframe.addClass "full"
      $iframe.css "height", "100%"
      disable_scroll()

    data_received = {}
    reporter = (e) ->
      console.log "parent received message!:  ", e.data, window.location.href
      $iframe = $(".a2ma-iframe")
      if e.data.ad_finished
        Helpers.send_message_to_control { offer_id:e.data.offer_id, show_survey:true}
      if e.data.surveyResponse
        Helpers.send_message_to_control e.data
      if e.data.showFindItResults
        Helpers.findIt.showResults(e.data.results_id)
      if e.data is "showNextAd"
        Helpers.send_message_to_control "showNextAd"
      if e.data is "minimize"
        minimize()
      else if e.data is "maximize"
        maximize()
      else if e.data is "close"
        Helpers.local_storage_set
          ad_status: false
        , ->
          remove_iframe()
          Helpers.refresh_status()

        remove_iframe()
      else if e.data.remaining?
        $iframe.data "remaining", e.data.remaining.time
        report_status()
      else if e.data.offering?
        offering_id = e.data.offering.id
        if (offering_id?) and offering_id isnt ""
          $iframe.data "offering_id", offering_id
          console.log "set offering_id", offering_id

    send_message = (msg) ->

    addListeners = ->
        console.log "added window event listener"
        window.addEventListener messageEvent, reporter, false

    stopAds = ->
      remove_iframe()

    startAds = (params={})->
      Helpers.local_storage_get "user", (data) ->
        inject_iframe params  if data.user?

    removeListeners = ->
      console.log "removed window event listener"
      window.removeEventListener messageEvent, reporter, false
    removeListeners()
    addListeners()

    showNextAd = (request) ->
      stopAds()
      startAds(request)

    $ ->
      console.log "attached event"

      console.log "setting up a2ma:control listeners"
      Chanel.subscribe "a2ma:control", (chanel, request) ->
        console.log "container: received message: ", request
        if request.msg is "startAds"
          startAds(request)
        else if request.msg is "showNextAd"
          showNextAd()
        else if request.msg is "detach"
          console.log "detaching window event listener"
          window.removeEventListener messageEvent, reporter, false
        else if request.msg is "stopAds"
          stopAds()
        else if request.msg.show_survey
          showSurvey(request.msg.offer_id)
        else if request.msg.surveyResponse
          surveyResponse(request.msg.data)
        else if request.msg is "pauseAds"
          send_ad_control_message "pauseAds"
        else send_ad_control_message "restartAds"  if request.msg is "restartAds"
    return