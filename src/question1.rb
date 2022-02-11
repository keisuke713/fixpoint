def question1(logs)
  cache = {}
  result = []
  logs.each do |log|
    time = log[0]
    address = log[1]
    response = log[2]

    next if cache.has_key?(address) && response == TIMEOUT_MESSAGE
    next if !(cache.has_key?(address) || response == TIMEOUT_MESSAGE)

    if cache.has_key?(address)
      result.push({"addrss" => address, "from" => cache[address], "to" => time})
      cache.delete(address)
    else
      cache[address] = time
    end
  end

  cache.each do |address, time|
    result.push({"address" => address, "from" => time, "to" => "-----"})
  end

  result
end