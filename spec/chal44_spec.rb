describe Chal44 do
  let(:y) {
    %W[
    2d026f4bf30195ede3a088da85e398ef869611d0f68f07
    13d51c9c1a3a26c95105d915e2d8cdf26d056b86b8a7b8
    5519b1c23cc3ecdc6062650462e3063bd179c2a6581519
    f674a61f1d89a1fff27171ebc1b93d4dc57bceb7ae2430
    f98a6a4d83d8279ee65d71c1203d2c96d65ebbf7cce9d3
    2971c3de5084cce04a2e147821
    ].join.to_i(16)
  }
  let(:public_key) {
    DSA::PublicKey.new(DSA::Standard, y)
  }
  let(:samples_path) { Pathname("#{__dir__}/data/44.txt") }
  let(:samples) do
    samples_path.readlines.map(&:chomp).each_slice(4).map do |lines|
      msg = lines[0][/\Amsg: \K.*\z/] or raise "Parse error"
      s = lines[1][/\As: \K.*\z/] or raise "Parse error"
      r = lines[2][/\Ar: \K.*\z/] or raise "Parse error"
      m = lines[3][/\Am: \K.*\z/] or raise "Parse error"
      raise "Mismatching hash" unless DSA.hash(msg) == m.to_i(16)
      DSA::Signature.new(public_key, msg, r.to_i, s.to_i)
    end
  end

  let(:private_key_sha1) { "ca8f6f7c66fa362d40760d135b763eb8527d3d52" }

  it do
    samples
  end
end
