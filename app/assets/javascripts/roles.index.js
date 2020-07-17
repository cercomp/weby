$(document).ready(function(){
  var switch_status = function(link) {
    var text = link.html();
    link.html(link.data('alt-text')).data('alt-text', text);
    if (link.hasClass('selected')) {
      link.removeClass('selected')
      return false;
    } else {
      link.addClass('selected')
      return true;
    }
  };

  $('.check-all-role').click(function(){
    var $this = $(this);
    $('[data-role='+$this.data('role')+']').attr('checked', switch_status($this));
    return false;
  });

  $('.check-group-rights').click(function(){
    var $this = $(this);
    $('[data-group='+$this.data('group')+']').attr('checked', switch_status($this));
    return false;
  });

  $('.check-group-role').click(function(){
    var $this = $(this);
    $('[data-group='+$this.data('group')+'][data-role='+$this.data('role')+']').attr('checked', switch_status($this));
    return false;
  });

  $('.check-right-roles').click(function(){
    var $this = $(this);
    $('[data-group='+$this.data('group')+'][data-right='+$this.data('right')+']').attr('checked', switch_status($this));
    return false;
  });
});
