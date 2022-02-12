class Network
  attr_reader :network, :servers
  def initialize(network, servers)
    @network = network
    @servers = servers
  end
end