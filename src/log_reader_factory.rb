class LogReaderFactory
  # take List<String> logs
  def initialize(logs)
    @logs = logs
  end

  def build
    LogReader.new(
      @logs.map {|log|
        Log.new(log[0], Address.new(log[1]), log[2])
      }
    )
  end
end