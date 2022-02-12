class Server
  attr_accessor :network, :host, :subnet

  def initialize(address)
    set_network_and_host(address)
    @work = true
  end

  def is_working?
    @work
  end

  def break
    @work = false
  end

  def fix
    @work = true
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

  def to_string
    [
      [network, host].join("."), subnet
    ].join("/")
  end
end