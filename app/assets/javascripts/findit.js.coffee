modulejs.define "findit", ->
  spinner:
    show: ->
      $('#findit-spinner img').fadeIn()
    hide: ->
      $('#findit-spinner img').fadeOut()
  show: (resultsId) ->
    self = @
    $.ajax
      url: "/search/results/a2ma.json"
      data:
        search_results_id:resultsId
      success: (data) ->
        html  = $.tmpl($('#find-it-results-template'), data.ads)
        self.spinner.hide()
        $('#find-it-results .gallery #links').html(html)

