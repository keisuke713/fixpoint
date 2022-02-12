class LogReaderFactory
  def initialize(logs)
    @logs = logs
    @limit = 1
    @time = 0
    @average = 0
  end

  def build
    LogReader.new(logs, networks)
  end

  # メソッドチェーンで繋げるため戻り値をselfにしている
  def set_limit(limit)
    @limit = limit
    self
  end

  def set_time(time)
    @time = time
    self
  end

  def set_average(average)
    @average = average
    self
  end

  private

  def logs
    @logs.map {|log| Log.new(log[0], log[1], log[2])}
  end

  def networks
    servers = @logs.map {|log|
      log[1]
    }.to_set.to_a.map{|log|
      Server.new(log, @limit, ResponseArray.new(@time), @average)
    }
    networks = {}
    servers.each do |server|
      if !networks.has_key?(server.network)
        networks.store(server.network, Set.new)
      end
      networks.fetch(server.network).add(server)
    end
    networks.map {|network, servers| Network.new(network, servers)}
  end
end