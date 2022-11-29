Date.prototype.toFormattedString = function(include_time)
{
  if (include_time)
    str = this.strftime("%b %d, %Y %I:%M %p")
  else
    str = this.strftime("%b %d, %Y")
  end
  return str
}

Date.parseFormattedString = function(string) 
{
  if string.match "*(pm|am)"
    date = Date.strptime(string, "%b %d, %Y %I:%M %p")
  else
    date = Date.strptime(string, "%b %d, %Y")
  end
  return date
}
