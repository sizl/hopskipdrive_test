require 'time'

class Clock

  def degree_from_time(time_str)
    time = Time.parse(time_str)
    hour = time.hour > 12 ? (time.hour - 12) : time.hour
    degree = ((time.min * 6) - (hour * 30))
    degree = degree * -1 if degree < 0
    return (360 - degree) if degree > 180
    degree
  end
end
