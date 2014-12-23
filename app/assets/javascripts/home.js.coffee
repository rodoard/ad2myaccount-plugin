class Home
  signin: (params) ->
    user = modulejs.require("user")
    redirect = params.split('#')[1] if params
    user.signin(redirect)
  ad_tube: ->
    main = modulejs.require("main")
    $('#main #feedback form').bind 'ajax:success', (_, data) ->
      $('#main #feedback #feedbacks').prepend(data.template)
    main.a2maInit()
    search = modulejs.require("search")
    form = $('form#find-it')
    tube = $('#ad-tube .tube')
    findit = modulejs.require("findit")
    form.submit (event) ->
      event.preventDefault()
      find = form.find('input').val()
      if find
        console.log('Looking up: '+ find)
        tube.fadeOut()
        findit.spinner.show()
        search.engines().search(find)

window.Home = Home