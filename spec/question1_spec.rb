require "../src/fetch_broken_addresses"

RSpec.describe "故障しているサーバアドレスとその期間を解析する" do
  context "1回でもタイムアウトしたら故障とみなす" do
    TIMES = 1
    it "一つのサーバアドレスが最初からタイムアウトする" do
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
      expect(fetch_broken_addresses(input, TIMES)).to eq output
    end
    it "一つのサーバアドレスが途中からタイムアウトする" do
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
      expect(fetch_broken_addresses(input, TIMES)).to eq output
    end
    it "一つのサーバアドレスがタイムアウトしたまま終了する" do
      input = [
        ["20201019133120", "10.20.30.1/16", "1"],
        ["20201019133124", "10.20.30.1/16", "-"],
        ["20201019133134", "192.168.1.1/24", "10"],
        ["20201019133135", "192.168.1.2/24", "5"],
        ["20201019133234", "192.168.1.1/24", "8"]
      ]
      output = [
        {"address" => "10.20.30.1/16", "from" => "20201019133124", "to" => "-----"}
      ]
      expect(fetch_broken_addresses(input, TIMES)).to eq output
    end
    it "一つのサーバアドレスが長期間タイムアウトを挟み復旧する" do
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
      expect(fetch_broken_addresses(input, TIMES)).to eq output
    end
    it "一つのサーバアドレスが複数回タイムアウト->復旧を繰り返す" do
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
      expect(fetch_broken_addresses(input, TIMES)).to eq output
    end
    it "複数サーバアドレスがタイムアウトする" do
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
      expect(fetch_broken_addresses(input, TIMES)).to eq output
    end
  end
end