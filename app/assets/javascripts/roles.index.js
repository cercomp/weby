$(document).ready(function(){
  // var switch_status = function(link) {
  //   var text = link.html();
  //   link.html(link.data('alt-text')).data('alt-text', text);
  //   if (link.hasClass('selected')) {
  //     link.removeClass('selected')
  //     return false;
  //   } else {
  //     link.addClass('selected')
  //     return true;
  //   }
  // };

  $('.right-checkbox [type=checkbox]').change(function(){
    var $this = $(this);
    if (!$this.data('original')) {
      $this.data('original', $this.is(':checked') ? 'off' : 'on')
    }
    //
    var origState = $this.data('original') == 'on';
    if ($this.is(':checked') == origState) {
      $this.removeClass('dirty')
    } else {
      $this.addClass('dirty')
    }
  });

  var revertToOriginal = function(selector) {
    $(selector).each(function(){
      var origState = $(this).data('original') == 'on';
      $(this).removeClass('dirty').prop('checked', origState);
    });
    return false;
  }

  $('.reset-all').click(function(){
    return revertToOriginal('.dirty[type=checkbox]');
  });
  $('.reset-role').click(function(){
    return revertToOriginal('.dirty[type=checkbox][data-role='+$(this).data('role')+']');
  });
  $('.reset-group').click(function(){
    return revertToOriginal('.dirty[type=checkbox][data-group='+$(this).data('group')+']');
  });
  $('.reset-group-role').click(function(){
    return revertToOriginal('.dirty[type=checkbox][data-group='+$(this).data('group')+'][data-role='+$(this).data('role')+']');
  });

  var setChecked = function(selector, status) {
    $(selector).prop('checked', status);
    return false;
  }

  $('.check-all-role').click(function(){
    return setChecked('[data-role='+$(this).data('role')+']', $(this).data('chkd'));
  });

  $('.check-group-rights').click(function(){
    return setChecked('[data-group='+$(this).data('group')+']', $(this).data('chkd'));
  });

  $('.check-group-role').click(function(){
    return setChecked('[data-group='+$(this).data('group')+'][data-role='+$(this).data('role')+']', $(this).data('chkd'));
  });

  $('.check-right-roles').click(function(){
    return setChecked('[data-group='+$(this).data('group')+'][data-right='+$(this).data('right')+']', $(this).data('chkd'));
  });
});
