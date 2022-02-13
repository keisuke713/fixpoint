class LogReader
  NOT_FIX_MESSAGE = "-----"
  START = "=============== ログの読み込みを始めます。 ================="
  FINISH = "=============== ログの読み込みを終了します。 ================="
  HEADER = "--------------"

  def initialize(logs, networks)
    @logs = logs
    @networks = networks
  end

  # 実際の処理と出力を分けたのは自動テストを行いやすくするため
  def display_not_working_servers
    puts START
    not_working_servers.each do |server|
      puts HEADER
      puts "サーバーアドレス: #{server["address"]}"
      puts "タイムアウト時刻: #{server["from"]}"
      puts "復旧時刻: #{server["to"]}"
    end
    puts FINISH
  end

  def display_overloaded_servers
    puts START
    overloaded_servers.each do |server|
      puts "------------------"
      puts "サーバーアドレス: #{server["address"]}"
      puts "開始時刻: #{server["from"]}"
      puts "終了時刻: #{server["to"]}"
    end
    puts FINISH
  end

  def display_not_working_networks
    puts START
    not_working_networks.each do |server|
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

    # 最後まで復旧しなかったServerも存在することが考えられるため
    servers.select{|address, server|
      server.is_not_working?
    }.each {|address, server|
      result.push({"address" => server.address, "from" => server.time_when_not_working, "to" => NOT_FIX_MESSAGE})
    }

    result
  end

  def overloaded_servers
    result = []
    overloaded_time_keeper = servers.map {|network, server|
      [server, nil]
    }.to_h

    logs.each do |log|
      next if log.is_timeout?

      server = servers.fetch(log.address)

      server.push_(log.response, log.time)
      if server.is_overloaded? && overloaded_time_keeper.fetch(server).nil?
        overloaded_time_keeper.store(server, server.first_time_when_overloaded)
      end
      if server.is_not_overloaded? && overloaded_time_keeper.fetch(server)
        result.push({"address" => server.address, "from" => overloaded_time_keeper.fetch(server), "to" => server.last_time_when_overloaded})
        overloaded_time_keeper.store(server, nil)
      end
    end

    overloaded_time_keeper.each do |server, time|
      if time
        result.push({"address" => server.address, "from" => time, "to" => NOT_FIX_MESSAGE})
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

    # 最後まで復旧しなかったネットワークが考えられるため
    networks.select { |network|
      network.is_not_working?
    }.each { |network|
      result.push({"network" => network.network, "from" => network.time_when_not_working, "to" => NOT_FIX_MESSAGE})
    }
    result
  end

  private

  # これらのメンバ変数はパブリックメソッドにすると外部からも呼び出せてしまうためプライベートメソッドにする。
  # @logsなど@をいちいちタイピングするのは面倒なため、logs・networksメソッドでラップする。
  def logs
    @logs
  end

  def networks
    @networks
  end

  def network(curr_network)
    networks.find {|network|
      network.network == curr_network
    }
  end

  def servers
    networks.map { |network|
      network.servers.to_a
    }.flatten.map {|server|
      [server.address, server]
    }.to_h
  end
end