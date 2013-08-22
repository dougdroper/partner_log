
class ActionInterval
  attr_accessor :end_time, :start_time, :end_action, :start_action
  @@table = {}

  def initialize(time, action)
    @start_time = time
    @start_action = action
  end

  def self.set(time, token, order_id, action)
    k = key(token, order_id)
    if ending_interval = find(k)
      ending_interval.end_time = time
      ending_interval.end_action = action
    end
    @@table[k] = ActionInterval.new(time, action)
    ending_interval
  end

  def duration
    @end_time - @start_time
  end

  private

  def self.find(k)
    @@table[k]
  end

  def self.key(token, order_id)
    order_id + ":" + token
  end
end