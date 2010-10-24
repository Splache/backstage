class Task < ActiveRecord::Base
  belongs_to :collection
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :project
  belongs_to :worker, :class_name => 'User', :foreign_key => 'assigned_to'
  
  has_many :comments, :order => "created_at ASC", :dependent => :destroy
  
  scope :active, where("ended_on = '' OR ended_on IS NULL").order('priority ASC')
  scope :archived, where("ended_on != '' OR ended_on IS NULL")
  
  
  #*************************************************************************************
  # PUBLIC CLASS METHODS
  #*************************************************************************************
  def self.all_for_report(user, options={})
    options.reverse_merge!(:begin_at => Time.now, :end_at => Time.now)
    
    user_targets = user.subscriptions.map{ |t| t.target_id }
    user_targets << user.id
    
    tasks = Task.includes(:comments)
    tasks = tasks.where('created_by IN (?) OR assigned_to IN (?)', user_targets, user_targets)
    tasks = tasks.where('tasks.updated_at > ? OR comments.updated_at > ?', options[:begin_at], options[:begin_at])

    return tasks
  end
  
  def self.all_from_options(user, project, options)
    tasks = Task.includes(:comments)
    tasks = tasks.where("project_id = ?", project.id)
    tasks = tasks.where((options[:archive] ? 'ended_on != ""' : '(ended_on = "" OR ended_on IS NULL)'))
    
    get_natures.each { |n| tasks = tasks.where("nature = ?", n[1]) if options[:nature] == n[1] }
    
    tasks = tasks.where((options[:assigned_to].to_i != 0 ? "assigned_to = #{options[:assigned_to].to_i}" : "assigned_to IS NULL")) if options[:assigned_to]

    if options[:move]
      move = Time.now - options[:move].to_i.days
      tasks = tasks.where("(tasks.updated_at >= ? OR comments.updated_at >= ?)", move, move)
    end
        
    if options[:search]
      options[:search].split(' ').each do |term|
        tasks = tasks.where('(name LIKE ? OR description LIKE ?)', "%#{term}%", "%#{term}%") unless term.empty?
      end
    end
    
    if options[:archive]
      tasks = tasks.order('ended_on DESC')
    elsif options[:sort] == 'created_at'
      tasks = tasks.order("created_at DESC")
    elsif options[:sort] == 'due_on'
      tasks = tasks.order("(case WHEN due_on IS NULL THEN 1 ELSE 0 END), due_on ASC")
    else
      tasks = tasks.order("priority ASC")
    end

    return tasks
  end
  
  def self.get_natures
    natures = []
    natures << ['Développement', 'development']
    natures << ['Fix', 'fix']
    natures << ['Optimisation', 'optimisation']
    natures << ['Production', 'production']
    natures << ['Communication', 'communication']
    natures << ['Interface et linguistique', 'interface']
    natures << ['Test', 'test']
    
    return natures
  end
  
  def self.regenerate_priorities(project_id, options={})
    options.reverse_merge!(:skip_task => nil)
    position = 1
    
    tasks = Task.where('project_id = ?', project_id)
    tasks = tasks.where("ended_on = '' OR ended_on IS NULL")
    tasks = tasks.where("id != ?", options[:skip_task].id) if options[:skip_task]
    tasks = tasks.order('priority ASC')

    tasks.all.each do |task|
      position += 1 if options[:skip_task] and position == options[:skip_task].priority
      Task.update_all("priority = #{position}", "id = #{task.id}" ) 
      position += 1
    end
  end
  
  
  #*************************************************************************************
  # PUBLIC METHODS
  #*************************************************************************************
  def archived?
    return (self.ended_on.to_s.empty? ? false : true)
  end
  
  def identifier
    return self.nature[0,1].upcase + '-' + self.identifier_no.to_s.rjust(6, '0')
  end
  
  def insert_after(previous_task_id)
    previous = Task.first(:conditions => {:id => previous_task_id })
    
    if self.priority > previous.priority
      prioritize_to(previous.priority + 1)
    else
      prioritize_to(previous.priority)
    end
  end
  
  def nature_human
    Task.get_natures.each { |n| return n[0] if n[1] == self.nature }
    
    return ''
  end

  def prioritize_to(new_priority)
    self.priority = new_priority
    self.save
    
    Task.regenerate_priorities(self.project_id, :skip_task => self)
  end
  
  def set_archive_status!
    if self.archived?
      prioritize_to(0) if self.priority != 0
    elsif self.priority == 0
      prioritize_to(1)
    end
  end
  
  def set_dates_from_params(params)
    self.due_on = '' if params[:show_due_on] != '1'
    self.started_on = '' if params[:show_started_on] != '1'
    self.ended_on = '' if params[:show_ended_on] != '1'
    
    self.save
  end
  
  def set_identifier
    template = Task.first(:conditions => {:project_id => self.project_id, :nature => self.nature }, :order => 'identifier_no DESC')
    
    if template
      self.identifier_no = template.identifier_no + 1
      self.save
    end
  end
  
  def state
    if archived?
      return 'archived'
    elsif started_on
      return 'started'
    else
      return 'stopped'
    end
  end
  
  def state_f
    return case self.state
      when 'archived' then 'Terminée'
      when 'started' then 'En cours'
      when 'stopped' then 'Non démarrée'
    end
  end
end