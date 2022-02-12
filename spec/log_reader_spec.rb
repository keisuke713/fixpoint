require "../src/response_array"
require "../src/server"
require "../src/log"
require "../src/log_reader"
require "../src/log_reader_factory"

RSpec.describe "" do
  context "N回以上タイムアウトしたら故障とみなす" do
    it "一つのサーバが最初からタイムアウトする" do
      input = [
        ["20201019133124", "10.20.30.1/16", "-"],
        ["20201019133125", "10.20.30.2/16", "1"],
        ["20201019133134", "192.168.1.1/24", "10"],
        ["20201019133135", "192.168.1.2/24", "5"],
        ["20201019133224", "10.20.30.1/16", "522"],
        ["20201019133234", "192.168.1.1/24", "8"]
      ]
      output = [
        {"address" => "10.20.30.1/16", "from" => "20201019133124", "to" => "20201019133224"}
      ]
      log_reader = LogReaderFactory.new(input).build
      expect(log_reader.not_working_servers).to eq output
    end
    it "一つのサーバが途中からタイムアウトする" do
      input = [
        ["20201019132125", "10.20.30.1/16", "1"],
        ["20201019133124", "10.20.30.1/16", "-"],
        ["20201019133134", "192.168.1.1/24", "10"],
        ["20201019133135", "192.168.1.2/24", "5"],
        ["20201019133224", "10.20.30.1/16", "522"],
        ["20201019133234", "192.168.1.1/24", "8"]
      ]
      output = [
        {"address" => "10.20.30.1/16", "from" => "20201019133124", "to" => "20201019133224"}
      ]
      log_reader = LogReaderFactory.new(input).build
      expect(log_reader.not_working_servers).to eq output
    end
    it "一つのサーバがタイムアウトしたまま終了する" do
      input = [
        ["20201019133120", "10.20.30.1/16", "1"],
        ["20201019133124", "10.20.30.1/16", "-"],
        ["20201019133134", "192.168.1.1/24", "10"],
        ["20201019133135", "192.168.1.2/24", "5"],
        ["20201019133234", "192.168.1.1/24", "8"]
      ]
      output = [
        {"address" => "10.20.30.1/16", "from" => "20201019133124", "to" => LogReader::NOT_FIX_MESSAGE}
      ]
      log_reader = LogReaderFactory.new(input).build
      expect(log_reader.not_working_servers).to eq output
    end
    it "一つのサーバが長期間タイムアウトを挟み復旧する" do
      input = [
        ["20201019133124", "10.20.30.1/16", "-"],
        ["20201019133125", "10.20.30.2/16", "1"],
        ["20201019133134", "10.20.30.1/16", "-"],
        ["20201019133135", "192.168.1.2/24", "5"],
        ["20201019133229", "10.20.30.1/16", "522"],
        ["20201019133234", "192.168.1.1/24", "8"]
      ]
      output = [
        {"address" => "10.20.30.1/16", "from" => "20201019133124", "to" => "20201019133229"}
      ]
      log_reader = LogReaderFactory.new(input).build
      expect(log_reader.not_working_servers).to eq output
    end
    it "一つのサーバが複数回タイムアウト->復旧を繰り返す" do
      input = [
        ["20201019133124", "10.20.30.1/16", "-"],
        ["20201019133125", "10.20.30.2/16", "1"],
        ["20201019133134", "10.20.30.1/16", "-"],
        ["20201019133135", "192.168.1.2/24", "5"],
        ["20201019133229", "10.20.30.1/16", "522"],
        ["20201019133234", "192.168.1.1/24", "8"],
        ["20201019233124", "10.20.30.2/16", "9"],
        ["20201019233125", "10.20.30.1/16", "1"],
        ["20201019233134", "10.20.30.1/16", "-"],
        ["20201019233135", "192.168.1.2/24", "5"],
        ["20201019233229", "10.20.30.1/16", "522"],
        ["20201019233234", "192.168.1.1/24", "8"]
      ]
      output = [
        {"address" => "10.20.30.1/16", "from" => "20201019133124", "to" => "20201019133229"},
        {"address" => "10.20.30.1/16", "from" => "20201019233134", "to" => "20201019233229"}
      ]
      log_reader = LogReaderFactory.new(input).build
      expect(log_reader.not_working_servers).to eq output
    end
    it "複数サーバがタイムアウトする" do
      input = [
        ["20201019133124", "10.20.30.1/16", "-"],
        ["20201019133125", "10.20.30.2/16", "1"],
        ["20201019133134", "10.20.30.1/16", "-"],
        ["20201019133135", "192.168.1.2/24", "-"],
        ["20201019133229", "10.20.30.1/16", "522"],
        ["20201019133234", "192.168.1.1/24", "8"],
        ["20201019233124", "192.168.1.2/24", "1"],
        ["20201019233125", "10.20.30.1/16", "1"],
        ["20201019233134", "10.20.30.1/16", "-"],
        ["20201019233135", "192.168.1.2/24", "5"],
        ["20201019233229", "10.20.30.1/16", "522"],
        ["20201019233234", "192.168.1.1/24", "8"]
      ]
      output = [
        {"address" => "10.20.30.1/16", "from" => "20201019133124", "to" => "20201019133229"},
        {"address" => "192.168.1.2/24", "from" => "20201019133135", "to" => "20201019233124"},
        {"address" => "10.20.30.1/16", "from" => "20201019233134", "to" => "20201019233229"}
      ]
      log_reader = LogReaderFactory.new(input).build
      expect(log_reader.not_working_servers).to eq output
    end
    it "2回連続でタイムアウトしない" do
      input = [
        ["20201019133124", "10.20.30.1/16", "-"],
        ["20201019133125", "10.20.30.2/16", "1"],
        ["20201019133134", "10.20.30.1/16", "10"],
        ["20201019133135", "192.168.1.2/24", "-"],
        ["20201019133224", "10.20.30.1/16", "-"],
        ["20201019133234", "192.168.1.1/24", "8"]
      ]
      output = []
      log_reader = LogReaderFactory.new(input).set_limit(2).build
      expect(log_reader.not_working_servers).to eq output
    end
    it "故障した後すぐに復旧する" do
      input = [
        ["20201019133124", "10.20.30.1/16", "-"],
        ["20201019133125", "10.20.30.2/16", "1"],
        ["20201019133134", "10.20.30.1/16", "-"],
        ["20201019133135", "192.168.1.2/24", "5"],
        ["20201019133224", "10.20.30.1/16", "1"],
        ["20201019133234", "192.168.1.1/24", "8"]
      ]
      output = [
        {"address" => "10.20.30.1/16", "from" => "20201019133134", "to" => "20201019133224"}
      ]
      log_reader = LogReaderFactory.new(input).set_limit(2).build
      expect(log_reader.not_working_servers).to eq output
    end
    it "故障して最後まで復旧しない" do
      input = [
        ["20201019133124", "10.20.30.1/16", "-"],
        ["20201019133125", "10.20.30.2/16", "1"],
        ["20201019133134", "10.20.30.1/16", "-"],
        ["20201019133135", "192.168.1.2/24", "-"],
        ["20201019133224", "10.20.30.1/16", "-"],
        ["20201019133234", "192.168.1.1/24", "8"]
      ]
      output = [
        {"address" => "10.20.30.1/16", "from" => "20201019133134", "to" => LogReader::NOT_FIX_MESSAGE}
      ]
      log_reader = LogReaderFactory.new(input).set_limit(2).build
      expect(log_reader.not_working_servers).to eq output
    end
    it "一つのサーバが複数回故障" do
      input = [
        ["20201019133124", "10.20.30.1/16", "-"],
        ["20201019133125", "10.20.30.2/16", "1"],
        ["20201019133134", "10.20.30.1/16", "-"],
        ["20201019133135", "192.168.1.2/24", "5"],
        ["20201019133224", "10.20.30.1/16", "100"],
        ["20201019133234", "192.168.1.1/24", "8"],
        ["20201019133324", "10.20.30.1/16", "-"],
        ["20201019133325", "10.20.30.2/16", "1"],
        ["20201019133334", "10.20.30.1/16", "-"],
        ["20201019133335", "192.168.1.2/24", "5"],
        ["20201019133324", "10.20.30.1/16", "-"],
        ["20201019133434", "192.168.1.1/24", "8"],
        ["20201019133444", "10.20.30.1/16", "-"]
      ]
      output = [
        {"address" => "10.20.30.1/16", "from" => "20201019133134", "to" => "20201019133224"},
        {"address" => "10.20.30.1/16", "from" => "20201019133334", "to" => LogReader::NOT_FIX_MESSAGE},
      ]
      log_reader = LogReaderFactory.new(input).set_limit(2).build
      expect(log_reader.not_working_servers).to eq output
    end
    it "複数サーバが故障" do
      input = [
        ["20201019133124", "10.20.30.1/16", "-"],
        ["20201019133125", "10.20.30.2/16", "1"],
        ["20201019133134", "10.20.30.1/16", "-"],
        ["20201019133135", "192.168.1.2/24", "-"],
        ["20201019133224", "10.20.30.1/16", "100"],
        ["20201019133234", "192.168.1.1/24", "8"],
        ["20201019133324", "10.20.30.1/16", "-"],
        ["20201019133325", "10.20.30.2/16", "-"],
        ["20201019133326", "10.20.30.2/16", "-"],
        ["20201019133334", "10.20.30.1/16", "-"],
        ["20201019133335", "192.168.1.2/24", "-"],
        ["20201019133324", "10.20.30.1/16", "-"],
        ["20201019133434", "192.168.1.1/24", "8"],
        ["20201019133444", "10.20.30.1/16", "-"],
        ["20201019133526", "10.20.30.2/16", "1"]
      ]
      output = [
        {"address" => "10.20.30.1/16", "from" => "20201019133134", "to" => "20201019133224"},
        {"address" => "10.20.30.2/16", "from" => "20201019133326", "to" => "20201019133526"},
        {"address" => "10.20.30.1/16", "from" => "20201019133334", "to" => LogReader::NOT_FIX_MESSAGE},
        {"address" => "192.168.1.2/24", "from" => "20201019133335", "to" => LogReader::NOT_FIX_MESSAGE},
      ]
      log_reader = LogReaderFactory.new(input).set_limit(2).build
      expect(log_reader.not_working_servers).to eq output
    end
  end
  context "直近m回の平均がtを超えたら過負荷と見なす" do
    it "指定の回数ログが出力されなかった場合" do
      input = [
        ["20201019133124", "10.20.30.1/16", "-"],
        ["20201019133134", "192.168.1.1/24", "10"],
        ["20201019133224", "10.20.30.1/16", "522"],
        ["20201019133234", "192.168.1.1/24", "8"],
        ["20201019133254", "10.20.30.1/16", "10"],
      ]
      output = []
      log_reader = LogReaderFactory.new(input).build
      expect(log_reader.overloaded_servers(3,2)).to eq output
    end
    it "平均値が基準を満たさない場合" do
      input = [
        ["20201019133124", "10.20.30.1/16", "-"],
        ["20201019133125", "10.20.30.1/16", "3"],
        ["20201019133134", "10.20.30.1/16", "6"],
        ["20201019133135", "10.20.30.1/16", "3"],
      ]
      output = []
      log_reader = LogReaderFactory.new(input).build
      expect(log_reader.overloaded_servers(2,5)).to eq output
    end
    it "一度平均値が基準値を超える" do
      input = [
        ["20201019133124", "10.20.30.1/16", "6"],
        ["20201019133125", "10.20.30.1/16", "3"],
        ["20201019133134", "10.20.30.1/16", "7"],
        ["20201019133135", "10.20.30.1/16", "2"],
      ]
      output = [
        {"address" => "10.20.30.1/16", "from" => "20201019133125", "to" => "20201019133134"}
      ]
      log_reader = LogReaderFactory.new(input).build
      expect(log_reader.overloaded_servers(2,5)).to eq output
    end
    it "複数回平均値が基準値を超える" do
      input = [
        ["20201019133124", "10.20.30.1/16", "6"],
        ["20201019133125", "10.20.30.1/16", "4"],
        ["20201019133134", "10.20.30.1/16", "5"],
        ["20201019133135", "10.20.30.1/16", "5"],
      ]
      output = [
        {"address" => "10.20.30.1/16", "from" => "20201019133124", "to" => "20201019133125"},
        {"address" => "10.20.30.1/16", "from" => "20201019133134", "to" => "20201019133135"}
      ]
      log_reader = LogReaderFactory.new(input).build
      expect(log_reader.overloaded_servers(2,5)).to eq output
    end
    it "複数サーバの平均値が基準値を超える" do
      input = [
        ["20201019133124", "10.20.30.1/16", "7"],
        ["20201019133125", "10.20.30.2/16", "4"],
        ["20201019133134", "10.20.30.1/16", "8"],
        ["20201019133135", "10.20.30.1/16", "1"],
        ["20201019133136", "10.20.30.2/16", "5"],
        ["20201019133137", "10.20.30.1/16", "2"],
        ["20201019133138", "10.20.30.2/16", "2"],
        ["20201019133139", "10.20.30.2/16", "8"],
        ["20201019133140", "10.20.30.1/16", "12"]
      ]
      output = [
        {"address" => "10.20.30.1/16", "from" => "20201019133124", "to" => "20201019133135"},
        {"address" => "10.20.30.2/16", "from" => "20201019133136", "to" => "20201019133139"},
        {"address" => "10.20.30.1/16", "from" => "20201019133135", "to" => "20201019133140"}
      ]
      log_reader = LogReaderFactory.new(input).build
      expect(log_reader.overloaded_servers(3,5)).to eq output
    end
  end
  context "同一ネットワーク内の全てのサーバが故障したらネットワーク自体の故障と見なす" do
    it "同じネットワーク内の全てのサーバが同期間に故障をしていない" do
      input = [
        ["20201019133124", "192.168.1.1/24", "30"],
        ["20201019133125", "192.168.1.2/24", "-"],
        ["20201019133134", "192.168.1.3/24", "-"],
        ["20201019133135", "192.168.1.1/24", "5"],
        ["20201019133224", "192.168.1.2/24", "522"],
        ["20201019133234", "192.168.1.1/24", "-"]
      ]
      output = []
      log_reader = LogReaderFactory.new(input).build
      expect(log_reader.not_working_networks(1)).to eq output
    end
    it "一定期間同じネットワーク内の全てのサーバが故障する" do
      input = [
        ["20201019133124", "192.168.1.1/24", "30"],
        ["20201019133125", "192.168.1.2/24", "-"],
        ["20201019133134", "192.168.1.3/24", "-"],
        ["20201019133135", "192.168.1.1/24", "-"],
        ["20201019133224", "192.168.1.1/24", "522"],
        ["20201019133234", "192.168.1.2/24", "-"]
      ]
      output = [
        {"network" => "192.168.1", "from" => "20201019133135", "to" => "20201019133224"}
      ]
      log_reader = LogReaderFactory.new(input).build
      expect(log_reader.not_working_networks(1)).to eq output
    end
    it "途中から最後まで同じネットワーク内の全てのサーバが故障する" do
      input = [
        ["20201019133124", "192.168.1.1/24", "30"],
        ["20201019133125", "192.168.1.2/24", "-"],
        ["20201019133133", "192.168.1.3/24", "-"],
        ["20201019133134", "192.168.1.2/24", "-"],
        ["20201019133135", "192.168.1.1/24", "3"],
        ["20201019133224", "192.168.1.1/24", "-"],
        ["20201019133234", "192.168.1.2/24", "-"]
      ]
      output = [
        {"network" => "192.168.1", "from" => "20201019133224", "to" => "-----"}
      ]
      log_reader = LogReaderFactory.new(input).build
      expect(log_reader.not_working_networks(1)).to eq output
    end
    it "同じネットワーク内の全てのサーバが複数回同時に故障する" do
      input = [
        ["20201019133124", "192.168.1.1/24", "-"],
        ["20201019133125", "192.168.1.2/24", "-"],
        ["20201019133133", "192.168.1.3/24", "1"],
        ["20201019133134", "192.168.1.1/24", "-"],
        ["20201019133135", "192.168.1.3/24", "-"],
        ["20201019133224", "192.168.1.1/24", "1"],
        ["20201019133234", "192.168.1.2/24", "-"],
        ["20201019133235", "192.168.1.3/24", "-"],
        ["20201019133237", "192.168.1.1/24", "-"]
      ]
      output = [
        {"network" => "192.168.1", "from" => "20201019133135", "to" => "20201019133224"},
        {"network" => "192.168.1", "from" => "20201019133237", "to" => "-----"}
      ]
      log_reader = LogReaderFactory.new(input).build
      expect(log_reader.not_working_networks(1)).to eq output
    end
    it "同じネットワーク内の全てのサーバが一定期間の間に全てN回タイムアウトする" do
      input = [
        ["20201019133124", "192.168.1.1/24", "-"],
        ["20201019133125", "192.168.1.2/24", "-"],
        ["20201019133133", "192.168.1.3/24", "1"],
        ["20201019133134", "192.168.1.1/24", "-"],
        ["20201019133135", "192.168.1.3/24", "-"],
        ["20201019133224", "192.168.1.1/24", "-"],
        ["20201019133234", "192.168.1.2/24", "-"],
        ["20201019133235", "192.168.1.3/24", "-"],
        ["20201019133237", "192.168.1.1/24", "-"]
      ]
      output = [
        {"from"=>"20201019133235", "network"=>"192.168.1", "to"=>"-----"}
      ]
      log_reader = LogReaderFactory.new(input).build
      expect(log_reader.not_working_networks(2)).to eq output
    end
    it "同じネットワーク内の全てのサーバが同期間に故障をしていない" do
      input = [
        ["20201019133124", "192.168.1.1/24", "30"],
        ["20201019133125", "192.168.1.2/24", "-"],
        ["20201019133126", "10.20.30.2/16", "-"],
        ["20201019133134", "192.168.1.3/24", "-"],
        ["20201019133135", "192.168.1.1/24", "5"],
        ["20201019133136", "10.20.30.1/16", "1"],
        ["20201019133224", "192.168.1.2/24", "522"],
        ["20201019133225", "10.20.30.2/16", "1"],
        ["20201019133234", "192.168.1.1/24", "-"]
      ]
      output = []
      log_reader = LogReaderFactory.new(input).build
      expect(log_reader.not_working_networks(1)).to eq output
    end
    it "ネットワーク192.168.1内の全てのサーバがある期間で全て故障する" do
      input = [
        ["20201019133124", "192.168.1.1/24", "-"],
        ["20201019133125", "192.168.1.2/24", "-"],
        ["20201019133126", "10.20.30.2/16", "-"],
        ["20201019133134", "192.168.1.3/24", "-"],
        ["20201019133135", "192.168.1.1/24", "-"],
        ["20201019133136", "10.20.30.1/16", "-"],
        ["20201019133224", "192.168.1.2/24", "-"],
        ["20201019133225", "10.20.30.2/16", "-"],
        ["20201019133234", "192.168.1.1/24", "-"],
        ["20201019133244", "192.168.1.3/24", "-"],
        ["20201019133245", "10.20.30.2/16", "-"]
      ]
      output = [
        {"network" => "192.168.1", "from" => "20201019133244", "to" => "-----"}
      ]
      log_reader = LogReaderFactory.new(input).build
      expect(log_reader.not_working_networks(2)).to eq output
    end
    it "ネットワーク192.168.1と10.20内の全てのサーバがある期間で全て故障する" do
      input = [
        ["20201019133124", "192.168.1.1/24", "-"],
        ["20201019133125", "192.168.1.2/24", "-"],
        ["20201019133126", "10.20.30.2/16", "-"],
        ["20201019133134", "192.168.1.3/24", "-"],
        ["20201019133135", "192.168.1.1/24", "-"],
        ["20201019133136", "10.20.30.1/16", "-"],
        ["20201019133224", "192.168.1.2/24", "-"],
        ["20201019133225", "10.20.30.2/16", "-"],
        ["20201019133234", "192.168.1.1/24", "-"],
        ["20201019133244", "192.168.1.3/24", "-"],
        ["20201019133245", "10.20.30.1/16", "-"],
        ["20201019133246", "10.20.30.1/16", "100"]
      ]
      output = [
        {"network" => "10.20", "from" => "20201019133245", "to" => "20201019133246"},
        {"network" => "192.168.1", "from" => "20201019133244", "to" => "-----"}
      ]
      log_reader = LogReaderFactory.new(input).build
      expect(log_reader.not_working_networks(2)).to eq output
    end

  end
end