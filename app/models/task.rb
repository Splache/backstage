class Task < ActiveRecord::Base
  belongs_to :project
  belongs_to :collection
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :worker, :class_name => 'User', :foreign_key => 'assigned_to'
  
  def self.all_from_section(section, user, archived)
    conditions = []
    conditions << (archived ? 'ended_on != ""' : 'ended_on = "" OR ended_on IS NULL')
    get_natures.each { |n| conditions << "nature = '#{n[1]}'" if section == n[1] }
    
    conditions << "assigned_to = #{user.id}" if section == 'my_tasks'
    
    #raise conditions.join(' AND ').inspect
    
    return self.all(:conditions => conditions.join(' AND '))
  end
  
  def set_dates_from_params(params)
    self.due_on = '' if params[:show_due_on] != '1'
    self.started_on = '' if params[:show_started_on] != '1'
    self.ended_on = '' if params[:show_ended_on] != '1'
    
    self.save
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
  
  def identifier
    return self.nature[0,1].upcase + '-' + self.identifier_no.to_s.rjust(6, '0')
  end
end