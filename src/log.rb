class Log
  TIMEOUT_MESSAGE = "-"
  def initialize(time, address, response)
    @time = time
    @address = address
    @response = response
  end

  attr_reader :time, :address, :response

  def is_timeout?
    response == TIMEOUT_MESSAGE
  end
end