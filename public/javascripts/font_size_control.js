$(document).ready(function(){
    $.cookie("font_size_original", $('html').css('font-size'), { path: '/' })
		
		if($.cookie("font_size") != null)
		$('html').css('font-size', $.cookie("font_size")+ 'px')
})

function font_size_up(){
    var font = $('html').css('font-size'),
    size = parseInt(font.substr(0, font.length - 2)) + 2
    $('html').css('font-size', size.toString() + 'px') 
	
		//atualiza valor de font_size no cookie
		$.cookie("font_size", size, { path: '/' })
}

function font_size_down(){
 	var font = $('html').css('font-size'),
    size = parseInt(font.substr(0, font.length - 2)) - 2
    $('html').css('font-size', size.toString() + 'px') 

		//atualiza valor de font_size no cookie
		$.cookie("font_size", size, { path: '/' })

}


function font_size_original(){ 
 		
		$('html').css('font-size', $.cookie("font_size_original"))
        $.cookie("font_size", null, {path: '/'})
 
 }
