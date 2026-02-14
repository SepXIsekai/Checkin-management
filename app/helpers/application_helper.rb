module ApplicationHelper
  def format_datetime(datetime)
    return "-" if datetime.blank?
    datetime.strftime("%d %b %Y • %H:%M")
  end

  def format_date(date)
    return "-" if date.blank?
    date.strftime("%d %B %Y")
  end
end
