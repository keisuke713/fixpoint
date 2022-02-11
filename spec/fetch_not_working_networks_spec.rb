require "../src/fetch_not_working_networks"

RSpec.describe "過負荷のサーバーを解析する" do
  it "" do
    expect(fetch_not_working_networks([],1)).to eq 3
  end
end