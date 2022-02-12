require "pry"

class LogReader
  NOT_FIX_MESSAGE = "-----"
  START = "=============== ログの読み込みを始めます。 ================="
  FINISH = "=============== ログの読み込みを終了します。 ================="
  HEADER = "--------------"

  attr_reader :logs, :networks
  def initialize(logs, servers)
    @logs = logs
    @networks = set_networks(servers)
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

  def not_working_networks
    result = []
    logs.each do |log|
      network = network(log.network)
      server = servers.fetch(log.address)

      if log.is_timeout?
        next if server.is_not_working?
        server.break(log.time)
        network.break(log.time) if network.is_not_working?
      else
        if network.is_not_working?
          result.push({"network" => network.network, "from" => network.time_when_not_working, "to" => log.time})
        end
        server.fix
        network.fix
      end
    end

    networks.select { |network|
      network.is_not_working?
    }.each { |network|
      result.push({"network" => network.network, "from" => network.time_when_not_working, "to" => NOT_FIX_MESSAGE})
    }
    result
  end

  private

  def network(curr_network)
    networks.find {|network|
      network.network == curr_network
    }
  end

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

  def set_networks(servers)
    networks = {}
    servers.each do |server|
      if !networks.has_key?(server.network)
        networks.store(server.network, Set.new)
      end
      networks.fetch(server.network).add(server)
    end
    networks.map {|network, servers| Network.new(network, servers)}
  end

  def servers
    networks.map { |network|
      network.servers.to_a
    }.flatten.map {|server|
      [server.address, server]
    }.to_h
  end
end