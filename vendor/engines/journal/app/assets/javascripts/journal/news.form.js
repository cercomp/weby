//= require init/datetime
//= require init/tinymce

$(document).ready(function(){
  $('.input-category').select2({
    width: 'resolve',
    tokenSeparators: [","],
    multiple: true,
    tags: $('.input-category').data('taglist'),
    createSearchChoice: function(term){
      var eq = false;
      $($('.input-category').select2('val')).each(function(){
        //Case insensitive tagging
        if (this.toUpperCase().replace(/^\s+|\s+$/g,"") == term.toUpperCase().replace(/^\s+|\s+$/g,""))
          eq = true;
      });
      if (eq)
        return false
      else
        return {id: term, text: term.replace(/^\s+|\s+$/g,"")};
    }
  });

  //// Auto-save - check for changes
  var currentValues = {};
  var news_id = null;
  var serialized = '';

  var checkChanges = function(){

    if (serialized == '') {
      serialized = $('form').serialize();
    } else {
      tinyMCE.triggerSave();
      var checkserial = $('form').serialize();
      if (checkserial != serialized) {
        serialized = checkserial;
        $.post($('form').data('drafturl'), serialized, function(data){
          if (data.ok) {
            FlashMsg.info(data.message);
          }
        });
      }
    }

    // var sendChanges = false;
    // tinyMCE.editors.forEach(function(ed) {
    //   var txt = $('#'+ed.id);
    //   var field = txt.data('field');
    //   var panel = txt.closest('.tab-pane');
    //   var locale = panel.data('locale');
    //   news_id = panel.find('.i18n-id').val();

    //   if (!currentValues.hasOwnProperty(locale)) {
    //     currentValues[locale] = {};
    //   }

    //   if (currentValues[locale].hasOwnProperty(field)) {
    //     if (currentValues[locale][field] != ed.getContent()) {
    //       sendChanges = true;
    //       currentValues[locale][field] = ed.getContent();
    //     } else {
    //       //all good, no changes
    //     }
    //   } else {
    //     currentValues[locale][field] = ed.getContent();
    //   }
    // });
    // if (sendChanges) {
    //   $.post($('form').data('drafturl'), {content: currentValues, news_id: news_id}, function(data){
    //     console.log(data);
    //   });
    // }
  };
  ////// init
  checkChanges();
  setInterval(checkChanges, 4000)

  ///
  var applyValue = function(json, path) {
    Object.keys(json).forEach(function(item){
      var attr = json[item];
      if (typeof attr === 'object') {
        applyValue(attr, path+item+'_');
      } else {
        var field = $('#news_'+path+item);
        field.val(json[item]).trigger('change');
        if (field.is('textarea')) {
          tinyMCE.get(field.attr('id')).setContent(json[item]);
        }
      }
    });
  };

  //// Restore or Discard unsaved changes
  $('.restore-draft').click(function(ev){
    var $this = $(this);
    $.post(this.href, function(data){
      applyValue(data, '');
      $this.closest('.alert').remove();
    });

    return false;
  });

  $('.discard-draft').click(function(ev){
    var $this = $(this);
    $.post(this.href, function(data){
      if (data.ok) {
        $this.closest('.alert').remove();
      }
    });
    return false;
  });

});
