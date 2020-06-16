$(document).ready(function(){

  var editor = $('.code-area').data('codemirrorInstance');

  editor.on("change", function(cm, change) {
    $('.btn-apply').prop('disabled',false);
  });

  var flashMsgApply = function(title, content) {
    $('.btn-apply').popover({title:title,content:"<span style=\"font-size: 12pt;\">"+content+"</span>",animation:true, placement: "right", html: true, trigger: "manual"}).popover('show');
    setTimeout(function(){
      $('.btn-apply').popover('hide');
    },2000);
  };

  $('.btn-apply').click(function(){
    $.ajax({
      url: $(this).closest('form').prop('action'),
      type: "PUT",
      data: {'style[css]': editor.getValue()},
      dataType: "json",
      success: function(data, st, jqxhr){
        flashMsgApply(`<img src="${data.icon}"/>`, data.message);
        if(data.ok){
          $('#preview-css-panel iframe')[0].contentWindow.location.reload();
        }else {
          $('.btn-apply').prop('disabled',false);
        }
      },
      error: function(jqxhr, st, error){
        var data = jqxhr.responseJSON;
        flashMsgApply(`<img src="${data.icon}"/>`, data.message);
        $('.btn-apply').prop('disabled',false);
      },
      beforeSend: function(){
        $('.btn-apply').prop('disabled',true);
      }
    })
  });
});
