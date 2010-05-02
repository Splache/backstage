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