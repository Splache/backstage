module TaskHelper
  def show_task_due_on(task)
    return '' if not task.due_on
    
    time_left = task.due_on - (task.archived? ? task.ended_on : Date.today)
    
    if time_left >= 0
      content = "#{time_left} jours"
      
      if task.archived?
        icon = 'target-on'
        label = 'En avance de'
      else
        icon = 'target'
        label = 'À remettre'
      
        case time_left
          when 0 then content = 'Aujourd\'hui'
          when 1 then content = 'Demain'
          else label << ' dans'
        end
      end
    else
      icon = task.archived? ? 'target-out' : 'late'
      label = 'En retard de'
      content = "#{time_left * -1} jours"
    end
    
    return task_line_detail(icon, label, content)
  end
  
  def show_task_estimation(task)
    return task_line_detail('time', 'Temps estimé', "#{task.hours_estimated} heures") if not task.archived? and task.hours_estimated.to_i > 0
  end
  
  def show_task_state(task)
    if task.archived?
      return task_line_detail('archived', '', 'Archivé', :class => 'state')
    elsif task.started_on
      return task_line_detail('started', '', 'En cours', :class => 'state')
    else
      return task_line_detail('stopped', '', 'Non démarré', :class => 'state')
    end
  end
  
  def show_task_calendar(task)
    content = []
    
    if task.archived?
      label = 'Terminé le'
      content << task_line_detail('calendar', label, task.ended_on.strftime("%d-%m-%Y"))
    elsif task.started_on
      label = (task.started_on <= Date.today) ? 'Débuté le' : 'À débuter le'
      content << task_line_detail('calendar', label, task.started_on.strftime("%d-%m-%Y"))
    end
    
    return content.join
  end
  
  def task_option_radio_tag(id, items, options)
    content = []
    
    content << '<div class="radio-group group-' + id + '" >'
    items.each do |item|
      
    end
    content << '</div>'
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
  
  def title_tasks_section(options)
    
    text = 'Liste des tâches'
    if current_user.id = options[:assigned_to]
      text = 'Mes tâches'
    else
      Task.get_natures.each { |t| text = t[0] if t[1] == options[:nature] }
    end
    
    sub = options[:archive] ? '<span class="path">Archive</span>' + options[:archive].to_s : ''
    
    return '<h2>' + sub + text + '</h2>'
  end
end