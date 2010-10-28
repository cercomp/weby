/**
 * Webyge default TinyMCE configuration
 */
tinyMCE.init({
    language: "pt",
    mode : "textareas",
    theme : "advanced",
    plugins : "table",

    theme_advanced_toolbar_location: "top",
    //theme_advanced_buttons1_add_before : ',forecolor,backcolor,|',
    //theme_advanced_buttons2_add_before : ',table,tablecontrols,|',
    theme_advanced_buttons3 : ',forecolor,backcolor,|,table,tablecontrols,|'
    //theme_advanced_buttons3 : ''
});

