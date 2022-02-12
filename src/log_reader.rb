class LogReader
  TIMEOUT_MESSAGE = "-"
  NOT_FIX_MESSAGE = "-----"
  attr_reader :logs
  # accepts List<Log> logs
  def initialize(logs)
    @logs = logs
  end
  
  def not_working_servers(limits)
    not_working_servers = {}
    not_working_limits = {}
    result = []

    logs.each do |log|
      if log.response == TIMEOUT_MESSAGE
        next if not_working_servers.has_key?(log.address)
        not_working_limits.store(log.address, not_working_limits.fetch(log.address, 0) + 1)
        not_working_servers.store(log.address, log.time) if not_working_limits.fetch(log.address) >= limits
      else
        if not_working_servers.has_key?(log.address)
          result.push({"address" => log.address, "from" => not_working_servers[log.address], "to" => log.time})
          not_working_servers.delete(log.address)
        end
        not_working_limits.store(log.address, 0)
      end
    end

    not_working_servers.each do |address, time|
      result.push({"address" => address, "from" => time, "to" => NOT_FIX_MESSAGE})
    end

    result
  end
end