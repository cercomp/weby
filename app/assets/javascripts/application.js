//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require select2
//= require clipboard
//= require moment
//= require moment/pt-br.js
//= require moment/es.js
//= require dropmic.min
//= require sticky.min.js
//= require tables
// // floatThead was commented because there is a bug when used in tabs
// // require floatthead/jquery.floatThead._.js
// // require floatthead/jquery.floatThead
//= require select2/select2_locale_pt-BR.js
//= require_self

var WEBY = {};

var assetPath = function(file_path) {
  var storage = $('meta[name=storage]');
  if (storage.length > 0) {
    return "//"+storage.attr('content')+"/assets/"+file_path;
  }
  return "/assets/"+file_path;
}

// Mostrar mensagem para erros, no retorno do ajax
FlashMsg = {
  notify: function(status) {
    //TODO some ajax requisitions return 500, even if they are ok
    //if([403,500].indexOf(status)>-1){
    if(status == 403){
      //flash = $(document.createElement('div'));
      //$('#content').prepend(flash);
      //flash.addClass('alert alert-error notify');
      //flash.text(status==403 ?'Acesso Negado':status==500 ?'Erro no servidor':'');
      //flash.append('<a class="close" data-dismiss="alert" href="#">×</a>');
      //flash.append(status==403 ?'Acesso Negado':'');
      $('<div class="modal fade" tabindex="-1" role="dialog">'+
        '<div class="modal-dialog" role="document">'+
        '<div class="modal-content">'+
        '<div class="modal-header"><h4>Acesso Negado</h4></div>'+
        '<div class="modal-body">'+
        '<div class="alert alert-error">Você não possui permissão para esta ação</div></div>'+
        '<div class="modal-footer"><a class="btn btn-primary" data-dismiss="modal">OK</a></div>'+
        '</div></div></div>').modal('show');
    }
  },
  info: function(text) {
    var id = '_' + Math.random().toString(36).substr(2, 9);
    $('body').append('<div class="notify-info" id="'+id+'">'+text+'</div>');
    $('#'+id).css({
      zIndex: toasterPos.zindex,
      right: toasterPos.right,
      bottom: toasterPos.bottom
    }).addClass('visible');
    setTimeout(function(){
      $('#'+id).removeClass('visible');
      setTimeout(function(){
        $('#'+id).remove();
      }, 2000)
    }, 4000);
  },
  error: function(textErrors, append_elem) {
    if (append_elem == undefined) append_elem = '';

    $(`${append_elem} form #error_explanation`).remove();
    $(`${append_elem} form #error_box`).remove();
    $(`${append_elem} form`).prepend('<div class="alert alert-error" id="error_box"></div>');
    if (Array.isArray(textErrors)) {
      $(`${append_elem} form #error_box`).append(`<b>${textErrors.length} Erros impedem que você prossiga</b>`);
      let listMsg = '';
      textErrors.forEach(element => {
        listMsg = listMsg.concat(`<li>${element}</li>`)
      });
      $('#error_box').append(`<ul>${listMsg}</ul>`);
    } else {
      $('#error_box').append(`<b>Um erro impede que você prossiga</b>`);
      $('#error_box').append(`<ul><li>${textErrors}</li></ul>`);
    }
  },
  clear: function() {
    $(`form #error_box`).remove();
  }
}

var toasterPos = {
  bottom: 20,
  right: 25,
  zindex: 66060
}

function addToSelect(selectId, text){
   var new_cat = prompt(text), option = new Option(new_cat);
   if(!new_cat) return;
   $(selectId).append(option);
   $(option).attr('selected', true);
}

function handleToggle(target, json, parentSelector) {
  if (json && json.message) {
    FlashMsg.info(`<img src="${json.icon}"/> ${json.message}`);
    target.find('[type=checkbox]').prop('checked', json.status).val(json.status).prop('title', json.title).prop('alt', json.title);
    target.prop('title', json.title).prop('alt', json.title);
    if (parentSelector && json.status) {
      target.closest(parentSelector).removeClass('deactivated');
    } else {
      target.closest(parentSelector).addClass('deactivated');
    }
  } else {
    FlashMsg.info('Ocorreu um erro, tente novamente');
  }
}

function appendToggleHandle(selector, parentSelector) {
  $(document).on('ajax:success', selector, function(ev, data){
    handleToggle($(ev.target), data, parentSelector);
  }).on('ajax:error', selector, function(ev, data){
    handleToggle($(ev.target), data.responseJSON, parentSelector);
  });
}

function initDropmic() {
  /// open dropdown menu
  $('[data-dropmic=42]').each(function(){
    var $this = $(this);
    if ($this.data('dropmicInstance')) return;

    $this.data('dropmicInstance', new Dropmic(this));
  });
}

////// Toast UI Editor - for markdown

function switchEditor(is_markdown) {
  if (is_markdown) {
    $('.tinymce-editor').hide()
    $('.tui-editor').data('enabled', true).show()
  } else {
    $('.tinymce-editor').show()
    $('.tui-editor').data('enabled', false).hide()
  }
}

function submitEditorValues(ev) {
  $(this).find('.md-editor').each(function(){
    let $this = $(this);
    if ($this.closest('.tui-editor').data('enabled')) {
      let editor = $this.data('editor')
      let input = $this.closest('.tab-pane').find('textarea[data-field='+$this.data('field')+']')
      input.val(editor.getMarkdown())
    }
  });
}

function createImgButton(editorEl) {
  const button = document.createElement('button');
  button.className = 'image toastui-editor-toolbar-icons';
  button.style.margin = 0;
  button.addEventListener('click', (ev) => {
    if(WEBY.getRepositoryDialog){
      WEBY.getRepositoryDialog().open({
        file_types: ["image"],
        multiple: false,
        include_others: true,
        onsubmit: function(items) {
          editorEl.data('editor').insertText("!["+items[0].description+"]("+items[0].medium_path+")")
        }
      });
    }
    ev.preventDefault();
  });
  return button;
}

function initMarkdownEditor(elem) {
  const Editor = toastui.Editor;
  $this = $(elem);
  let editor = new Editor({
    el: elem,
    language: 'pt-BR',
    height: ($(elem).is('.simple') ? '200px' : '350px'),
    initialEditType: 'markdown',
    initialValue: $this.data('value'),
    hideModeSwitch: true,
    previewStyle: 'vertical',
    toolbarItems: [
      ['heading', 'bold', 'italic', 'strike'],
      ['hr', 'quote'],
      ['ul', 'ol', 'task', 'indent', 'outdent'],
      ['table', 'link'],
      ['code', {
        el: createImgButton($this),
        tooltip: 'Inserir imagem'
      },  'codeblock']
    ]
  });
  $this.data('editor', editor);
}

$(document).on('ajaxComplete', initDropmic);

$(document).ready(function() {

  // Ajax indicator
  $('body').append($('<div class="panel panel-default hide" id="loading-modal" style="z-index: '+toasterPos.zindex+'; position: fixed; bottom: '+toasterPos.bottom+'px; right: '+toasterPos.right+'px;"><div class="panel-body"><img src="'+assetPath('loading-bar.gif')+'"/></div></div>'));
  $(document).ajaxSend(function(ev, jqXHR, options){
    if(options.files){
      return;
    }
    var panel = $('#loading-modal');
    //panel.css("top", ($(window).height() / 2) - (53 / 2));
    //panel.css("left", ($(window).width() / 2) - (192 / 2));
    //Do not use the .modal() function. If there is another modal it generates anomalous behaviour
    panel.removeClass('hide');
  }).ajaxComplete(function(evt,xhr){
    $('#loading-modal').addClass('hide');
    FlashMsg.notify(xhr.status);
  });

  ///sticky
  var sticky = new Sticky('.sticky');

  //Fixes the admin menu on the screen
  //responsive
  // var menuadmin = $('#menu-admin');
  // if(menuadmin.length>0){
  //    $(window).scroll(function(){
  //        if($(window).width() >= 768){
  //            maincontainer = $('#main');
  //            windowtop = $(this).scrollTop() + 10;
  //            if(windowtop >= maincontainer.position().top){
  //                if(menuadmin.css('position')!='fixed')
  //                    menuadmin.css({'position':'fixed',
  //                    'top':(10+parseInt(maincontainer.css("padding-top")))+'px',
  //                    'width':menuadmin.width()+'px'});
  //            }else{
  //                if(menuadmin.css('position')=='fixed')
  //                    menuadmin.css({'position':'','top':'', 'width':''});
  //            }
  //        }
  //     });
  // }
  // $(window).resize(function(){
  //     menuadmin.css({'position':'','top':'', 'width':''});
  //     $(window).scroll();
  // });

  ///copy to clipboard
  $('.clip-btn').each(function(){
    var btn = $(this);
    var clip = new Clipboard(btn[0]);
    clip.on('success', function(e){
      btn.text(btn.data('hint')).addClass("disabled");
    } );
  });

  /// init dropmic
  initDropmic();

  ///// select bulk
  var checkBulk = function(){
    var checked = $('[name=select_item]:checked');
    if (checked.length > 0) {
      $('.bulk-actions').animate({height: 62}, 200);
    } else {
      $('.bulk-actions').animate({height: 0}, 200);
    }
    // delete many btn
    var destroyMany = $('.destroy-many');
    if (destroyMany.length) {
      var newhref = destroyMany.attr('href').split('?')[0] + `?ids=${checked.map(function(){ return $(this).val(); }).get().join(',')}`;
      destroyMany.attr('href', newhref);
    }
  };

  $('[name=select_all]').change(function(){
    if ($(this).is(':checked')) {
      $('[name=select_item]').prop('checked', true)
    } else {
      $('[name=select_item]').prop('checked', false)
    }
    checkBulk();
  });

  $('[name=select_item]').change(checkBulk);
  checkBulk();

  $(document).on('change', '.pagination select', function(){
      //window.location = $(this).find('option:selected').data('url');
      $.getScript($(this).find('option:selected').data('url'));
  });

  ////// Check slug
  $('[data-check-slug]').each(function(){
    let $this = $(this);
    $this.change(function(){
      $.get($this.data('url'), {slug: $this.val(), id: $this.data('id')}, function(resp){
        let fg = $this.closest('.form-group');
        let cf = fg.find('.form-control-feedback');
        let hb = fg.find('.help-block');
        if (!cf.length) cf = $('<span class="glyphicon form-control-feedback" aria-hidden="true"></span>').appendTo(fg);
        if (!hb.length) hb = $('<span class="help-block"></span>').appendTo(fg);
        if (resp.empty) {
          cf.remove();
          hb.remove();
          fg.removeClass('has-success').removeClass('has-error').removeClass('has-feedback')
        } else {
          hb.text(resp.message);
          if (resp.taken) {
            cf.removeClass('glyphicon-ok').addClass('glyphicon-remove');
            fg.addClass('has-feedback').removeClass('has-success').addClass('has-error')
          } else {
            cf.removeClass('glyphicon-remove').addClass('glyphicon-ok');
            fg.addClass('has-feedback').removeClass('has-error').addClass('has-success')
          }
        }
      });
    });

    $this.on('input', function(e){
      let t = e.target;
      t.value = t.value.replace(' ', '-');
      let badValues = /[^a-z-]/g;
      if ($this.data('include-num')) badValues = /[^a-z0-9-]/g;
      t.value = t.value.replace(badValues, '');
    });
  });

  //// toggle fields based on checkboxes
  $(document).on('change', '.toggle-fields', function(){
    let $this = $(this);
    let $fields = $($this.data('fields'));
    if ($this.is(':checked')) {
      $fields.slideDown(300);
    } else {
      $fields.slideUp(300);
    }
  });

  var hash = location.hash
    , hashPieces = ((hash.split('?')[0] == "") ? 0 : hash.split('?'))
    , activeTab = $('[href="' + hashPieces[0] + '"]');
  activeTab && activeTab.tab('show');
});
