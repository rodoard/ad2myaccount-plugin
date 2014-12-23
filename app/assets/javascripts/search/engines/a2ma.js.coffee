modulejs.define "engines/a2ma", ["engine"], (Engine) ->
  a2ma = new Engine "a2ma"
  $.extend a2ma,
    src: ->
      "/search/#{@name}"