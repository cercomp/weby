//= require jquery
//= require jquery_ujs 
//= require bootstrap
//= require_self

var WEBY = {};

function show_dialog(ele) {
  if(!$('#modal_page_list').length){
     $('body').append('<div id="modal_page_list" class="modal fade" style="display: none;">'+
'<div class="modal-header"><h3>Selecione uma notícia</h3></div>'+
'<div class="modal-body"></div>'+
'<div class="modal-footer"><a href="#" class="btn" data-dismiss="modal">Fechar</a></div>'+
'</div>');
  }
  
  $.get(ele.attr('data-link'),{'template' : 'list_popup'}, function(data){
      $('#modal_page_list').modal('show');
  }, 'script');

}

$(document).ready(function() {

})
