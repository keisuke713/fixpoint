class LogReaderFactory
  def initialize(logs)
    @logs = logs
    @limit = 1
    @time = 0
    @average = 0
  end

  def build
    LogReader.new(
      @logs.map {|log|
        Log.new(log[0], log[1], log[2])
      },
      @logs.map {|log|
        Server.new(log[1], @limit, ResponseArray.new(@time), @average)
      }.map {|server|
        [server.address, server]
      }.to_h
    )
  end

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
end