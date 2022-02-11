require "pry"
TIMEOUT_MESSAGE = "-"
NOT_FIX_MESSAGE = "-----"

def fetch_broken_addresses(logs, times)
  broken_addresses = {}
  broken_times = {}
  result = []

  logs.each do |log|
    time = log[0]
    address = log[1]
    response = log[2]

    if response == TIMEOUT_MESSAGE
      next if broken_addresses.has_key?(address)
      broken_times.store(address, broken_times.fetch(address, 0) + 1)
      broken_addresses.store(address, time) if broken_times.fetch(address) >= times
    else
      if broken_addresses.has_key?(address)
        result.push({"address" => address, "from" => broken_addresses[address], "to" => time})
        broken_addresses.delete(address)
      end
      broken_times.store(address, 0)
    end
  end

  broken_addresses.each do |address, time|
    result.push({"address" => address, "from" => time, "to" => NOT_FIX_MESSAGE})
  end

  result
end