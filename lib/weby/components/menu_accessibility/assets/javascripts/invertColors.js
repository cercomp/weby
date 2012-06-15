function invertColors() {
//set up color properties to iterate through
var colorProperties = ['color', 'background-color'];
var tags = $('*');
var tags_contrast = tags.not(tags.find(".no_contrast").find("*"));
var icons_black = tags.find($('i[class^="icon"]'));
var icons_white = tags.find(".icon-white");

icons_black.addClass('icon-white');
icons_white.removeClass('icon-white');

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
}
