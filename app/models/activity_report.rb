class ActivityReport
  #*************************************************************************************
  # CONSTRUCTOR
  #*************************************************************************************
  def initialize(user, project, tasks, begin_at)
    @begin_at = begin_at
    @project = project
    @recipient = user
    @tasks = tasks
  end


  #*************************************************************************************
  # PUBLIC CLASS METHODS
  #*************************************************************************************
  def self.send_for_user(user, options={})
    options.reverse_merge!(:force => false, :start_at => self.report_start_at(user))

    if time_to_send?(user) or options[:force]
      Project.all.each do |project|
        tasks = Task.all_for_report(user, project, :begin_at => options[:start_at])

        if not tasks.empty?
          report = self.new(user, project, tasks, options[:start_at])
          ActivityReportMailer.standard_report(report).deliver
        end
      end
    end
  end


  #*************************************************************************************
  # PUBLIC METHODS
  #*************************************************************************************
  def closed_tasks(category=nil)
    tasks_for_category(category).select{ |t| t.archived? }
  end

  def comments_of(task)
    task.comments.select{ |c| c.updated_at >= @begin_at }
  end

  def new_tasks(category=nil)
    tasks_for_category(category).select{ |t| t.created_at >= @begin_at and not t.archived? }
  end

  def project
    @project
  end

  def recipient
    @recipient
  end

  def tasks_for_category(category=nil)
    category = :all if not category

    return case category
      when :all then @tasks
      when :worker then @tasks.select{ |t| t.worker == @recipient }
      when :team then @tasks.select{ |t| t.worker != @recipient }
    end
  end

  def total_tasks(category=nil)
    return tasks_for_category(category).length
  end

  def updated_tasks(category=nil)
    tasks_for_category(category).select{ |t| t.created_at < @begin_at and not t.archived? }
  end

  private


  #*************************************************************************************
  # PRIVATE CLASS METHODS
  #*************************************************************************************
  def self.report_start_at(user)
    frequency = user.send_report_every
    day = user.local_time(Time.now)
    current_hour = day.hour
    time_zone = Tools::Krono.gmt_offset(day)

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

    return Time.parse("#{day.year}-#{day.month}-#{day.day} #{hour} #{time_zone}").utc
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
