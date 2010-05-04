BACKSTAGE.Tasks = function(){
  var get_task_id_from_item, init_form, init_list, set_state_fields, update_priority,
      is_sortable = true;
  
  this.initialize = function(){
    if($j('#form-task').length > 0){ init_form(); }
    if($j('#list-tasks').length > 0){ init_list(); }
    if($j('#task-filters').length > 0){ init_filters(); }
  };
  
  apply_filter = function(filter){
    var field = filter.find('input[type=hidden]'),
        field_name = field.attr('name');
        field_value = field.val()
        url = '';
        
    if(!filter.hasClass('active')){ field_value = '$remove$'; }
    
    url = '/tasks.js?' + field_name + '=' + field_value;
    
    loading_task_list_data();
    
    $j.get(url, function(data){ reload_task_list(data); }, 'html');
  };
  
  close_comments = function(box){
    box.fadeOut();
    if(is_sortable){ $j('#list-tasks').sortable("enable"); }
  };
  
  get_task_id_from_item = function(item){
    return item.attr('id').replace('task-', '');
  };
  
  init_filters = function(){
    $j('#task-filters div.filter label').click(function(){ toggle_filter($j(this).closest('div.filter')); })
    $j('#task-filters div.filter input.custom-combo').bind('updated', function(){ apply_filter($j(this).closest('div.filter')); });
  };
  
  init_form = function(){
    var date_fields = ['due_on', 'started_on', 'ended_on'];
    
    $j.each(date_fields, function(){
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
    $j('#list-tasks div.description').click(function(){ toggle_description($j(this)); });
  };
  
  loading_task_list_data = function(){
    $j('#tasks h2').append('<span class="loading-bar">&nbsp;</span>');
  };
  
  open_comments = function(task){
    if(is_sortable){ $j('#list-tasks').sortable("disable"); }
    task.find('div.wrapper-comments').fadeIn();
  };
  
  reload_task_list = function(data){
    $j('#tasks').html(data);
    init_list();
  };
  
  set_state_fields = function(name){
    if($j('#show_' + name).is(':checked')){
      $j('#fields_' + name).removeClass('hidden-fields');
    }else{
     $j('#fields_' + name).addClass('hidden-fields'); 
    }
  };
  
  toggle_description = function(description){
    var wrapper = description.closest('div.wrapper-description');
    
    if(description.outerHeight() <= 40){ return ''; }
    
    if(wrapper.css('max-height') == '40px'){
      wrapper.animate({ 'max-height': description.outerHeight() + 'px'}, 500);
    }else{
      wrapper.animate({ 'max-height': '40px'}, 500);
    }
  };
  
  toggle_filter = function(filter){
    if(filter.hasClass('active')){
      filter.removeClass('active');
    }else{
      filter.addClass('active');
    }
    
    apply_filter(filter);
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
    
    alert(params.insert_after);
    
    $j.ajax({ type: "POST", url: '/tasks/' + task_id, data: params, dataType: 'json' });  
  };
};
BACKSTAGE.Tasks = new BACKSTAGE.Tasks();
