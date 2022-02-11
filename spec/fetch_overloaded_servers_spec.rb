require "../src/fetch_overloaded_servers"

RSpec.describe "過負荷のサーバーを解析する" do
  context "1回でもタイムアウトしたら故障とみなす" do
    it "test" do
      expect(fetch_overloaded_servers([],1,1)).to eq [1]
    end
  end
  context "2回以上タイムアウトしたら故障とみなす" do
  end
end