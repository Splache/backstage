module Tools::Krono
  #*************************************************************************************
  # CONSTANTS
  #*************************************************************************************
  TIME_ZONE_NAME = "Eastern Time (US & Canada)"


  #*************************************************************************************
  # PUBLIC METHODS
  #*************************************************************************************
  def self.datestamp(date=nil)
    date = Time.now unless date

    return date.strftime("%Y%m%d")
  end

  def self.format_in_time(number)
    minutes = (number >= 1) ? number.modulo(number.floor) : number
    minutes = (minutes * 60).to_i.to_s

    return number.floor.to_s.rjust(2, '0') + ':' + minutes.rjust(2, '0')
  end

  def self.get_date_limits(period, options={})
    options.reverse_merge!(:history => 0, :iso8601 => nil, :utc => false)

    period = HashTree.new(period) if period.is_a?(Hash)

    limits = {}

    if period.exists?('from') and period.exists?('to')
      limits[:date_start] = Time.parse(period.from.to_s)
      limits[:date_end] = Time.parse(period.to.to_s)
    else
      date_start = Time.parse(period.get('starting_on').to_s)
      days_in_period = period.get('period').to_i

      if days_in_period == 30
        if date_start.end_of_month == date_start.end_of_day
          limits[:date_start] = (date_start - (options[:history]).month).beginning_of_month
          limits[:date_end] = (date_start - options[:history].month).end_of_month
        else
          limits[:date_start] = date_start - (options[:history]+1).month + 1.day
          limits[:date_end] = date_start - options[:history].month
        end
      elsif days_in_period == 91
        if date_start.end_of_month == date_start.end_of_day
          limits[:date_start] = (date_start - ((options[:history]+1)*3-1).month).beginning_of_month
          limits[:date_end] = (date_start - (options[:history]*3).month).end_of_month
        else
          limits[:date_start] = date_start - ((options[:history]+1)*3).month + 1.day
          limits[:date_end] = date_start - (options[:history]*3).month
        end
      else
        limits[:date_start] = date_start - (days_in_period * (options[:history]+1)).days + 1.day
        limits[:date_end] = date_start - (days_in_period * options[:history]).days
      end

      limits[:date_end] = limits[:date_end].end_of_day
    end

    if options[:utc]
      limits[:date_start] = limits[:date_start].getgm
      limits[:date_end] = limits[:date_end].getgm
    end

    if options[:iso8601]
      limits[:date_start] = self.to_iso8601(limits[:date_start], options[:iso8601])
      limits[:date_end] = self.to_iso8601(limits[:date_end], options[:iso8601])
    end

    return limits
  end

  def self.gmt_offset(datetime)
    offset = (datetime.gmt_offset / 3600)
    if offset < 0
      return (offset < -9) ? "-#{offset*-1}00" : "-0#{offset*-1}00"
    else
      return (offset > 9) ? "+#{offset}00" : "+0#{offset}00"
    end
  end

  def self.is_in_period?(target, period, options={})
    options.reverse_merge!(:past_years => 0)

    limits = get_date_limits(period)

    (options[:past_years]+1).times do |i|
      return true if (target >= (limits[:date_start] - i.years) and target <= (limits[:date_end] - i.years))
    end

    return false
  end

  def self.is_valid?(strtime, options={})
    options.reverse_merge!(:blank_is_valid => true)
    begin
      if !strtime.blank?
        time_parsed = Time.parse(strtime)
        return true
      else
        return true if options[:blank_is_valid]
      end
    rescue
    end
    return false
  end

  def self.parse_timestamp(raw_timestamp, options={})
    options.reverse_merge!(:time_only => false)

    timestamp = Time.parse(raw_timestamp + '-0000').getlocal

    if options[:time_only]
      return timestamp.strftime("%H:%M:%S")
    end
  end

  def self.seconds_to_unit(seconds, options={})
    options.reverse_merge!(:force => nil, :format => :time, :show_unit => true)
    seconds = seconds.to_f

    result = seconds
    time_table = {'year' => 31536000, 'day' => 86400, 'hour' => 3600, 'minute' => 60, 'second' => 1}
    unit_selected = 'second'

    time_table.each do |unit, value|
      if (seconds >= value and not options[:force]) or (unit == options[:force])
        unit_selected = unit
        result = seconds / value
        break
      end
    end

    formatted_result = (options[:format] == :time) ? format_in_time(result) : sprintf("%0.02f", result)

    if options[:show_unit]
      return formatted_result + " " + I18n.t("datetime.short.#{unit_selected}")
    else
      return formatted_result.to_i
    end
  end

  def self.show_period(raw_date_start, raw_date_end, options={})
    options.reverse_merge!(:html => true, :wrapper => 'span')

    if raw_date_start.year == raw_date_end.year
      if raw_date_start.month == raw_date_end.month
        if raw_date_start.day == raw_date_end.day
          date_start = I18n.localize(raw_date_start, :format => :short_month)
          date_end = ''
        else
          date_start = raw_date_start.day.to_s
          date_end = I18n.localize(raw_date_end, :format => :short_month)
        end
      else
        date_start = I18n.localize(raw_date_start, :format => :short_month)
        date_end = I18n.localize(raw_date_end, :format => :short_month)
      end
    else
      date_start = I18n.localize(raw_date_start, :format => :long)
      date_end = I18n.localize(raw_date_end, :format => :long)
    end

    if options[:html]
      content = []
      content << '<' + options[:wrapper] + ' class="period">' unless options[:wrapper].to_s.empty?
      if date_end.empty?
        content << '<span class="start-only">' + date_start + '</span>'
      else
        content << '<span class="start">' + date_start + '</span>'
        content << '<span class="union"> ' + I18n.t('date.connector') + ' </span>'
        content << '<span class="end">' + date_end + '</span>'
      end
      content << '</' + options[:wrapper] + '>' unless options[:wrapper].to_s.empty?

      return content.join
    elsif date_end.empty?
      return date_start
    else
      return date_start + ' ' + I18n.t('date.connector') + ' ' + date_end
    end
  end

  def self.start_timer
    @timer = Time.now
  end

  def self.stop_timer
    result = Time.now - @timer

    return result
  end

  def self.time_process_in_seconds(time)
    time = time.split('.')[0]
    new_time = time.split(':')

    return (new_time[new_time.length-2].to_i * 60).to_i + new_time.last.to_i
  end

  def self.timestamp(date=nil)
    date = Time.now.getgm unless date

    return date.strftime("%Y%m%d%H%M%S")
  end

  def self.timestamp_db(date=nil)
    date = Time.now unless date

    return date.strftime("%Y-%m-%d %H:%M:%S")
  end

  def self.to_iso8601(date, format='basic')
    if format == 'basic'
      return date.strftime("%Y%m%dT%H%M%S")
    else
      return date.iso8601
    end
  end

  def self.utc(date, format='datetime')
    Time.zone = TIME_ZONE_NAME
    result = Time.zone.parse(date)
    result = result.utc

    case format
      when 'w3c' then result = result.strftime("%Y-%m-%dT%H:%M:%SZ")
    end

    return result
  end
end
