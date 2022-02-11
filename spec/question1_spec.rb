require "../src/question1"

RSpec.describe do
  it "4" do
    expect(add(1,3)).to eq 4
  end
  it "" do
    expect(question1([])).to eq [1]
  end
end