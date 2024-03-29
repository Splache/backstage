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
  
  def show_task_step(task)
    return task_line_detail(task.step, '', task.step_f, :class => 'step')
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
    
    return content.join.html_safe
  end
  
  def task_line_detail(icon, label, content, options={})
    options.reverse_merge!(:class => '')
    
    line = ['<div class="line ' + options[:class] + '">']
    line << icon(icon)
    line << '<div class="content">'
    line << "<label>#{label} :</label>" if not label.empty?
    line << content
    line << '</div></div>'
    
    return line.join.html_safe
  end
  
  def title_tasks_section(options)
    
    text = 'Liste des tâches'
    if current_user.id = options[:assigned_to]
      text = 'Mes tâches'
    else
      Task.get_natures.each { |t| text = t[0] if t[1] == options[:nature] }
    end
    
    sub = options[:archive] ? content_tag(:span, 'Archive', :class => 'path') : ''
    
    return content_tag(:h2, sub + text)
  end
end