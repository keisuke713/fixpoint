require "pry"
require "set"
TIMEOUT_MESSAGE = "-"
NOT_FIX_MESSAGE = "-----"

def fetch_not_working_networks(logs, limits)
  # ダウンしたネットワークを管理
  # {network => from, network => from}
  not_working_networks = {}
  # ダウンしているアドレスを管理
  # {network => [host, host], network => [host, host]}
  not_working_addresses = {}
  # アドレスごとのタイムアウトした回数を管理
  # {address => N, address => N}
  not_working_limits = {}
  addresses_by_grouping_network = fetch_addresses_by_grouping_network(logs)
  result = []

  logs.each do |log|
    time = log[0]
    address = log[1]
    splited_address = split_address(address)
    network = splited_address.fetch("network")
    host = splited_address.fetch("host")
    response = log[2]
    
    # タイムアウトした場合
    # not_working_limitsにアドレスを追加
    # 上限に達していたらnot_working_addressに追加
    # not_working_addressesの数がaddress_by_grouping_networkと同じだったらnot_working_networksにネットワークと時間を保持
    
    # タイムアウトしなかった場合
    # 該当のネットワークがnot_working_networksに含まれていた場合resultにネットワークとfrom,toを追加し、取り除く
    # 該当のアドレスがnot_working_addressesに含まれていた場合は取り除く。
    # not_working_limitsを0に戻す
    if response == TIMEOUT_MESSAGE
      not_working_limits.store(address, not_working_limits.fetch(address, 0) + 1)
      if not_working_limits.fetch(address) >= limits
        not_working_addresses.store(network, Set.new) unless not_working_addresses.has_key?(network)
        not_working_addresses.fetch(network).add(host) unless not_working_addresses.fetch(network).include?(host)
        if not_working_addresses.fetch(network).size == addresses_by_grouping_network.fetch(network).size && !not_working_networks.has_key?(network)
          not_working_networks.store(network, time)
        end
      end
    else
      if not_working_networks.has_key?(network)
        result.push({"network" => network, "from" => not_working_networks.fetch(network), "to" => time})
        not_working_networks.delete(network)
      end
      if not_working_addresses.fetch(network, Set.new).include?(host)
        not_working_addresses.fetch(network).delete(host)
      end
      not_working_limits.store(address, 0)
    end
  end

  not_working_networks.each do |network, time|
    result.push("network" => network, "from" => time, "to" => NOT_FIX_MESSAGE)
  end

  result
end

def fetch_addresses_by_grouping_network(logs)
  addresses_by_grouping_network = {}
  logs.each do |log|
    splited_address = split_address(log[1])
    network = splited_address.fetch("network")
    host = splited_address.fetch("host")

    addresses_by_grouping_network.store(network, Set.new) unless addresses_by_grouping_network.has_key?(network)
    addresses_by_grouping_network.fetch(network).add(host)
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