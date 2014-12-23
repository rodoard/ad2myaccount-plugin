modulejs.define "engine", ->
  iframe = (keyword)->
    queryString = "keyword=#{keyword}"
    "<iframe class='search-result-frame #{@name}' width='100%' height='900px' src='" + "#{@src()}?" + queryString + "'></iframe>"
  (name)->
    postProcess: ->
    src: ->
      "#{@name}.html"
    container: ->
      "#search_result_#{@name}"
    name: name
    search: (keyword) ->
      container = $(@container())
      frame = iframe.call(@, keyword)
      $(container).html(frame)
      self = @
      $('.search-result-frame').load ->
        self.postProcess()