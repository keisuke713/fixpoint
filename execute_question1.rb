require "csv"

puts "読み込みたいファイル名を拡張子抜きで入力してください。 例)log.csvというファイルを入力したい場合は「log」と入力してください。"
file_name = gets.chomp
puts File.exist? "#{file_name}.csv"