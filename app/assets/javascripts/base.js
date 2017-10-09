//= require jquery
//= require jquery_ujs
//= require moment
//= require moment/pt-br.js
//= require moment/es.js
//= require_self

var WEBY = {};

$(document).ready(function(){
  moment.locale($('html').attr('lang'));
})