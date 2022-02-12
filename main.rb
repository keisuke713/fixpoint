require "csv"
Dir[File.expand_path("../src", __FILE__) << "/*.rb"].each do |file|
  require file
end

HEADER = "監視ログファイルを読み込み、"
QUESTIONS = [
  "故障状態のサーバアドレスとそのサーバの故障期間を出力します。",
  "N回以上タイムアウトしたサーバアドレスとそのサーバの故障期間を出力します。",
  "過負荷になっているサーバアドレスを出力します。",
  "故障しているサブネットを出力します。"
].map(&:freeze)
START = "=============== ログの読み込みを始めます。 ================="
FINISH = "=============== ログの読み込みを終了します。 ================="

def main
  puts "読み込みたいファイル名を拡張子抜きで入力してEnterを押してください。 例)log.csvというファイルを入力したい場合は「log」と入力してください。"
  file_name = gets.chomp
  # file_name = "log"

  unless File.exist? "#{file_name}.csv"
    puts "#{file_name}.csvは存在しません。ファイル名を確認してください。"
    return
  end

  puts "ファイルを確認しました。次に確認したい内容の番号を入力してEnterを押してください"
  QUESTIONS.each.with_index(1) do |question, index|
    puts "#{index}.#{HEADER}#{question}"
  end

  question_no = gets.chomp.to_i
  if question_no < 1 || QUESTIONS.size < question_no
    puts "1から#{QUESTIONS.size}の中から入力してください。最初からやり直してください。"
    return
  end

  case question_no
  when 1 then
    puts START
    logs = convert_csv_to_array(file_name)
    fetch_not_working_servers(logs, 1).each do |result|
      puts "------------------"
      puts "サーバーアドレス: #{result["address"]}"
      puts "タイムアウト時刻: #{result["from"]}"
      puts "復旧時刻: #{result["to"]}"
    end
    puts FINISH
  when 2 then
    puts "何回以上連続してタイムアウトしたら故障と見なしましょうか。1以上の整数を入力してEnterを押してください。"
    times = gets.chomp.to_i
    if times < 1
      puts "1以上の数値を入力してください。最初からやり直してください。"
      return
    end

    puts START
    logs = convert_csv_to_array(file_name)
    fetch_not_working_servers(logs, times).each do |result|
      puts "------------------"
      puts "サーバーアドレス: #{result["address"]}"
      puts "タイムアウト時刻: #{result["from"]}"
      puts "復旧時刻: #{result["to"]}"
    end
    puts FINISH
  when 3 then
    puts "直近何回の平均時間を算出しましょうか。1以上の整数を入力してEnterを押してください。"
    times = gets.chomp.to_i
    if times < 1
      puts "1以上の数値を入力してください。最初からやり直してください。"
      return
    end

    puts "何ミリ秒以上から過負荷と見なしましょうか。0以上の整数を入力してEnterを押してください。"
    average = gets.chomp.to_i
    if average < 0
      puts "0以上の数値を入力してください。最初からやり直してください。"
      return
    end

    puts START
    logs = convert_csv_to_array(file_name)
    fetch_overloaded_servers(logs, times, average).each do |result|
      puts "------------------"
      puts "サーバーアドレス: #{result["address"]}"
      puts "開始時刻: #{result["from"]}"
      puts "終了時刻: #{result["to"]}"
    end
    puts FINISH
  when 4 then
    puts "何回以上連続してタイムアウトしたら故障と見なしましょうか。1以上の整数を入力してEnterを押してください。"
    times = gets.chomp.to_i
    if times < 1
      puts "1以上の数値を入力してください。最初からやり直してください。"
      return
    end

    puts START
    logs = convert_csv_to_array(file_name)
    fetch_not_working_networks(logs, times).each do |result|
      puts "------------------"
      puts "ネットワーク: #{result["network"]}"
      puts "タイムアウト時刻: #{result["from"]}"
      puts "終了時刻: #{result["to"]}"
    end
    puts FINISH
  end
end

# question1(logs).each do |result|
#   puts "------------------"
#   puts "サーバーアドレス: #{result["address"]}"
#   puts "タイムアウト時刻: #{result["from"]}"
#   puts "復旧時刻: #{result["to"]}"
# end

def convert_csv_to_array(file_name)
  array = []
  CSV.foreach("#{file_name}.csv") do |row|
    array.push row
  end
  # mock
  # [
  #   ["20201019133124", "10.20.30.1/16", "-"],
  #   ["20201019133125", "10.20.30.2/16", "1"],
  #   ["20201019133134", "192.168.1.1/24", "10"],
  #   ["20201019133135", "192.168.1.2/24", "5"],
  #   ["20201019133224", "10.20.30.1/16", "522"],
  #   ["20201019133225", "10.20.30.2/16", "-"],
  #   ["20201019133234", "192.168.1.1/24", "8"],
  #   ["20201019133235", "192.168.1.2/24", "15"],
  #   ["20201019133324", "10.20.30.1/16", "-"],
  #   ["20201019133325", "10.20.30.2/16", "2"]
  # ]
  return array
end

main
