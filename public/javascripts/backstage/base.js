var BACKSTAGE = {};

BACKSTAGE.Base = function(){
  var init_form;
  
  this.initialize = function() {
    init_form();
    
    BACKSTAGE.Tasks.initialize();
  };
  
  init_form = function(){
    var combo, tap_list;
    
    $j("input.focus").focus();
    
    $j("ul.tap-list").each(function(){
      tap_list = new BACKSTAGE.Form.TapList();
      tap_list.initialize($j(this));
    });
    
    $j("select.custom-combo").each(function(){
      combo = new BACKSTAGE.Form.CustomCombo();
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

BACKSTAGE.is_d = function(content){ return (typeof(content) !== 'undefined'); };

BACKSTAGE.merge_hash = function(options, default_options){ 
  if(!BACKSTAGE.is_d(options)){ return default_options; }
  
  jQuery.each(default_options, function(key, value){
    if(!BACKSTAGE.is_d(options[key])){ options[key] = value; }
  });
  
  return options;
};



$j(document).ready( function() { BACKSTAGE.Base.initialize(); });
