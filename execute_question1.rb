require "csv"

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

