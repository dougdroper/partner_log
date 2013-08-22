class EmailLookup
  def initialize
    @table = {}
  end

  def insert(params)
    @table[params['authenticity_token']] = params['email']
  end    

  def find(token)
    @table[token]
  end
end