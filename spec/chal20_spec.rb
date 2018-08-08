describe Chal20 do
  let(:chal) { Chal20.new }
  let(:samples_path) { Pathname("#{__dir__}/data/20.txt") }
  let(:samples) { samples_path.readlines.map{|x| Base64.decode64(x) }}
  let(:ctr) { Chal18.new }
  let(:nonce) { 0 }
  let(:key) { Random::DEFAULT.bytes(16) }
  let(:encrypted) { samples.map{|s| ctr.encode(s, key, nonce) } }

  # Can't get them all this way as sample sizes get tiny
  # Beyond the cutoff there's just 5 or fewer samples (and still some bytes are OK)
  let(:correct_bytes) { 101 }
  it do
    decrypted = chal.decrypt(encrypted)

    samples.zip(decrypted).each do |pt, d|
      expect(d[0,correct_bytes]).to eq(pt[0,correct_bytes])
      # if d.size > correct_bytes
      #   p [d[0, correct_bytes], d[correct_bytes..-1], pt[correct_bytes..-1]]
      # end
    end
  end
end
