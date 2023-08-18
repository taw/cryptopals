describe Chal19 do
  let(:chal) { Chal19.new }
  let(:samples_path) { Pathname("#{__dir__}/data/20.txt") }
  let(:samples) { samples_path.readlines.map{|x| Base64.decode64(x) }}
  let(:ctr) { Chal18.new }
  let(:nonce) { 0 }
  let(:key) { Random.bytes(16) }
  let(:encrypted) { samples.map{|s| ctr.encode(s, key, nonce) } }

  # This is a result of iterative human guessing
  #
  # "spaces everywhere" is a pretty decent model
  # Further right we go, fewer samples we have to work with
  # but with manual process we can guess it

  let(:correct_bytes) { 107  }
  it do
    data = encrypted.map(&:dup)
    chal.transform_for_most_spaces!(data)
    chal.tranform_manual!(data, 20, 0, "H")
    chal.tranform_manual!(data, 20, 1, "a")
    chal.tranform_manual!(data, 54, 19, "u")
    chal.tranform_manual!(data, 54, 20, "t")
    chal.tranform_manual!(data, 54, 21, ",")
    chal.tranform_manual!(data, 5, 50, "y")
    chal.tranform_manual!(data, 5, 62, "e")
    chal.tranform_manual!(data, 5, 70, "o")
    chal.tranform_manual!(data, 1, 74, "u")
    chal.tranform_manual!(data, 2, 80, "o")
    chal.tranform_manual!(data, 32, 85, "c")
    chal.tranform_manual!(data, 32, 86, "e")
    chal.tranform_manual!(data, 46, 88, "t")
    chal.tranform_manual!(data, 11, 91, "c")
    chal.tranform_manual!(data, 11, 93, "s")
    chal.tranform_manual!(data, 11, 94, "t")
    chal.tranform_manual!(data, 2, 95, "k")
    chal.tranform_manual!(data, 12, 96, "n")
    chal.tranform_manual!(data, 26, 98, "v")
    chal.tranform_manual!(data, 26, 99, "e")
    chal.tranform_manual!(data, 41, 101, "l")
    chal.tranform_manual!(data, 21, 103, "a")
    chal.tranform_manual!(data, 21, 104, "c")
    chal.tranform_manual!(data, 21, 105, "e")

    # n=105; data.map.with_index.map{|k,i| [i, k[0...n], k[n..-1]] }.select{|u| u[2]}

    samples.zip(data).each do |pt, d|
      expect(d[0,correct_bytes]).to eq(pt[0,correct_bytes])
    end
  end
end
