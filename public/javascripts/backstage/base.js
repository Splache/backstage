var BACKSTAGE = {};

BACKSTAGE.Base = function(){
  var init_form;
  
  this.initialize = function() {
    init_form();
    
    BACKSTAGE.Task.initialize();
  };
  
  init_form = function(){
    $("input.focus").focus();
  };
};
BACKSTAGE.Base = new BACKSTAGE.Base();

BACKSTAGE.Task = function(){
  var init_form, set_state_fields;
  
  this.initialize = function(){
    if($('#form-task').length > 0){ init_form(); }
  };
  
  init_form = function(){
    date_fields = ['due_on', 'started_on', 'ended_on']
    
    $.each(date_fields, function(){
      name = this;
      $('#show_' + this).click(function(){ set_state_fields(this.id.replace('show_', '')) });
      set_state_fields(this);
    });
  };
  
  set_state_fields = function(name){
    $('#show_' + name).is(':checked') ? $('#fields_' + name).removeClass('hidden-fields') : $('#fields_' + name).addClass('hidden-fields');
  }
}
BACKSTAGE.Task = new BACKSTAGE.Task();



$(document).ready( function() { BACKSTAGE.Base.initialize(); });
