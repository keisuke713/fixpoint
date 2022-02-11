require "csv"
require "pry"

TIMEOUT_MESSAGE = "-"

puts "読み込みたいファイル名を拡張子抜きで入力してください。 例)log.csvというファイルを入力したい場合は「log」と入力してください。"
# file_name = gets.chomp
file_name = "log"

unless File.exist? "#{file_name}.csv"
  puts "#{file_name}.csvは存在しません。ファイル名を確認してください。"
  return
end

logs = []
CSV.foreach("#{file_name}.csv") do |row|
  logs.push row
end

logs = [
  ["20201019133124", "10.20.30.1/16", "-"],
  ["20201019133125", "10.20.30.2/16", "1"],
  ["20201019133134", "192.168.1.1/24", "10"],
  ["20201019133135", "192.168.1.2/24", "5"],
  ["20201019133224", "10.20.30.1/16", "522"],
  ["20201019133225", "10.20.30.2/16", "-"],
  ["20201019133234", "192.168.1.1/24", "8"],
  ["20201019133235", "192.168.1.2/24", "15"],
  ["20201019133324", "10.20.30.1/16", "-"],
  ["20201019133325", "10.20.30.2/16", "2"]
]
# cache = {}
# result = []
# logs.each do |log|
#   time = log[0]
#   address = log[1]
#   response = log[2]
#
#   # cacheにaddressが入っている(クラッシュ)していてクラッシュ
#   # cacheにaddressが入っていないかつ正常
#   next if cache.has_key?(address) && response == TIMEOUT_MESSAGE
#   next if !(cache.has_key?(address) || response == TIMEOUT_MESSAGE)
#
#   # cacheにaddressが入っているかつ正常
#   # cacheにaddressが入っていないかつクラッシュ
#   if(cache.has_key?(address))
#     result.push({"addrss" => address, "from" => cache[address], "to" => time})
#     cache.delete address
#   else
#     cache[address] = time
#   end
# end
#
# cache.each do |address, time|
#   result.push({"address" => address, "from" => time, "to" => "-----"})
# end

# puts result

def test(logs)
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

puts test(logs)

