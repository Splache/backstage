module TaskHelper
  def show_task_due_on(task)
    content = []
    if task.due_on
      time_left = Date.today - task.due_on
      
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
end