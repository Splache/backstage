class ActivityReport
  #*************************************************************************************
  # CONSTRUCTOR
  #*************************************************************************************
  def initialize(user, tasks, begin_at)
    @begin_at = begin_at
    @tasks = tasks
    @recipient = user
  end
  
  
  #*************************************************************************************
  # PUBLIC CLASS METHODS
  #*************************************************************************************  
  def self.send_for_user(user, options={})
    options.reverse_merge!(:force => false, :start_at => self.report_start_at(user))
    
    if time_to_send?(user) or options[:force]
      tasks = Task.all_for_report(user, :begin_at => options[:start_at])

      if not tasks.empty?
        report = self.new(user, tasks, options[:start_at])
        ActivityReportMailer.standard_report(report).deliver
      end
    end
  end
  
  
  #*************************************************************************************
  # PUBLIC METHODS
  #*************************************************************************************
  def closed_tasks
    @tasks.select{ |t| t.archived? }
  end
  
  def comments_of(task)
    task.comments.select{ |c| c.updated_at >= @begin_at }
  end
  
  def new_tasks
    @tasks.select{ |t| t.created_at >= @begin_at and not t.archived? }
  end
  
  def recipient
    @recipient
  end
  
  def total_tasks
    @tasks.length
  end
  
  def updated_tasks
    @tasks.select{ |t| t.created_at < @begin_at and not t.archived? }
  end
  
  private

  
  #*************************************************************************************
  # PRIVATE CLASS METHODS
  #*************************************************************************************
  def self.report_start_at(user)
    frequency = user.send_report_every
    day = user.local_time(Time.now)
    current_hour = day.hour
    
    if frequency.include?('hourly')
      hour = (current_hour-1).to_s + ':00:00'
      day -= 1.hour
    elsif frequency.include?('evening') and ((19..23).include?(current_hour) or (0..6).include?(current_hour))
      hour = '18:00:00'
      day -= 1.day if current_hour <= 6
    elsif frequency.include?('noon') and ((13..23).include?(current_hour) or (0..6).include?(current_hour))
      hour = '12:00:00'
      day -= 1.day if current_hour <= 6
    elsif frequency.include?('morning')
      hour = '06:00:00'
      day -= 1.day if current_hour <= 6
    else
      day -= 1.day
      hour = current_hour.to_s + ':00:00'
    end
    
    return Time.parse("#{day.year}-#{day.month}-#{day.day} #{hour} #{day.gmt_offset}").utc
  end
  
  def self.time_to_send?(user)
    frequency = user.send_report_every

    return false if frequency == 'never'
    return true if frequency == 'hourly'
    
    return case user.local_time(Time.now.utc).hour
      when 6 then  frequency.include?('morning')  
      when 12 then frequency.include?('noon')
      when 18 then frequency.include?('evening')
      else false
    end
  end
end