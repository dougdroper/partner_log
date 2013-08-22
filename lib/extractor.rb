class Extractor
  SHOW_ACTION = "Admin::OrdersController#show as JSON"
  UPDATE_ACTION = "Admin::OrdersController#update as JSON"
  SESSION_CREATE = "Admin::SessionsController#create as HTML"

  def initialize(file)
    @file = file
  end

  def run
    enum = @file.each
    @file.each do |line|
      begin
        show_action(line, enum.peek) if line.include?(SHOW_ACTION)
        Output.puts line if line.include?(UPDATE_ACTION)
        Output.puts line if line.include?(SESSION_CREATE)
      rescue StopIteration
      end
    end
  end

  def show_action(action, params_line)
    params = ParameterLine.new(params_line).params
    # Output.puts(action + params)
  end
end

class Output
  def self.puts(arg)
    STDOUT.puts arg
  end
end