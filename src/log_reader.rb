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

  def overloaded_servers(limit, average)
    servers_queue = {}
    response_sums = {}
    result = []

    logs.each do |log|
      next if log.response == TIMEOUT_MESSAGE

      response_sums.store(log.address, response_sums.fetch(log.address, 0) + log.response.to_i)
      if servers_queue.has_key?(log.address)
        servers_queue.fetch(log.address).push({"time" => log.time, "response" => log.response.to_i})
      else
        servers_queue.store(log.address, [{"time" => log.time, "response" => log.response.to_i}])
      end
      if servers_queue.fetch(log.address).size > limit
        oldest_data = servers_queue.fetch(log.address).shift
        response_sums.store(log.address, response_sums.fetch(log.address) - oldest_data.fetch("response"))
      end

      next if servers_queue.fetch(log.address).size < limit
      current_average = (response_sums.fetch(log.address) / limit).floor
      result.push({"address" => log.address, "from" => servers_queue.fetch(log.address)[0].fetch("time"), "to" => log.time}) if current_average >= average
    end

    result
  end
end