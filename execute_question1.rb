require "csv"

puts "読み込みたいファイル名を拡張子抜きで入力してください。 例)log.csvというファイルを入力したい場合は「log」と入力してください。"
# file_name = gets.chomp
file_name = "log"

unless File.exist? "#{file_name}.csv"
  puts "#{file_name}.csvは存在しません。ファイル名を確認してください。"
  return
end
# => ["Ruby", "1995"]
#    ["Rust", "2010"]

# ファイルから一度に
# p CSV.read("#{file_name}.csv")