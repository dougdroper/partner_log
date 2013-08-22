class ParameterLine
  def initialize(line)
    @line = line
  end

  def params
    eval(@line.split(/Parameters: /).last)
  end
end