class Reason
  @@close_reason=""

  def self.close_reason_is(reason)
    @@close_reason = reason
  end

  def self.close_reason
    @@close_reason
  end
end
