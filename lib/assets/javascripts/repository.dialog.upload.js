//= require jquery-ui/widget
//= require fileupload/jquery.iframe-transport
//= require fileupload/jquery.fileupload
//= require_self
$(function(){

    $('#ajax-upload-form').submit(function(){

        if($('#fileupload').val().length <= 0){
            return false;
        }

        $(this).fileupload('send', {
           url: $(this).prop('action')+ ".json",
           fileInput: $('#fileupload'),
           dataType: "json",
           formData: {"repository[description]" : $("#ajax-upload-form #repository_description").val(),
                      "repository[title]" : $("#ajax-upload-form #repository_title").val(),
                      "repository[legend]" : $("#ajax-upload-form #repository_legend").val(),
                      "repository[site_id]" : $("#dialog-repository-search #site_id").val()}
        });
        return false;
   });

   $('#ajax-upload-form').fileupload({
       replaceFileInput: false,

       add: function (e, data) {
         $(".file-name").text(data.files[0].name);
       },

       done: function (e, data) {
           ///No IE, mesmo com erro, ele dispara a função done, vindo do iframe
          if(data.result.errors){
             handleFail(data.result.errors);
          }else{
             resetFields();
             var repository = data.result.repository;
             var message = data.result.message;
             text_msg = [repository.description,
                   " (", repository.archive_file_name, ")",
                   " - ", message].join('');
              $("#results").prepend('<span class="label label-success">'+text_msg+'</span>');
          }
       },

       fail: function(e, data) {
          //console.log(data.jqXHR.responseText);
          try{
            var errors = JSON.parse(data.jqXHR.responseText).errors;
          }catch(e){
            var errors = [data.jqXHR.responseText.split(/\r?\n/)[0]]
          }
          handleFail(errors);
       },

       send: function (e, data) {
          $("#upload-file-progress").show();
          switch_disable_text(true);
       },

       always: function (e, data) {
          $("#upload-file-progress").hide();//val(null).hide();
          switch_disable_text(false);
       }
   
   });
   
});

function switch_disable_text(disable){
  $submit = $('.send-file');
  $dis_txt = $submit.val();
  $submit.val($submit.data('disable-with')).data('disable-with', $dis_txt).prop('disabled', disable);
}

function handleFail(respondError) {
   for (var key in respondError){
       $("#results").prepend('<span class="label label-important">'+respondError[key]+'</span>');
   }
}

function resetFields () {
   $('#ajax-upload-form')[0].reset();
   $(".file-name").text("");
}
