require "pry"
TIMEOUT_MESSAGE = "-"
NOT_FIX_MESSAGE = "-----"

def fetch_not_working_networks(logs, times)
  not_working_addresses = {}
  not_working_times = {}
  result = []

  logs.each do |log|
    time = log[0]
    address = log[1]
    response = log[2]
  end

  result
end