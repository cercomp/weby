
$(document).ready(function(){
  var elements = $('.wlax-layer')
  
  var cont = $('.wlax-container');
  var contW = cont.width();
  var contH = cont.height();
  var midX = contW / 2;
  var midY = contH / 2;

  //// adds mousemove event
  cont.mousemove(function(ev){
    if ($(ev.target).is('.layer-safe')) return;
    var x = ev.offsetX < 0 ? 0 : ev.offsetX;
    var y = ev.offsetY < 0 ? 0 : ev.offsetY;
    var skewX = (x - midX) / midX;
    var skewY = (y - midY) / midY;
    elements.each(function(){
      var el = $(this);
      var factorX = el.data('invert') ? skewX*-1 : skewX;
      var factorY = el.data('invert') ? skewY*-1 : skewY;
      el.css({transform: 'translate('+(el.data('rangex')*factorX)+'px, '+(el.data('rangey')*factorY)+'px)'});
    });
  });

});
