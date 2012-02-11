BACKSTAGE.Tasks = function(){
  var get_task_id_from_item, init_form, init_list, init_task_options, init_task_show, open_comments, set_state_fields, task_path, toggle_description, toggle_task_item, update_priority,
      is_sortable = true,
      self = this;

  this.initialize = function(){
    if($j('#form-task').length > 0){ init_form(); }
    if($j('#list-tasks').length > 0){ init_list(); }
    if($j("#task-options").length > 0){ init_task_options(); }
    if($j("#task-show").length > 0){ init_task_show(); }
  };

  this.disable_list_sort = function(){ if(is_sortable){ $j('#list-tasks').sortable("disable"); }};

  this.enable_list_sort = function(){ if(is_sortable){ $j('#list-tasks').sortable("enable"); }};

  this.loading = function(){
    $j('#task-options h5:first-child').append('<span class="loading-bar">&nbsp;</span>');
  };

  this.reload_task_list = function(data){
    $j('#task-options h5 span.loading-bar').remove();
    $j('#tasks').html(data);
    init_list();
  };

  get_task_id_from_item = function(item){
    return item.attr('id').replace('task-', '');
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
      $j("#task-options div.sort").hide();
    }else{
      if($j("#task-options div.sort input#option-sort").val() === 'priority'){
        $j('#list-tasks').sortable({ update: function(event, ui) { update_priority(ui.item); }});
      }
      $j("#task-options div.sort").show();
    }

    $j('#list-tasks a.open-comments').click(function(){ open_comments($j(this).closest('div.task')); });
    $j('#list-tasks div.description').click(function(){ toggle_description($j(this)); });
    $j('#list-tasks h3 span.ico').click(function(){ toggle_task_item($j(this).closest('div.task')); });
  };

  init_task_options = function(){
    var filters = new BACKSTAGE.Form.Candy();
    filters.initialize($j("#task-filters"), 'option');
    filters.set_ajax('change', $j("#task-filters input[name=ajax_path]").val(), BACKSTAGE.Tasks.reload_task_list, BACKSTAGE.Tasks.loading);
  };

  init_task_show = function(){
    var form_show = new BACKSTAGE.Form.Candy();
    form_show.initialize($j("#task-show"), 'option');
    form_show.set_ajax('change', $j("#task-filters input[name=ajax_path]").val(), BACKSTAGE.Tasks.reload_task_list, BACKSTAGE.Tasks.loading);
  };

  open_comments = function(task){
    self.disable_list_sort();
    BACKSTAGE.Comments.initialize(task);
  };

  set_state_fields = function(name){
    if($j('#show_' + name).is(':checked')){
      $j('#fields_' + name).removeClass('hidden-fields');
    }else{
     $j('#fields_' + name).addClass('hidden-fields');
    }
  };

  task_path = function(task){ return task.find('input[name=ajax_path]').val(); };

  toggle_description = function(description){
    var wrapper = description.closest('div.wrapper-description');

    if(description.outerHeight() <= 40){ return ''; }

    if(wrapper.css('max-height') === '40px'){
      wrapper.animate({ 'max-height': description.outerHeight() + 'px'}, 500);
    }else{
      wrapper.animate({ 'max-height': '40px'}, 500);
    }
  };

  toggle_task_item = function(task){
    if(task.hasClass('preview')){
      task.removeClass('preview');
      task.find('h3 span.ico').removeClass('ico-block-closed').addClass('ico-block-opened');
    }else{
      task.addClass('preview');
      task.find('h3 span.ico').removeClass('ico-block-opened').addClass('ico-block-closed');
    }
  };

  update_priority = function(task){
    var previous = task.prev(),
        params = '_method=put';

    if(previous.length > 0){
      params += '&insert_after=' + get_task_id_from_item(previous);
    }else{
      params += '&insert_first=1';
    }

    $j.post(task_path(task), params, function(){}, 'json');
  };
};
BACKSTAGE.Tasks = new BACKSTAGE.Tasks();
