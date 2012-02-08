BACKSTAGE.Form.Candy = function(){
  var apply_option, init_holder, toggle_field,
      ajax = {e: null, url: null, callback: null, loading_method: null},
      form_id,
      holders = {root: null, fields: null};
      
      
  this.initialize = function(root, p_form_id){
    form_id = p_form_id;
    
    init_holder(root);
    
    holders.fields.find('label.clickable').click(function(){ toggle_field($j(this).closest('div.' + name)); });
    holders.fields.find('input.custom-combo').bind('updated', function(){ apply_option($j(this).closest('div.option')); });
    holders.fields.find('input[type=text]').keypress(function(event){ 
      if (event.keyCode === 13) { apply_option($j(this).closest('div.option')); }
    });
  };
  
  this.set_ajax = function(e, url, callback, loading_method){
    ajax.e = e;
    ajax.url = url;
    ajax.callback = callback;
    ajax.loading_method = loading_method;
  };
  
  apply_option = function(option){
    var field = option.find('input'),
        field_name = field.attr('name'),
        field_value = field.val(),
        url = '';
        
    if(!option.hasClass('active')){ field_value = '$remove$'; }
    
    url = ajax.url + '?' + field_name + '=' + field_value;

    if(ajax.loading_method !== undefined){ ajax.loading_method(); }
    
    $j.get(url, function(data){ ajax.callback(data); }, 'html');
  };
  
  init_holder = function(root){
    holders.root = root;
    holders.fields = $j(root.find('div.' + form_id));
  };
  
  toggle_field = function(field){
    if(field.hasClass('active')){
      field.removeClass('active');
      field.find('input[type=text]').val('');
    }else{
      field.addClass('active');
    }
  
    apply_option(field);
  };
};