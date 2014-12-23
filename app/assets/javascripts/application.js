//= require jquery
//= require jquery.validate
//= require jquery_ujs
//= require json2
//= require bootstrap
//= require string
//= require modulejs
//= require controller_action
//= require jstorage
//= require jsstorage
//= require home
//= require chanel
//= require a2ma
//= require storage
//= require helpers
//= require user
//= require config
//= require main
//= require findit
//= require_tree './search'

$(document).ready( function() {
    user = modulejs.require("user")
    user.checkLogin()
    $('form.validate').each(function(index, form){
        $(form).validate({errorLabelContainer: $(form).find('.error')})
    })
})