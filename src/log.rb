class Log
  TIMEOUT_MESSAGE = "-"
  attr_reader :time, :response

  def initialize(time, address, response)
    @time = time
    @address = address
    @response = response
  end

  def is_timeout?
    response == TIMEOUT_MESSAGE
  end

  def network
    @address.network
  end

  def host
    @address.host
  end

  def address
    @address.to_string
  end
end