describe Chal12 do
  let(:chal) { Chal12.new }

  describe "#detect_block_size" do
    let(:sized_box) do
      proc{|n|
        extra_size = rand(10..100)
        proc{|str|
          unpadded_size = str.size + extra_size
          padded_size = (unpadded_size + (n-1)) / n * n
          padded_size.times.map{ rand(256) }.pack("C*")
        }
      }
    end

    it do
      expect(chal.detect_block_size(chal.box)).to eq(16)
      expect(chal.detect_block_size(sized_box.(12))).to eq(12)
      expect(chal.detect_block_size(sized_box.(33))).to eq(33)
    end
  end

  describe "#is_ecb?" do
    let(:random_box) do
      extra_size = rand(10..100)
      n = 16
      proc{|str|
        unpadded_size = str.size + extra_size
        padded_size = (unpadded_size + (n-1)) / n * n
        padded_size.times.map{ rand(256) }.pack("C*")
      }
    end

    it do
      expect(chal.ecb?(chal.box)).to eq(true)
      expect(chal.ecb?(random_box)).to eq(false)
    end
  end

  describe "#guess_first_char" do
    it do
      expect(chal.guess_first_char(chal.box)).to eq("R")
    end
  end

  describe "#guess_first_block" do
    it do
      expect(chal.guess_first_block(chal.box)).to eq("Rollin' in my 5.")
    end
  end
end
