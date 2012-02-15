// Adcionando metodo em String para trabalhar com templates
// usar chaves em strings para indicar um campo
String.prototype.supplant = function (o) { 
   return this.replace(/{([^{}]*)}/g, function (a, b) {  
      var r = o[b];
      return typeof r === 'string' ?  r : String(r); 
   }); 
}; 

// Adcionando metodo em String para escapar caracteres 
// especiais para os seletores do JQuery
String.prototype.escapeForJQuerySelector = function () {
   try {
      return this.
         replace(/([#$%&'()*+,./:;<=>?@\[\]\\^`{|}~])/g, '\\\\$1');
   } catch (error) {
      console.warn(error.message);
      return this
   }
}
