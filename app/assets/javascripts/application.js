//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require tables
//= require about
//= require select2
//= require select2_locale_pt-BR
//= require_self

var WEBY = {};

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

$(document).ready(function() {
   // Ajax indicator
   $('body').append($('<div class="modal hide" data-backdrop="false" style="width: 150px; margin: -30px 0 0 -75px; z-index: 66060;" id="loading-modal"><div class="modal-body"><img src="/assets/loading-bar.gif"/></div></div>'));
   $('body').ajaxSend(function(ev, jqXHR, options){
       if(options.files){
          return;
       }
      //Não use a função .modal() pois se a página tiver outro modal, gera comportamento não ideal
      $('#loading-modal').removeClass('hide');
   }).ajaxComplete(function(evt,xhr){
      $('#loading-modal').addClass('hide');
      FlashMsg.notify(xhr.status);
   });

   //Fixar o menu admin quando o usuário rola a página
   //inclusive responsivo
   var menuadmin = $('#menu-admin');
   if(menuadmin.length>0){
       $(window).scroll(function(){
           if($(window).width() >= 768){
               maincontainer = $('#main');
               windowtop = $(this).scrollTop() + 10;
               if(windowtop >= maincontainer.position().top){
                   if(menuadmin.css('position')!='fixed')
                       menuadmin.css({'position':'fixed',
                       'top':(10+parseInt(maincontainer.css("padding-top")))+'px',
                       'width':menuadmin.width()+'px'});
               }else{
                   if(menuadmin.css('position')=='fixed')
                       menuadmin.css({'position':'','top':'', 'width':''});
               }
           }
        });
    }
    $(window).resize(function(){
        menuadmin.css({'position':'','top':'', 'width':''});
        $(window).scroll();
    });

    $(document).on('change', '.pagination select', function(){
        //window.location = $(this).find('option:selected').data('url');
        $.getScript($(this).find('option:selected').data('url'));
    });

    var hash = location.hash
      , hashPieces = hash.split('?')
      , activeTab = $('[href=' + hashPieces[0] + ']');
    activeTab && activeTab.tab('show');
});
