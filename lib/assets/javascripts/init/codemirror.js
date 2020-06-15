//=require codeMirror/codemirror.min
//=require codeMirror/formatting.min
//=require codeMirror/javascript.min
//=require codeMirror/css.min
//=require codeMirror/fullscreen.min
//=require codeMirror/xml.min
//=require codeMirror/htmlmixed.min
//=require codeMirror/javascript-hint.min
//=require codeMirror/show-hint.min
//=require codeMirror/dialog.min
//=require codeMirror/search.min
//=require codeMirror/searchcursor.min

$(document).ready(function(){

  $('.code-area').each(function(){
    var txtarea = $(this);
    var mode = 'htmlmixed';
    if (txtarea.data('code-mode')) {
      mode = txtarea.data('code-mode');
    }
    var readOnly = false;
    if (txtarea.data('code-readonly')) {
      readOnly = 'nocursor';
    }

    var editor = CodeMirror.fromTextArea(this, {
      mode: mode,
      lineNumbers: true,
      tabSize: 2,
      readOnly: readOnly,
      extraKeys: {
        "Ctrl-Space": "autocomplete",
        "F11": function(cm) {
          cm.setOption("fullScreen", !cm.getOption("fullScreen"));
        },
        "Esc": function(cm) {
          if (cm.getOption("fullScreen")) cm.setOption("fullScreen", false);
        }
      }
    });

    var curr_line = -1;
    editor.on("cursorActivity", function(instance) {
      if (curr_line > -1) {
        instance.removeLineClass(curr_line, 'background', "activeline");
      }
      curr_line = instance.getCursor().line;
      instance.addLineClass(curr_line, 'background', "activeline");
    });

    txtarea.data('codemirrorInstance', editor);
  });

  ////// editor helper functions
  var findEditor = function(el) {
    var tab = $(el).closest('.tab-pane');
    var editor = (tab.length > 0) ? tab.find('.code-area') : $('.code-area');
    return editor.data('codemirrorInstance');
  };

  var getSelectedRange = function(ed) {
    return { from: ed.getCursor(true), to: ed.getCursor(false) };
  };

  ///// editor tool command
  $('.js-code-format').click(function(){
    var editor = findEditor(this);
    if (editor) {
      var range = getSelectedRange(editor);
      editor.autoFormatRange(range.from, range.to);
    }
    return false;
  });

  $('.js-code-comment').click(function(){
    var editor = findEditor(this);
    if (editor) {
      var range = getSelectedRange(editor);
      editor.commentRange(true, range.from, range.to);
    }
    return false;
  });

  $('.js-code-uncomment').click(function(){
    var editor = findEditor(this);
    if (editor) {
      var range = getSelectedRange(editor);
      editor.commentRange(false, range.from, range.to);
    }
    return false;
  });

  $('.js-code-add-image').click(function(){
    var editor = findEditor(this);
    if (editor) {
      WEBY.getRepositoryDialog().open({
        file_types: ["image"],
        multiple: false,
        onsubmit: function(value) {
          var path = value[0].original_path.replace(/\?\d+$/, '');
          editor.replaceRange(path, editor.getCursor());
        }
      });
    }
    return false;
  });

  //// code mirror inside tabs
  $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
    var panel = $($(e.target).attr('href'));
    var cm = panel.find('.code-area').data('codemirrorInstance');
    if (cm) {
      cm.refresh();
    }
  });
});
