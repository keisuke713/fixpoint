require "pry"
require "set"
TIMEOUT_MESSAGE = "-"
NOT_FIX_MESSAGE = "-----"

def fetch_not_working_networks(logs, times)
  not_working_addresses = {}
  not_working_times = {}
  addresses_by_grouping_network = fetch_addresses_by_grouping_network(logs)
  result = []

  logs.each do |log|
    time = log[0]
    address = log[1]
    response = log[2]
  end

  result
end

def fetch_addresses_by_grouping_network(logs)
  addresses_by_grouping_network = {}
  logs.each do |log|
    splited_address = split_address(log[1])
    network = splited_address.fetch("network")
    host = splited_address.fetch("host")
    
    if addresses_by_grouping_network.has_key?(network)
      addresses_by_grouping_network.fetch(network).add(host)
    else
      addresses_by_grouping_network.store(network, Set.new([host]))
    end
  end
  addresses_by_grouping_network
end

def split_address(address)
  tmp = address.split(/\.|\//)
  subnet = tmp[-1].to_i / 8
  network = tmp[0...subnet].join(".")
  host = tmp[subnet...-1].join(".")
  {"network" => network, "host" => host}
end

input = [
  ["20201019133124", "192.168.1.1/24", "30"],
  ["20201019133125", "192.168.1.2/24", "-"],
  ["20201019133126", "10.20.30.2/16", "-"],
  ["20201019133134", "192.168.1.3/24", "-"],
  ["20201019133135", "192.168.1.1/24", "5"],
  ["20201019133136", "10.20.30.1/16", "1"],
  ["20201019133224", "192.168.1.2/24", "522"],
  ["20201019133225", "10.20.30.2/16", "1"],
  ["20201019133234", "192.168.1.1/24", "-"]
]

puts fetch_addresses_by_grouping_network(input)