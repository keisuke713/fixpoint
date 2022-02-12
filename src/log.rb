class Log
  def initialize(time, address, response)
    @time = time
    @address = address
    @response = response
  end

  attr_reader :time, :address, :response
end