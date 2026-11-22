//= require jquery
//= require jquery_ujs
//= require bootstrap

$(document).ready(function() {
  // Captcha refresh loading feedback & field focus
  $(document).on('click', '.btn-refresh-captcha', function() {
    var $btn = $(this);
    var $icon = $btn.find('.fa-refresh');
    var $wrap = $btn.closest('.weby-captcha-box');
    var $input = $wrap.find('.weby-captcha-input');

    $icon.addClass('fa-spin');
    if ($input.length) {
      $input.val('').focus();
    }
    setTimeout(function() {
      $icon.removeClass('fa-spin');
    }, 1200);
  });

  // Password visibility toggle
  $(document).on('click', '.toggle-password-btn', function(e) {
    e.preventDefault();
    var $btn = $(this);
    var targetSelector = $btn.data('target');
    var $input = targetSelector ? $(targetSelector) : $btn.closest('.password-toggle-wrapper').find('input');
    var $icon = $btn.find('i');

    if ($input.length) {
      if ($input.attr('type') === 'password') {
        $input.attr('type', 'text');
        $icon.removeClass('fa-eye').addClass('fa-eye-slash');
      } else {
        $input.attr('type', 'password');
        $icon.removeClass('fa-eye-slash').addClass('fa-eye');
      }
    }
  });

  // Auto-uppercase for captcha input
  $(document).on('input', '.weby-captcha-input', function() {
    var start = this.selectionStart;
    var end = this.selectionEnd;
    this.value = this.value.toUpperCase();
    this.setSelectionRange(start, end);
  });
});
