require "csv"
require "set"

Dir[File.expand_path("../src", __FILE__) << "/*.rb"].each do |file|
  require file
end

HEADER = "監視ログファイルを読み込み、"
QUESTIONS = [
  "故障状態のサーバアドレスとそのサーバの故障期間を出力します。",
  "N回以上タイムアウトしたサーバアドレスとそのサーバの故障期間を出力します。",
  "過負荷になっているサーバアドレスを出力します。",
  "故障しているネットワークを出力します。"
].map(&:freeze)

def main
  puts "読み込みたいファイル名を拡張子抜きで入力してEnterを押してください。 例)log.csvというファイルを入力したい場合は「log」と入力してください。"
  file_name = gets.chomp

  unless File.exist? "#{file_name}.csv"
    puts "#{file_name}.csvは存在しません。ファイル名を確認してください。"
    return
  end

  puts "ファイルを確認しました。次に確認したい内容の番号を入力してEnterを押してください"
  QUESTIONS.each.with_index(1) do |question, index|
    puts "#{index}.#{HEADER}#{question}"
  end

  log_reader_factory = LogReaderFactory.new(convert_csv_to_array(file_name))

  question_no = gets.chomp.to_i
  if question_no < 1 || QUESTIONS.size < question_no
    puts "1から#{QUESTIONS.size}の中から入力してください。最初からやり直してください。"
    return
  end

  case question_no
  when 1 then
    log_reader = log_reader_factory.build
    log_reader.display_not_working_servers
  when 2 then
    puts "何回以上連続してタイムアウトしたら故障と見なしましょうか。1以上の整数を入力してEnterを押してください。"
    limit = gets.chomp.to_i
    if limit < 1
      puts "1以上の数値を入力してください。最初からやり直してください。"
      return
    end

    log_reader = log_reader_factory.set_limit(limit).build
    log_reader.display_not_working_servers
  when 3 then
    puts "直近何回の平均時間を算出しましょうか。1以上の整数を入力してEnterを押してください。"
    time = gets.chomp.to_i
    if time < 1
      puts "1以上の数値を入力してください。最初からやり直してください。"
      return
    end

    puts "何ミリ秒以上から過負荷と見なしましょうか。0以上の整数を入力してEnterを押してください。"
    average = gets.chomp.to_i
    if average < 0
      puts "0以上の数値を入力してください。最初からやり直してください。"
      return
    end

    log_reader = log_reader_factory.set_time(time).set_average(average).build
    log_reader.display_overloaded_servers
  when 4 then
    puts "何回以上連続してタイムアウトしたら故障と見なしましょうか。1以上の整数を入力してEnterを押してください。"
    limit = gets.chomp.to_i
    if limit < 1
      puts "1以上の数値を入力してください。最初からやり直してください。"
      return
    end

    log_reader = log_reader_factory.set_limit(limit).build
    log_reader.display_not_working_networks
  end
end

def convert_csv_to_array(file_name)
  array = []
  CSV.foreach("#{file_name}.csv") do |row|
    array.push row
  end
  return array
end

main