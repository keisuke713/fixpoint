require "pry"
TIMEOUT_MESSAGE = "-"
NOT_FIX_MESSAGE = "-----"

def fetch_not_working_servers(logs, times)
  not_working_addresses = {}
  not_working_times = {}
  result = []

  logs.each do |log|
    time = log[0]
    address = log[1]
    response = log[2]

    if response == TIMEOUT_MESSAGE
      next if not_working_addresses.has_key?(address)
      not_working_times.store(address, not_working_times.fetch(address, 0) + 1)
      not_working_addresses.store(address, time) if not_working_times.fetch(address) >= times
    else
      if not_working_addresses.has_key?(address)
        result.push({"address" => address, "from" => not_working_addresses[address], "to" => time})
        not_working_addresses.delete(address)
      end
      not_working_times.store(address, 0)
    end
  end

  not_working_addresses.each do |address, time|
    result.push({"address" => address, "from" => time, "to" => NOT_FIX_MESSAGE})
  end

  result
end