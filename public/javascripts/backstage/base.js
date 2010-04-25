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
  var get_task_id_from_item, init_form, init_list, set_state_fields, update_priority;
  
  this.initialize = function(){
    if($('#form-task').length > 0){ init_form(); }
    if($('#list-tasks').length > 0){ init_list(); }
  };
  
  get_task_id_from_item = function(item){
    return item.attr('id').replace('task-', '');
  };
  
  init_form = function(){
    var date_fields = ['due_on', 'started_on', 'ended_on'];
    
    $.each(date_fields, function(){
      $('#show_' + this).click(function(){ set_state_fields(this.id.replace('show_', '')); });
      set_state_fields(this);
    });
  };
  
  init_list = function(){
    if(!$('#list-tasks').hasClass('archived')){
      $('#list-tasks').sortable({
        update: function(event, ui) {
          update_priority(ui.item); 
        }
      });
    }
  };
  
  set_state_fields = function(name){
    if($('#show_' + name).is(':checked')){
      $('#fields_' + name).removeClass('hidden-fields');
    }else{
     $('#fields_' + name).addClass('hidden-fields'); 
    }
  };
  
  update_priority = function(task){
    var previous = task.prev(),
        params = { _method:'PUT' },
        task_id = get_task_id_from_item(task);
    
    
    if(previous.length > 0){
      params.insert_after = get_task_id_from_item(previous);
    }else{
      params.insert_first = 1;
    }
    
    $.ajax({ type: "POST", url: '/tasks/' + task_id, data: params, dataType: 'json' });  
  };
};
BACKSTAGE.Task = new BACKSTAGE.Task();



$(document).ready( function() { BACKSTAGE.Base.initialize(); });
