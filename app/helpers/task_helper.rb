module TaskHelper
  def show_task_due_on(task)
    return '' if not task.due_on
    
    time_left = task.due_on - Date.today
    
    if time_left >= 0
      icon = 'target'
      label = 'À remettre'
      
      case time_left
        when 0 then content = 'Aujourd\'hui'
        when 1 then content = 'Demain'
        else
          label << ' dans'
          content = "#{time_left} jours"
      end
    else
      icon = 'late'
      label = 'En retard de'
      content = "#{time_left * -1} jours"
    end
    
    return task_line_detail(icon, label, content)
  end
  
  def show_start_date(task)
    content = []
    
    if task.started_on
      content << task_line_detail('started', '', 'En cours', :class => 'state')

      label = (task.started_on <= Date.today) ? 'Débuté le' : 'À débuter le'
      content << task_line_detail('calendar', label, task.started_on.strftime("%d-%m-%Y"))
    else
      content << task_line_detail('stopped', '', 'Non démarré', :class => 'state')
    end
    
    return content.join
  end
  
  def task_filter_button_tag(id, name, filters)
    content = []
    selection = filters[id.to_sym]
    
    css_class = ['filter', 'filter-button-small']
    css_class << id
    css_class << 'active' if selection
    
    content << '<div class="' + css_class.join(' ') + '">'
    content << '<label><span class="ico ico-' + id + '">&nbsp;</span>' + name + '</label>'
    content << hidden_field_tag("filter[#{id}]", selection)
    content << '</div>'
    
    return content.join
  end
  
  def task_filter_combo_tag(id, name, values, filters)
    content = []
    selection = filters[id.to_sym]
    
    css_class = ['filter', 'filter-combo']
    css_class << id
    css_class << 'active' if selection
    
    content << '<div class="' + css_class.join(' ') + '">'
    content << '<label><span class="ico ico-' + id + '">&nbsp;</span>' + name + '</label>'
    content << select_tag("filter[#{id}]", options_for_select(values, :selected => selection), :class => 'custom-combo', :id => "filter-#{id}")
    content << '</div>'
    
    return content.join
  end
  
  def task_filter_text_field_tag(id, name, filters)
    content = []
    selection = filters[id.to_sym]
    
    css_class = ['filter', 'filter-input']
    css_class << id
    css_class << 'active' if selection
    
    content << '<div class="' + css_class.join(' ') + '">'
    content << '<label><span class="ico ico-' + id + '">&nbsp;</span>' + name + '</label>'
    content << text_field_tag("filter[#{id}]", selection, :id => "filter-#{id}")
    content << '</div>'
    
    return content.join
  end
  
  def task_line_detail(icon, label, content, options={})
    options.reverse_merge!(:class => '')
    
    line = ['<div class="line ' + options[:class] + '">']
    line << icon(icon)
    line << '<div class="content">'
    line << "<label>#{label} :</label>" if not label.empty?
    line << content
    line << '</div></div>'
    
    return line.join
  end
  
  def title_tasks_section(filters)
    
    text = 'Liste des tâches'
    if current_user.id = filters[:assigned_to]
      text = 'Mes tâches'
    else
      Task.get_natures.each { |t| text = t[0] if t[1] == filters[:nature] }
    end
    
    sub = filters[:archive] ? '<span class="path">Archive</span>' + filters[:archive].to_s : ''
    
    return '<h2>' + sub + text + '</h2>'
  end
end