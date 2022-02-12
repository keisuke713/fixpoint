class LogReaderFactory
  def initialize(logs)
    @logs = logs
  end

  def build
    LogReader.new(
      @logs.map {|log|
        Log.new(log[0], log[1], log[2])
      },
      @logs.map {|log|
        Server.new(log[1])
      }.map {|server|
        [server.address, server]
      }.to_h
    )
  end
end