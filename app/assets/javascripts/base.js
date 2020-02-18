//= require jquery
//= require jquery_ujs
//= require moment
//= require moment/pt-br.js
//= require moment/es.js
//= require_self

var WEBY = {};

$(document).ready(function(){
  moment.locale($('html').attr('lang'));


  //// Alerts on front end
  var alert = $('.flash-alert');

  if (alert.length > 0) {
    alert.addClass('visible');
    setTimeout(function(){
      alert.removeClass('visible');
    }, 5000);
  };

})