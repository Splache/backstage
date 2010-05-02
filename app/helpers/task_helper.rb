module TaskHelper
  def show_menu_tasks(archived)
    content = []
    
    content << '<ul class="tree">'
    content << '<li class="level1 folder show">' + link_to('Toutes les tâches',  tasks_path(:section => 'root')) + '</li>'
    content << '<li class="level1 folder show"><strong>' + link_to('Mes tâches',  my_tasks_path) + '</strong></li>'
    content << '<li class="level1 folder show" style="cursor:default">Par catégorie</li>'
    Task.get_natures.each { |t| content << '<li class="level2 folder show">' + link_to(t[0],  tasks_path(:section => t[1])) + '</li>' }

    content << '</ul>'
    
    content << '<div class="sub-navigation">'
    if archived
      content << link_to('Afficher les tâches en cours', tasks_path(:archived => 0), :class => 'current')
    else
      content << link_to('Afficher les tâches archivées', tasks_path(:archived => 1), :class => 'archive')
    end
    content << '</div>'
  end
  
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