class Server
  attr_reader :network, :time_when_not_working

  def initialize(address, limit, response_array, average)
    set_network_and_host(address)
    @limit = limit
    @response_array = response_array
    @average = average
    @amount_of_broken = 0
    @time_when_not_working = nil
  end

  def is_working?
    amount_of_broken < limit
  end

  def is_not_working?
    !is_working?
  end

  def break(time)
    @amount_of_broken += 1
    if is_not_working? && time_when_not_working.nil?
      @time_when_not_working = time
    end
  end

  def fix
    @amount_of_broken = 0
    @time_when_not_working = nil
  end

  def address
    [
      [network, host].join("."), subnet
    ].join("/")
  end

  def push_(response, time)
    response_array.push(response.to_i, time)
  end

  def is_overloaded?
    return false unless response_array.is_full?
    curr_average = response_array.average
    return false if curr_average.negative?
    curr_average >= average
  end

  def start
    response_array.start
  end

  private

  def set_network_and_host(address)
    tmp = address.split(/\.|\//)
    @subnet = tmp[-1].to_i
    partition = subnet / 8
    @network = tmp[0...partition].join(".")
    @host = tmp[partition...-1].join(".")
  end

  def amount_of_broken
    @amount_of_broken
  end

  def limit
    @limit
  end

  def subnet
    @subnet
  end

  def host
    @host
  end

  def response_array
    @response_array
  end

  def average
    @average
  end
end