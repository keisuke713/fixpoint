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
        log[1]
      }.to_set.to_a.map {|log|
        Server.new(log, @limit, ResponseArray.new(@time), @average)
      }
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