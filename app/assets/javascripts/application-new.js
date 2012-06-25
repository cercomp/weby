//= require jquery
//= require jquery_ujs 
//= require bootstrap
//= require tables
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

// Mostrar mensagem para erros, no retorno do ajax
FlashMsg = {
   notify: function(status){
      //TODO algumas requisições ajax, retornam 500, mesmo quando OK
      //if([403,500].indexOf(status)>-1){
      if(status == 403){
         //flash = $(document.createElement('div'));
         //$('#content').prepend(flash);
         //flash.addClass('alert alert-error notify');
         //flash.text(status==403 ?'Acesso Negado':status==500 ?'Erro no servidor':'');
         //flash.append('<a class="close" data-dismiss="alert" href="#">×</a>');
         //flash.append(status==403 ?'Acesso Negado':'');
         $('<div class="modal">'+
             '<div class="modal-header"><h3>Acesso Negado</h3></div>'+
             '<div class="modal-body">'+
             '<div class="alert alert-error">Você não possui permissão para esta ação</div></div>'+
             '<div class="modal-footer"><a class="btn btn-primary" data-dismiss="modal">OK</a></div>'+
             '</div>').modal('show');
      }
   }
}

function addToSelect(selectId, text){
   var new_cat = prompt(text), option = new Option(new_cat);
   if(!new_cat) return;
   $(selectId).append(option);
   $(option).attr('selected', true);
}

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
   // Ajax indicator
   $('body').ajaxComplete(function(evt,xhr){
      FlashMsg.notify(xhr.status);
   });

   //Fixar o menu admin quando o usuário rola a página
   //inclusive responsivo
   var menuadmin = $('#menu-admin');
   var webynavbar = $('#weby-navbar');
   $(window).scroll(function(){
       if($(window).width() >= 768){
           maincontainer = $('#main-container');
           webybarheight = webynavbar.css('position')=='fixed'? webynavbar.height() : 0;
           windowtop = $(this).scrollTop() + webybarheight;
           if(windowtop >= maincontainer.position().top){
               if(menuadmin.css('position')!='fixed')
                   menuadmin.css({'position':'fixed',
                   'top':(webybarheight+parseInt(maincontainer.css("padding-top")))+'px',
                   'width':menuadmin.width()+'px'});
           }else{
               if(menuadmin.css('position')=='fixed')
                   menuadmin.css({'position':'','top':'', 'width':''});
           }
       }
    });
    $(window).resize(function(){
        menuadmin.css({'position':'','top':'', 'width':''});
        $(window).scroll();
    });
});
