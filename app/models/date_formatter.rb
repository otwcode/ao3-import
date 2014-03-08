class DateFormatter

  # If we have a date, convert it to a consistent format
  # If the whole date is numbers, treat it as seconds since the epoch
  def self.format(date_string)
    date_string ||= ''
    if date_string.match(/^(\d+)$/)
      date = Time.at($1.to_i)
    else
      date = Date.parse(date_string)
    rescue ArgumentError, TypeError
      date = ''
    end
    date
  end

end