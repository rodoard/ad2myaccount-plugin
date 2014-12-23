controller_action = ->
  jQuery ->
    controller = $('body').data('controller')
    action = $('body').data('action')
    params = $('body').data('params')
    console.log(window[controller])
    if window[controller]
      controller = new window[controller]
      if controller[action]

        controller[action](params)

window.controller_action = controller_action