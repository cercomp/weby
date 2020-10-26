function translateOnInit() {
  const atr_trigger = $('[name=auto_translate_trigger]');
  if (atr_trigger.length > 0){
    let locale = atr_trigger.val();
    setTimeout(function () {
      autoTranslate(locale);
    }, 100);
  }
}

function googleTranslateElementInit2() {
  const atr_trigger = $('[name=auto_translate_trigger]');
  if (atr_trigger.length > 0 && atr_trigger.val() == 'pt-BR') return;

  let t = new google.translate.TranslateElement({pageLanguage: 'pt', autoDisplay: false}, 'google_translate_element2');
  //console.log(t);
}

function autoTranslate(lang, tries) {
  if (lang == '' || tries > 5) return;
  if (lang == 'pt-BR') lang = 'pt';
  if (!tries) tries = 0;
  let tselect = $('#google_translate_element2 .goog-te-combo');
  let option = tselect.find('option[value='+lang+']');

  if (tselect.length == 0 || option.length == 0) {
    setTimeout(function () {
      autoTranslate(lang, tries + 1);
    }, 300);
  } else {
    tselect.val(lang);
    if (document.createEvent) {
			var c = document.createEvent("HTMLEvents");
			c.initEvent('change', true, true);
			tselect[0].dispatchEvent(c)
		} else {
			var c = document.createEventObject();
			tselect[0].fireEvent('onchange', c)
		}
  }
}

$(document).ready(translateOnInit);

//$(document).on('click', '.locale-link', function(){
  // var $this = $(this);
  // var locale = $this.data('locale')
  // if (locale == 'pt-BR') locale = 'pt'
  // autoTranslate(locale);
  // //$.get($this.attr('href'));
  // setTimeout(function(){
  //   window.location = $this.attr('href');
  // }, 150);
  // return false;
//});
