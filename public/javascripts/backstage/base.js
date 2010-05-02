var BACKSTAGE = {};

BACKSTAGE.Base = function(){
  var init_form;
  
  this.initialize = function() {
    init_form();
    
    BACKSTAGE.Tasks.initialize();
  };
  
  init_form = function(){
    var combo;
    
    $j("input.focus").focus();
    $j("select.custom-combo").each(function(){
      combo = new BACKSTAGE.Form.CustomCombo()
      combo.initialize($j(this));
    });
  };
};
BACKSTAGE.Base = new BACKSTAGE.Base();

BACKSTAGE.Form = function(){};
BACKSTAGE.Form = new BACKSTAGE.Form();


BACKSTAGE.StringBuilder = function(){
  var content = [],
      position = 0;
  
  this.add = function(value) { content[position++] = value; };
  this.get = function() { return content.join(''); };
};



$j(document).ready( function() { BACKSTAGE.Base.initialize(); });
