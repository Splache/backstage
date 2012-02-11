BACKSTAGE.Form.CustomCombo = function(){
  var apply_skin, attach_events, hide_options, extract_position, morph_field, select_option, show_options,
      field = null,
      options = [],
      selection = 0,
      skin = null,
      skin_options = {icons: false, label: false};

  this.initialize = function(p_field){
    field = p_field;

    morph_field();
    apply_skin();
    attach_events();
  };

  apply_skin = function(){
    var content = new BACKSTAGE.StringBuilder();

    if(field.hasClass('label')){ skin_options.label = true; }
    if(field.hasClass('icons')){ skin_options.icons = true; }

    content.add('<div class="' + field.attr('class') + '">');
    content.add('<div class="selection">' + generate_single_option(options[selection], true)  + '</div>');
    content.add('<ul class="options masked">');
    $j.each(options, function(i){
      content.add('<li class="option' + i);
      if(i === selection){ content.add(' selected'); }
      content.add('">');
      content.add(generate_single_option(options[i], false));
      content.add('</li>');
    });
    content.add('</ul>');
    content.add('</div>');

    field.after(content.get());
    skin = $j(field.parent().find('div.custom-combo'));
  };

  attach_events = function(){
    skin.find('ul li').click(function(){ select_option($j(this)); });
  };

  extract_position = function(class_name){ return class_name.replace('option', ''); };

  generate_single_option = function(option, label){
    var option_html = '';

    if(skin_options.icons){ option_html += '<span class="ico ico-' + option.key + '">&nbsp;</span>'; }

    if(option.value.indexOf('[') == 0){
      option_html += '<span class="special">' + option.value.replace('[', '').replace(']', '') + '</span>';
    }else{
      option_html += option.value;
    }

    if(skin_options.label && label){ option_html += ' : '; }

    return option_html;
  };

  hide_options = function(){
    skin.find('ul').css('visibility','hidden');
    setTimeout(show_options, 500);
  };

  morph_field = function(){
    var new_field = '<input class="' + field.attr('class') + '" id="' + field.attr('id') + '" name="' + field.attr('name') + '" type="hidden" value="' + field.val() + '" />',
        parent_wrapper = $j(field.parent()),
        selected_value = field.val();

    field.find('option').each(function(i){
      if($j(this).val() === selected_value){ selection = i; }
      options[options.length] = { key: $j(this).val(), value: $j(this).html() };
    });

    field.after(new_field);
    field.remove();
    field = parent_wrapper.find('input.custom-combo');
  };

  select_option = function(option){
    var selection_content;

    selection = extract_position(option.attr('class'));

    hide_options();

    if(field.val() !== options[selection].key){
      skin.find('ul li.selected').removeClass('selected');
      skin.find('ul li').each(function(index, item){
        if(index === Number(selection)){
          $j(item).addClass('selected');
          field.val(options[index].key);

          selection_content = $j(item).html();
          if(skin_options.label){ selection_content = selection_content.replace(options[selection].value, options[selection].value + ' : '); }

          skin.find('div.selection').html(selection_content);
        }
      });

      field.trigger('updated');
    }
  };

  show_options = function(){ skin.find('ul').css('visibility', 'visible'); };
};
