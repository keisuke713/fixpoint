TIMEOUT_MESSAGE = "-"

def question1(logs)
  log_cache = {}
  result = []
  logs.each do |log|
    time = log[0]
    address = log[1]
    response = log[2]

    next if log_cache.has_key?(address) && response == TIMEOUT_MESSAGE
    next if !(log_cache.has_key?(address) || response == TIMEOUT_MESSAGE)

    if log_cache.has_key?(address)
      result.push({"address" => address, "from" => log_cache[address], "to" => time})
      log_cache.delete(address)
    else
      log_cache[address] = time
    end
  end

  log_cache.each do |address, time|
    result.push({"address" => address, "from" => time, "to" => "-----"})
  end

  result
end