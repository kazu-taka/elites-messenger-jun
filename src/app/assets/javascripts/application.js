// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require turbolinks
//= require_tree .
$(function() {
  var initPostButtonEvent;
  initPostButtonEvent = function() {
    return $('form.input_message_form input.post').click((function(_this) {
      return function(e) {
        var form;
        form = $('form.input_message_form');
        form.removeAttr('data-remote');
        form.removeData("remote");
        return form.attr('action', form.attr('action').replace('.json', ''));
      };
    })(this));
  };
  initPostButtonEvent();
  return $('form.input_message_form').on('ajax:complete', function(event, data, status) {
    var json;
    if (status === 'success') {
      json = JSON.parse(data.responseText);
      $('div.timeline').prepend($(json.timeline));
      return initPostButtonEvent();
    }
  });
});