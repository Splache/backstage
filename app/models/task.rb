class Task < ActiveRecord::Base
  belongs_to :collection
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :project
  belongs_to :worker, :class_name => 'User', :foreign_key => 'assigned_to'
  
  has_many :comments, :order => "created_at ASC", :dependent => :destroy
  
  named_scope :active, :conditions => "ended_on = '' OR ended_on IS NULL", :order => 'priority ASC'
  named_scope :archived, :conditions => "ended_on != '' AND ended_on IS NOT NULL"
  
  def self.all_from_section(section, user, archived)
    conditions = []
    conditions << (archived ? 'ended_on != ""' : 'ended_on = "" OR ended_on IS NULL')
    get_natures.each { |n| conditions << "nature = '#{n[1]}'" if section == n[1] }
    
    conditions << "assigned_to = #{user.id}" if section == 'my_tasks'
    
    if archived
      order = 'ended_on DESC'
    else
      order = 'priority ASC'
    end
    
    return self.all(:conditions => conditions.join(' AND '), :order => order)
  end
  
  def self.get_natures
    natures = []
    natures << ['Développement', 'development']
    natures << ['Fix', 'fix']
    natures << ['Optimisation', 'optimisation']
    natures << ['Production', 'production']
    natures << ['Communication', 'communication']
    natures << ['Interface et linguistique', 'interface']
    
    return natures
  end
  
  def self.regenerate_priorities
    position = 1
    
    self.active.each do |task|
      Task.update_all("priority = #{position}", "id = #{task.id}" ) 
      position += 1
    end
  end
  
  
  def archived?
    return (self.ended_on.to_s.empty? ? false : true)
  end
  
  def nature_human
    natures = Task.get_natures
    
    natures.each { |n| return n[0] if n[1] == self.nature }
    
    return ''
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

  def prioritize_to(new_priority)
    position = 1
    tasks = Task.active(:order => 'priority ASC')
    
    tasks.each do |task|
      if self.id != task.id
        position += 1 if new_priority == task.priority and self.priority > new_priority
        
        Task.update_all("priority = #{position}", "id = #{task.id}" ) 
        position += 1
        
        position += 1 if new_priority == position and self.priority < new_priority
      end
    end
    
    self.priority = new_priority
    self.save
  end
  
  def set_archive_status!
    if self.archived?
      self.priority = 0
      self.save
    end
    
    Task.regenerate_priorities
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
end