BACKSTAGE.Comments = function(){
  var attach_events, base_path, box_title, cancel_edit, destroy, insert_content, insert_box, loading, save, show_edit, update_content,
      comments_box,
      task;
  
  this.initialize = function(p_task){
    task = p_task;
    insert_box();
  };
  
  attach_events = function(){
    $j('#box-comments div.operations a.ico-edit').click(function(){ show_edit($j(this).closest('li.comment')); return false; });
    $j('#box-comments div.operations a.ico-delete').click(function(){ destroy($j(this).closest('li.comment')); return false; });
    $j('#box-comments a.cancel').click(function(){ cancel_edit($j(this).closest('li.comment')); return false; });
    $j('#box-comments form.form-comment').submit(function(){ save($j(this)); return false; });
  };
  
  base_path = function(){ return task.find('input[name=ajax_path]').val() + '/comments'; };
  
  box_title = function(){ return task.find('div.details h3 a').html(); };
  
  cancel_edit = function(comment){
    $j('#box-comments div.form').hide();
    comment.find('div.operations a.ico').show();
    comment.find('div.text').show();
    comment.find('div.form').hide();
  };
  
  destroy = function(comment){
    var form_action = comment.find('form').attr('action') + '.js';
    
    if (confirm('Êtes-vous sûr de vouloir détruire ce commentaire ?')){
      loading();
    
      $j.post(form_action, '_method=delete', function(data){ update_content(); });
    }
  };
  
  insert_content = function(content){
    var nbr_comments;
    
    comments_box.update(box_title(), content);
    
    nbr_comments = $j('#box-comments ul.comments li').length - 1;
    task.find('a.open-comments').html('Commentaires (' + nbr_comments + ')');

    attach_events();
  };
  
  insert_box = function(){    
    comments_box = new BACKSTAGE.Expositor();
    comments_box.initialize('box-comments', {h: 575, w: 800}, { close_callback: BACKSTAGE.Tasks.enable_list_sort });
    
    loading();
    update_content();
  };
  
  loading = function(){ comments_box.update(box_title(), '<div class="loading">Chargement en cours</div>'); };
  
  save = function(form){
    var form_action = form.attr('action') + '.js',
        form_params = form.serialize();
    
    //form.submit();
    
    loading();

    $j.post(form_action, form_params, function(data){ update_content(); });
  };
  
  show_edit = function(comment){
    $j('#box-comments div.form').hide();
    comment.find('div.operations a.ico').hide();
    comment.find('div.text').hide();
    comment.find('div.form').show();
  };
  
  update_content = function(){
    $j.get(base_path(), function(data){ insert_content(data); }, 'html');
  };
};
BACKSTAGE.Comments = new BACKSTAGE.Comments();