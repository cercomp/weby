// Teste
(function () {
  $(".more").each(function (i, element) {
    $(element).click(function(ev){
      $(this).hide();
      $(this).next().show();
      ev.preventDefault();
    });
  });
})(window);
