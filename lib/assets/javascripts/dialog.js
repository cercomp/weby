$.extend($.ui.dialog.prototype.options, {
   width: '630px',
   height: 500,
   modal: true,
   draggable: false,
   show: 'blind',
   hide: 'blind',
   resizable: false,
   position: ['center', 'top'],
   open: function(event, ui){
      $('body').css('overflow','hidden');
      $('.ui-widget-overlay').css('width','100%'); 
   }, 
   close: function(event, ui){
      $('body').css('overflow','auto'); 
   } 
});
