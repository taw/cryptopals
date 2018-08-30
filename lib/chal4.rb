class Chal4
  def initialize(samples)
    @samples = samples
  end

  def xor(str, key)
    str.bytes.map{|c| (c ^ key).chr}.join
  end

  def call
    @samples.flat_map do |sample|
      (0..255).map do |key|
        decoded = xor(sample, key)
        score = English.score(decoded)
        [score, key, decoded, sample]
      end
    end.sort[0][2..3]
  end
end
