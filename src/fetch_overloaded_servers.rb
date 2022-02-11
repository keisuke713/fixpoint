require "pry"
TIMEOUT_MESSAGE = "-"

def fetch_overloaded_servers(logs, limit, average)
  servers_queue = {}
  response_sums = {}
  result = []

  logs.each do |log|
    time = log[0]
    address = log[1]
    response = log[2]

    next if response == TIMEOUT_MESSAGE

    response_sums.store(address, response_sums.fetch(address, 0) + response.to_i)
    if servers_queue.has_key?(address)
      servers_queue.fetch(address).push({"time" => time, "response" => response.to_i})
    else
      servers_queue.store(address, [{"time" => time, "response" => response.to_i}])
    end
    if servers_queue.fetch(address).size > limit
      oldest_data = servers_queue.fetch(address).shift
      response_sums.store(address, response_sums.fetch(address) - oldest_data.fetch("response"))
    end

    next if servers_queue.fetch(address).size < limit
    current_average = (response_sums.fetch(address) / limit).floor
    result.push({"address" => address, "from" => servers_queue.fetch(address)[0].fetch("time"), "to" => time}) if current_average >= average
  end

  result
end