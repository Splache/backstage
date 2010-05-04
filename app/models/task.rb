class Task < ActiveRecord::Base
  belongs_to :collection
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :project
  belongs_to :worker, :class_name => 'User', :foreign_key => 'assigned_to'
  
  has_many :comments, :order => "created_at ASC", :dependent => :destroy
  
  named_scope :active, :conditions => "ended_on = '' OR ended_on IS NULL", :order => 'priority ASC'
  named_scope :archived, :conditions => "ended_on != '' AND ended_on IS NOT NULL"
  
  def self.all_from_filters(user, filters)
    conditions = []
    conditions << (filters[:archive] ? 'ended_on != ""' : 'ended_on = "" OR ended_on IS NULL')
    parameters = []
    
    get_natures.each { |n| conditions << "nature = '#{n[1]}'" if filters[:nature] == n[1] }
    
    conditions << "assigned_to = #{filters[:assigned_to].to_i}" if filters[:assigned_to]
    
    if filters[:move]
      conditions << "updated_at >= ?"
      parameters << Time.now - filters[:move].to_i.days 
    end
    
    order = filters[:archive] ? 'ended_on DESC' : 'priority ASC'
    
    conditions = [conditions.join(' AND '), parameters].flatten
    
    return self.all(:conditions => conditions, :order => order)
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
  
  def self.regenerate_priorities(project_id, options={})
    options.reverse_merge!(:skip_task => nil)
    position = 1
    
    conditions = ['project_id = ?', "ended_on = '' OR ended_on IS NULL"]
    parameters = [project_id]
    
    if options[:skip_task]
      conditions << 'id != ?'
      parameters << options[:skip_task].id
    end
    
    tasks = Task.all(:conditions => [conditions.join(' AND '), parameters].flatten, :order => 'priority ASC')
    
    tasks.each do |task|
      position += 1 if options[:skip_task] and position == options[:skip_task].priority
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
    self.priority = new_priority
    self.save
    
    Task.regenerate_priorities(self.project_id, :skip_task => self)
  end
  
  def set_archive_status!
    prioritize_to((self.archived? ? 0 : 1))
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