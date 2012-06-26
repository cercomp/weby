//set up color properties to iterate through
var colorProperties = ['color', 'background-color'];

var tags = $('*');
var tags_contrast = tags.not(tags.find(".no_contrast").find("*"));


var color_original = new Array();
var background_original = new Array();

tags_contrast.ready(function(){
   tags_contrast.each(function(){ color_original.push($(this).css('color'))})
   tags_contrast.each(function(){ background_original.push($(this).css('background-color'))})
})



function Contrast() {

   var icons_white = tags_contrast.find(".icon-white");
   var icons_black = tags_contrast.find($('i[class^="icon"]'));

   if (icons_white.size() == 0) {
      //aplicando contraste

      icons_black.addClass('icon-white');

      //iterate through every element
      tags_contrast.each(function() {
         var color = null;

         for (var prop in colorProperties) {
            prop = colorProperties[prop];

            //if we can't find this property or it's null, continue
            if (!$(this).css(prop)) continue; 

            //create RGBColor object
            color = new RGBColor($(this).css(prop));

            if (color.ok) { 
               //good to go, let's build up this RGB baby!
               //subtract each color component from 255
               $(this).css(prop, 'rgb(' + (255 - color.r) + ', ' + (255 - color.g) + ', ' + (255 - color.b) + ')');
                  }
                  color = null; //some cleanup
                  }
                  });
               }else{
                  //desaplicando contraste
                  icons_white.removeClass('icon-white');

                  var i=0; 
                  tags_contrast.each(function(){
                     $(this).css('color',color_original[i]);
                     $(this).css('background-color',background_original[i++]);
                  })
               };

}


