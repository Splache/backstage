module TaskHelper
  def show_task_due_on(task)
    content = []
    if task.due_on
      time_left = task.due_on - Date.today
      
      if time_left >= 0
        content << '<div class="line target">'
        if time_left == 0
          content << '<label>À remettre</label>Aujourd\'hui'
        elsif time_left == 1
          content << '<label>À remettre</label>Demain'
        else
          content << "<label>À remettre dans</label>#{time_left} jours"
        end
      else
        content << '<div class="line late"><label>En retard de</label>'
        content << "#{time_left * -1} jours"
      end
      
      content << '</div>'
    end
    
    return content.join
  end
  
  def show_start_date(task)
    content = []
    
    if task.started_on
      content << '<div class="line state started">En cours</div>'
      if task.started_on <= Date.today
        content << '<div class="line calendar"><label>Débuté le</label>' + task.started_on.strftime("%d-%m-%Y") + '</div>'
      else
        content << '<div class="line calendar"><label>À débuter le</label>' + task.started_on.strftime("%d-%m-%Y") + '</div>'
      end
    else
      content << '<div class="line state stopped">Non démarré</div>'
    end
    
    return content.join
  end
end