startVideoController = ->
    mute = $(".mute")
    unmute = $(".unmute")
    countdown = $(".countdown")
    domain = "https://www.ad2myaccount.com"
    PAUSED = false
    getTimer = ->
      localStorage.getItem "timer_id"

    storeTimer = (id) ->
      localStorage.setItem "timer_id", id

    removeTimer = ->
      localStorage.removeItem "timer_id"

    playerSize = ->
      (if $(".a2maonline").hasClass("mini") then "mini" else "full")

    clearTimer = ->
      clearInterval(getTimer())
      removeTimer()

    onTimerFired = ->
      console.log("timer fired")
      PAUSED or setVideoPosition(POSITION)
      countdown = $(".countdown")
      (if countdown.length > 0 then (remaining = parseInt(n.data("remaining"))
      videoEnded = $("video").length > 0 and $("video")[0].ended
      (if remaining > 0 and not videoEnded then ((if $("video").length > 0 then 4 is $("video")[0].readyState and (video = $("video")[0]
      remaining = parseInt(message.duration) - parseInt(message.currentTime)) else remaining -= 1) countdown.text("" + remaining + "s") countdown.data("remaining", remaining)
      data =
        remaining:
          time: remaining
      console.log("post remaining", data)
      parent.postMessage(data, "*")
      ) else ( stopVideo()
      (if "mini" is playerSize() then onComplete(->
        redirectTarget()
      ) else postMetric("completed_placeholder", null, null, ->
        redirectSkipped false
      ))
      ))
      ) else undefined)

  redirectSkipped = (skipped) ->
    location.href = "/survey?offering_id=" + $(".a2maonline").data("offering-id") + "&skipped=" + skipped

  $(".message").click(->
    operation = $(this).data("operation")
    parent.postMessage(operation, "*")
    playerControls[operation]()
  )
  $(".go_to_site").click(->
    operation = $(this).data("operation")
    playerControls[operation]()
  )
  playerControls =
    minimize: ->
      $(".a2maonline").removeClass("full")
      $(".a2maonline").addClass("mini")
      mute.show()

    maximize: ->
      $(".a2maonline").removeClass("mini")
      $(".a2maonline").addClass("full")
      playerControls.unmute()
      mute.hide()

    mute: ->
      unmute.show()
      mute.hide()
      $("video").prop("muted", true)

    unmute: ->
      mute.show()
      unmute.hide()
      $("video").prop("muted", false)

    close: ->
      $("video").remove()

  setTimer = ->
    (if null is getTimer() and (console.log("setting up timer")
    countdown.length > 0
    ) then storeTimer(setInterval(onTimerFired, 1e3)) else undefined)

  clearTimer()
  setTimer()
  unmute.hide()
  parent.postMessage(
    offering:
      id: $(".a2maonline").data("offering-id")
  , "*")
  play = ->
    video = $("video")
    (if video.length > 0 then video[0].play() else undefined)

  pause = ->
    n = $("video")
    (if video.length > 0 then video[0].pause() else undefined)

  playVideo = ->
    play()
    setInterval()

  pauseVideo = ->
    pause()
    stopVideo()

  setVideoPosition = (position) ->
    console.log("setting video position")
    null isnt position and position > 0 and (currentPosition = 0
    null isnt $("video")[0].duration and (currentPosition = $("video")[0].duration - parseInt(position)
    currentPosition > 0 and ($("video")[0].currentTime = currentPosition)
    )
    countdown.data("remaining", position)
    )
    PAUSED = true
    console.log("playing video")
    play()
    POSITION = null

  onReceiveMessage = (message) ->
    if console.log("iframe received message!:  ", message.data)
    null isnt message.data.size and ((if "mini" is message.data.size then ($(".a2maonline").addClass("mini")
    $(".a2maonline").removeClass("full")
    ) else "full" is message.data.size and ($(".a2maonline").addClass("full")
    $(".a2maonline").removeClass("mini")
    )))
    null isnt message.data.remaining and (console.log("setting video remaining ", message.data.remaining)
    (if $("video").length > 0 then (l = message.data.remaining
    null is message.data.remaining and $(".countdown").data("remaining", $("video").get(0).duration)
    ) else (console.log("setting remaining ", message.data.remaining)
    countdown.data("remaining", message.data.remaining)
    ))
    )
    null isnt message.data.command
    return pauseVideo()  if command = message.data.command
    "pauseAds" is command

    playVideo()  if "restartAds" is command

  addEventListener = ->
    window.addEventListener("message", onReceiveMessage, false)

  addEventListener()
  handleInactivity = ->
    (if $(".survey-form").data("activity") isnt true then ($(".survey-inactivity").show()
    $(".survey-form").hide()
    ) else undefined)

  trackSurveyActivity = ->
    $(".survey-form").mousemove(->
      $(this).data "activity", true
    )
    setTimeout(handleInactivity, 5e3)

  postMetric = (metric_type, comment, rating, success) ->
    video = $("video")
    PAUSED = false
    video.length and (muted = video.prop("muted"))
    n.length > 0 and (remaining = parseInt(n.data("remaining"))
    duration = parseInt($(".a2maonline").data("duration")) - remaining
    )
    playerSize = "full"
    $(".a2maonline").hasClass("mini") and (playerSize = "mini")
    data = metric:
      muted: PAUSED
      playerSize: playerSize
      seconds: duration
      metric_type: metric_type
      offering_id: $(".a2maonline").data("offering-id")
      comment: comment
      rating: rating

    $.ajax(
      url: "" + domain + "/metrics.json"
      data: JSON.stringify(data)
      dataType: "json"
      contentType: "application/json"
      type: "POST"
    ).done(success)

  redirectHome = ->
    dest = location.href.split("?")[0]
    dest = dest.split("#")[0]
    location.href = dest

  onComplete = (evt) ->
    postMetric "completed", null, null, ->
      navHome()


  navHome = ->
    redirectHome()

  initShare = ->
    $(".like-button").click((event) ->
      self = $(this)
      liked = self.data("liked")
      event.preventDefault()
      (if null isnt liked and liked then undefined else postMetric("liked", null, null, ->
        $(".like-button").text("Liked!")
        self.data("liked", true)
        self.css(":hover", "background-color: #0088FF")
      ))
    )
    $(".star-button").click((event) ->
      self = $(this)
      favorites = self.data("favorites")
      event.preventDefault()
      (if null isnt favorites and favorites then undefined else (data = ad_id: $("#ad_id").val()
      $.ajax(
        type: "post"
        dataType: "json"
        url: "" + z + "/ads/favorite"
        data: data
        success: ->
          $(".star-button").text("Favorites!")
          self.data("favorites", true)
          self.css(":hover", "background-color: #0088FF")
      )
    ))
    )
    $(".share-button").click(->
      self = $(this)
      self.parent("li").html("<a class='btn facebook-button' href='https://www.facebook.com/sharer/sharer.php?u=http://ad2myaccount.com' target='_blank'> <i class='fa fa-facebook'></i> <span class='full'>Facebook</span> </a> <a target='_blank' class='btn twitter-button' data-url='http://ad2myaccount.com' data-lang='en data-text='Join me at Ad2MyAccount! Start getting paid to watch ads, like I do! Click on my referral link to join! #Ad2MyAccount' data-playerSize='400px' href='https://twitter.com/share'> <i class='fa fa-twitter'></i> <span class='full'>Twitter</span> </a>")
    )
    $(".media-button").click(->
      postMetric "shared", null, null, ->

    )
    $(".skip-button").click((event) ->
      event.preventDefault()
      postMetric("skipped", null, null, ->
        i()
      )
    )
    $(".flag-button").click((event) ->
      self = $(this)
      flaged = self.data("flaged")
      event.preventDefault()
      (if null isnt flaged and flaged then undefined else (data = ad_id: $("#ad_id").val()
      $.ajax(
        type: "post"
        dataType: "json"
        url: "" + z + "/ads/flag"
        data: data
        success: ->
          $(".flag-button").text("Flaged!")
          self.data("flaged", not 0)
          self.css(":hover", "background-color: #0088FF")
      )
    ))
    )

  updateAdRating = (rating, rateAd) ->
    a = i = 0
    o = rating - 1

    while o >= i
      e = rateAd.eq(a).find("i")
      e.removeClass("fa-heart-o")
      e.addClass("fa-heart")
      a = i += 1
    if 5 > rating
      adClasses = []
      a = r = u = rating

      while (if 4 >= u then 4 >= r else r >= 4)
        e = message.eq(a).find("i")
        e.removeClass("fa-heart")
        adClasses.push(e.addClass("fa-heart-o"))
        a = (if 4 >= u then ++r else --r)
      adClasses

  initAdRating = ->
    rateAd = $(".rate-ad")
    rateAd.click(->
      rating = $(this).data("rating")
      postMetric("rated", null, rating, ->
        updateAdRating(rating, rateAd)
        $(".a2ma .a2mad").data("posted_rating", rating)
      )
      rateAd.off("mouseleave")
      rateAd.mouseleave(->
        rating = $(".a2ma .a2mad").data("posted_rating")
        updateAdRating(rating, rateAd)
      )
    )
    rateAd.hover(->
      rating = $(this).data("rating")
      updateAdRating(rating, rateAd)
    )
    rateAd.mouseleave(->
      rateAd.find("i").addClass("fa-heart-o").removeClass "fa-heart"
    )

  $(".content-container").click((event) ->
    url = $(this).data("url")
    (if "mini" is playerSize() then postMetric("clicked", null, null, ->
      window.open url
    ) else event.preventDefault())
  )
  $(".navigation-url").click((event) ->
    event.preventDefault()
    href = $(this).attr("href")
    postMetric("clicked", null, null, ->
      window.open href
    )
  )

  initAdRating()
  detectSurveyActivity()
  initShare()

  return