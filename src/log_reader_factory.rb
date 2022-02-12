class LogReaderFactory
  def initialize(logs)
    @logs = logs
    @limit = 1
  end

  def build
    LogReader.new(
      @logs.map {|log|
        Log.new(log[0], log[1], log[2])
      },
      @logs.map {|log|
        Server.new(log[1], @limit)
      }.map {|server|
        [server.address, server]
      }.to_h
    )
  end

  def set_limit(limit)
    @limit = limit
    self
  end
end