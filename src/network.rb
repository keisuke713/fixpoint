class Network
  attr_reader :network, :servers, :time_when_not_working
  def initialize(network, servers)
    @network = network
    @servers = servers
    @time_when_not_working = nil
  end

  def is_working?
    servers.inject(false) {|result, server| result || server.is_working? }
  end

  def is_not_working?
    !is_working?
  end

  def break(time)
    @time_when_not_working = time
  end

  def fix
    @time_when_not_working = nil
  end
end