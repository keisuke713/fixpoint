class Log
  TIMEOUT_MESSAGE = "-"
  attr_reader :time, :network, :host, :subnet, :response

  def initialize(time, address, response)
    @time = time
    @response = response
    set_network_and_host_and_subnet(address)
  end

  def is_timeout?
    response == TIMEOUT_MESSAGE
  end

  def address
    [
      [network, host].join("."), subnet
    ].join("/")
  end

  private

  def set_network_and_host_and_subnet(address)
    tmp = address.split(/\.|\//)
    @subnet = tmp[-1].to_i
    partition = subnet / 8
    @network = tmp[0...partition].join(".")
    @host = tmp[partition...-1].join(".")
  end
end