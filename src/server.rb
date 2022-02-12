class Server
  attr_reader :amount_of_broken, :limit
  attr_accessor :network, :host, :subnet, :time_when_not_working

  def initialize(address, limit, time, average)
    set_network_and_host(address)
    @limit = limit
    @time = time
    @average = average
    @amount_of_broken = 0
    @time_when_not_working = nil
  end

  def is_working?
    @amount_of_broken < limit
  end

  def is_not_working?
    !is_working?
  end

  def break(time)
    @amount_of_broken += 1
    if is_not_working? && time_when_not_working.nil?
      self.time_when_not_working = time
    end
  end

  def fix
    @amount_of_broken = 0
    self.time_when_not_working = nil
  end

  def address
    [
      [network, host].join("."), subnet
    ].join("/")
  end

  private

  def set_network_and_host(address)
    tmp = address.split(/\.|\//)
    self.subnet = tmp[-1].to_i
    partition = subnet / 8
    self.network = tmp[0...partition].join(".")
    self.host = tmp[partition...-1].join(".")
  end
end