class Chal47
  class Oracle
    def initialize(private_key)
      @private_key = private_key
      @nlen = Chal47.pad_len_for_key @private_key.n
    end

    def call(ct)
      pt = @private_key.decrypt(ct)
      pt_bin = ("%0#{@nlen*2}x"  % pt).from_hex
      Chal47.somewhat_correct_padding?(pt_bin, @nlen)
    end
  end

  class << self
    def pad_len_for_key(n)
      (n.to_s(2).size + 7)/8
    end

    # How many FFs are mandatory? This code assumes one byte, but maybe it's zero?
    def pad(msg, len)
      msg = msg.b
      ff_len = (len - msg.size - 3)
      raise "Message too long for the key, can't be padded correctly" unless ff_len >= 1
      "\x00\x02".b + "\xFF".b*ff_len + "\x00".b + msg
    end

    def correct_padding?(msg, nlen)
      return false unless msg.size == nlen
      return false unless msg[0,3] == "\x00\x02\xff".b
      (3...nlen).each do |i|
        return true if msg[i] == "\x00".b
        return false unless msg[i] == "\xff".b
      end
      return false
    end

    def somewhat_correct_padding?(msg, nlen)
      return false unless msg.size == nlen
      msg[0,2] == "\x00\x02".b
    end
  end
end
