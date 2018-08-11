describe Chal53 do
  let(:f) { Chal53::F.new }
  let(:chal) { Chal53.new }
  let(:target_message) {
    (0...1024).map {|i| "Hello %09d\n" % i }.join
  }

  it do
    hacked = chal.hack(target_message)
    expect(hacked).to_not eq(target_message)
    expect(f.hexdigest(hacked)).to eq(f.hexdigest(target_message))
  end
end
