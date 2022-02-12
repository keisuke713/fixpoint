require "pry"
class LogReader
  NOT_FIX_MESSAGE = "-----"
  START = "=============== ログの読み込みを始めます。 ================="
  FINISH = "=============== ログの読み込みを終了します。 ================="
  HEADER = "--------------"

  attr_reader :logs, :servers
  def initialize(logs, servers)
    @logs = logs
    @servers = servers
  end

  def display_not_working_servers(limits)
    puts START
    not_working_servers(limits).each do |server|
      puts HEADER
      puts "サーバーアドレス: #{server["address"]}"
      puts "タイムアウト時刻: #{server["from"]}"
      puts "復旧時刻: #{server["to"]}"
    end
    puts FINISH
  end

  def display_overloaded_servers(times, average)
    puts START
    overloaded_servers(times, average).each do |server|
      puts "------------------"
      puts "サーバーアドレス: #{server["address"]}"
      puts "開始時刻: #{server["from"]}"
      puts "終了時刻: #{server["to"]}"
    end
    puts FINISH
  end

  def display_not_working_networks(times)
    puts START
    not_working_networks(times).each do |server|
      puts "------------------"
      puts "サーバーアドレス: #{server["network"]}"
      puts "タイムアウト時刻: #{server["from"]}"
      puts "終了時刻: #{server["to"]}"
    end
    puts FINISH
  end

  def not_working_servers
    result = []
    logs.each do |log|
      server = servers.fetch(log.address)
      if log.is_timeout?
        next if server.is_not_working?
        server.break(log.time)
      else
        if server.is_not_working?
          result.push({"address" => server.address, "from" => server.time_when_not_working, "to" => log.time})
        end
        server.fix
      end
    end

    servers.select{|address, server|
      server.is_not_working?
    }.each {|address, server|
      result.push({"address" => server.address, "from" => server.time_when_not_working, "to" => NOT_FIX_MESSAGE})
    }

    result
  end

  def overloaded_servers
    result = []
    logs.each do |log|
      next if log.is_timeout?

      server = servers.fetch(log.address)

      server.push_(log.response, log.time)
      if server.is_overloaded?
        result.push({"address" => server.address, "from" => server.start, "to" => log.time})
      end
    end
    result
  end

  def not_working_networks(limits)
    # ダウンしたネットワークを管理
    # {network => from, network => from}
    not_working_networks = {}
    # ダウンしているアドレスを管理
    # {network => [host, host], network => [host, host]}
    not_working_addresses = {}
    # アドレスごとのタイムアウトした回数を管理
    # {address => N, address => N}
    not_working_limits = {}
    addresses_by_grouping_network = fetch_addresses_by_grouping_network
    result = []

    logs.each do |log|
      network = log.network
      host = log.host

      # タイムアウトした場合
      # not_working_limitsにアドレスを追加
      # 上限に達していたらnot_working_addressに追加
      # not_working_addressesの数がaddress_by_grouping_networkと同じだったらnot_working_networksにネットワークと時間を保持

      # タイムアウトしなかった場合
      # 該当のネットワークがnot_working_networksに含まれていた場合resultにネットワークとfrom,toを追加し、取り除く
      # 該当のアドレスがnot_working_addressesに含まれていた場合は取り除く。
      # not_working_limitsを0に戻す
      if log.is_timeout?
        not_working_limits.store(log.address, not_working_limits.fetch(log.address, 0) + 1)
        if not_working_limits.fetch(log.address) >= limits
          not_working_addresses.store(network, Set.new) unless not_working_addresses.has_key?(network)
          not_working_addresses.fetch(network).add(host) unless not_working_addresses.fetch(network).include?(host)
          if not_working_addresses.fetch(network).size == addresses_by_grouping_network.fetch(network).size && !not_working_networks.has_key?(network)
            not_working_networks.store(network, log.time)
          end
        end
      else
        if not_working_networks.has_key?(network)
          result.push({"network" => network, "from" => not_working_networks.fetch(network), "to" => log.time})
          not_working_networks.delete(network)
        end
        if not_working_addresses.fetch(network, Set.new).include?(host)
          not_working_addresses.fetch(network).delete(host)
        end
        not_working_limits.store(log.address, 0)
      end
    end

    not_working_networks.each do |network, time|
      result.push("network" => network, "from" => time, "to" => NOT_FIX_MESSAGE)
    end

    result
  end

  private

  def fetch_addresses_by_grouping_network
    addresses_by_grouping_network = {}
    logs.each do |log|
      network = log.network
      host = log.host

      addresses_by_grouping_network.store(network, Set.new) unless addresses_by_grouping_network.has_key?(network)
      addresses_by_grouping_network.fetch(network).add(host)
    end
    addresses_by_grouping_network
  end
end