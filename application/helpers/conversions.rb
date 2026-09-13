require "time"
require "tzinfo"
module Conversions
  #parse time to utc, used in Customer model
  def parse_time(time)
    Time.parse(time).utc
  end

  #convert any time object into uk timezones(GMT and BST) for comparasion
  def uk_time(time)
    time_zone = TZInfo::Timezone.get('Europe/London')
    time_zone.to_local(time)
  end

  #convert any time object into uk date for comparasion
  def uk_date(time)
    uk_time(time).to_date
  end

  #format time as string
  def formatted_time(time)
    time.strftime("%Y-%m-%d %H:%M:%S")
  end

  def safe_date_parse(date)
    Date.parse(date)
    rescue Date::Error, TypeError
      nil
  end

  def start_of_month(date)
    Date.new(date.year, date.month, 1)
  end

  def end_of_month(date)
    return Date.new(date.year + 1, 1, 1) - 1 if date.month == 12
    Date.new(date.year, date.month + 1, 1) - 1
  end

  def month_intervals(from_date = nil, to_date = nil)
    intervals = {}
    current = from_date
    begin_of_last = start_of_month(to_date)

    if current >= begin_of_last
      intervals[from_date] = to_date
      return intervals
    end

    while current < begin_of_last
      end_of_current = end_of_month(current)
      intervals[current] = end_of_current
      current = end_of_current + 1
    end

    intervals[begin_of_last] = to_date
    intervals
  end
  
  def parse_date_range_filter(from_date = nil, to_date = nil)
    from_date = safe_date_parse(from_date)
    to_date = safe_date_parse(to_date)
    to_date ||= Date.today
    from_date ||= to_date << 6
    return from_date, to_date
  end

  # convert price from a float to a formatted string (eg 1.5 -> 1.50, 1.530001 -> 1.53)
  def price_float_to_string(price_float)
      price_string = price_float.round(2).to_s
      decimal_places = price_string.split(".").last.length
      
      while decimal_places < 2 do
        price_string += "0"
        decimal_places = price_string.split(".").last.length
      end

      return price_string
  end
end