BACKSTAGE.Tasks = function(){
  var get_task_id_from_item, init_form, init_list, set_state_fields, update_priority,
      is_sortable = true;
  
  this.initialize = function(){
    if($j('#form-task').length > 0){ init_form(); }
    if($j('#list-tasks').length > 0){ init_list(); }
  };
  
  get_task_id_from_item = function(item){
    return item.attr('id').replace('task-', '');
  };
  
  init_form = function(){
    var date_fields = ['due_on', 'started_on', 'ended_on'];
    
    $.each(date_fields, function(){
      $j('#show_' + this).click(function(){ set_state_fields(this.id.replace('show_', '')); });
      set_state_fields(this);
    });
  };
  
  init_list = function(){
    if($j('#list-tasks').hasClass('archived')){ 
      is_sortable = false; 
    }else{
      $j('#list-tasks').sortable({ update: function(event, ui) { update_priority(ui.item); }});
    }
    
    $j('#list-tasks a.open-comments').click(function(){ open_comments($j(this).closest('div.task')); });
    $j('#list-tasks a.close-comments').click(function(){ close_comments($j(this).closest('div.wrapper-comments')); });
  };
  
  open_comments = function(task){
    if(is_sortable){ $j('#list-tasks').sortable("disable"); }
    task.find('div.wrapper-comments').fadeIn();
  };
  
  close_comments = function(box){
    box.fadeOut();
    if(is_sortable){ $j('#list-tasks').sortable("enable"); }
  };
  
  set_state_fields = function(name){
    if($j('#show_' + name).is(':checked')){
      $j('#fields_' + name).removeClass('hidden-fields');
    }else{
     $j('#fields_' + name).addClass('hidden-fields'); 
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
BACKSTAGE.Tasks = new BACKSTAGE.Tasks();
