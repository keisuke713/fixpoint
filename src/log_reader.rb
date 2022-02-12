class LogReader
  TIMEOUT_MESSAGE = "-"
  NOT_FIX_MESSAGE = "-----"
  # accepts List<Log> logs
  def initialize(logs)
    @logs = logs
  end

  def a
    puts @logs.size
  end
end