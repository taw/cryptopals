class Chal55
  class IntrospectiveMD4
    ROTATIONS = [
      3,7,11,19, 3,7,11,19, 3,7,11,19, 3,7,11,19,
      3,5,9,13, 3,5,9,13, 3,5,9,13, 3,5,9,13,
      3,9,11,15, 3,9,11,15, 3,9,11,15, 3,9,11,15,
    ]
    SCHEDULE = [
      0,1,2,3, 4,5,6,7, 8,9,10,11, 12,13,14,15,
      0,4,8,12, 1,5,9,13, 2,6,10,14, 3,7,11,15,
      0,8,4,12, 2,10,6,14, 1,9,5,13, 3,11,7,15,
    ]

    class << self
      def padding(message)
        byte_size = message.bytesize
        extra_zeroes = -(byte_size + 9) % 64
        "\x80".b + "\x00".b * extra_zeroes + [byte_size * 8].pack("Q<")
      end

      def rotate_left(v, s)
        mask = (1 << 32) - 1
        (v << s).&(mask) | (v.&(mask) >> (32 - s))
      end

      def rotate_right(v, s)
        rotate_left(v, 32-s)
      end

      def reduce(state, chunk)
        x = chunk.unpack("V*")
        intermediate_values = []
        mask = (1 << 32) - 1

        a, b, c, d = state
        aa, bb, cc, dd = a, b, c, d

        48.times do |j|
          xi = x[SCHEDULE[j]]
          ri = ROTATIONS[j]
          if j <= 15
            u = b & c | (b ^ mask) & d
            k = 0
          elsif j <= 31
            u = b & c | b & d | c & d
            k = 0x5a827999
          else
            u = b ^ c ^ d
            k = 0x6ed9eba1
          end
          t = rotate_left(a + u + xi + k, ri)
          intermediate_values << t
          a, b, c, d = d, t, b, c
        end

        updated_state = [
          (a + aa) & mask,
          (b + bb) & mask,
          (c + cc) & mask,
          (d + dd) & mask,
        ]
        return [updated_state, intermediate_values]
      end

      def initial_state
        [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476]
      end

      def finalize(state)
        state.pack("V4").unpack("H*")[0]
      end

      def hexdigest(message)
        padded = message.b + padding(message)
        chunks = (0...padded.size).step(64).map{|i| padded[i, 64] }
        state = initial_state
        all_intermediate_values = []
        chunks.each do |chuck|
          state, intermediate_values = reduce(state, chunk)
          all_intermediate_values += intermediate_values
        end
        result = finalize(state)
        [result, all_intermediate_values]
      end

      def diff(message1, message2)
        digest1, intermediate1 = reduce(initial_state, message1)
        digest2, intermediate2 = reduce(initial_state, message2)
        v1 = message1.unpack("V*")
        v2 = message2.unpack("V*")
        {
          digest1: digest1,
          digest2: digest2,
          message_diffs: v1.zip(v2).map{ |u,v| v-u },
          intermediate_diffs: intermediate1.zip(intermediate2).map{ |u,v| v-u },
        }
      end
    end
  end

  # https://fortenf.org/e/crypto/2017/09/10/md4-collisions.html
  CONDITIONS = [
    [[:e, 6]],
    [[:z, 6], [:e, 7], [:e, 10]],
    [[:o, 6], [:o, 7], [:z, 10], [:e, 25]],
    [[:o, 6], [:z, 7], [:z, 10], [:z, 25]],
    [[:o, 7], [:o, 10], [:z, 25], [:e, 13]],
    [[:z, 13], [:e, 18], [:e, 19], [:e, 20], [:e, 21], [:o, 25]],
    [[:e, 12], [:z, 13], [:e, 14], [:z, 18], [:z, 19], [:o, 20], [:z, 21]],
    [[:o, 12], [:o, 13], [:z, 14], [:e, 16], [:z, 18], [:z, 19], [:z, 20], [:z, 21]],
    [[:o, 12], [:o, 13], [:o, 14], [:z, 16], [:z, 18], [:z, 19], [:z, 20], [:e, 22], [:o, 21], [:e, 25]],
    [[:o, 12], [:o, 13], [:o, 14], [:z, 16], [:z, 19], [:o, 20], [:o, 21], [:z, 22], [:o, 25], [:e, 29]],
    [[:o, 16], [:z, 19], [:z, 20], [:z, 21], [:z, 22], [:z, 25], [:o, 29], [:e, 31]],
    [[:z, 19], [:o, 20], [:o, 21], [:e, 22], [:o, 25], [:z, 29], [:z, 31]],
    [[:z, 22], [:z, 25], [:e, 26], [:e, 28], [:o, 29], [:z, 31]],
    [[:z, 22], [:z, 25], [:o, 26], [:o, 28], [:z, 29], [:o, 31]],
    [[:e, 18], [:o, 22], [:o, 25], [:z, 26], [:z, 28], [:z, 29]],
    [[:z, 18], [:e, 25], [:o, 26], [:o, 28], [:z, 29], [:e, 31]],
  ]

  def self.verify_round1_conditions(message)
    initial_state = Chal55::IntrospectiveMD4.initial_state
    digest, intermediate = Chal55::IntrospectiveMD4.reduce(initial_state, message)
    fails = 0
    CONDITIONS.each_with_index do |conds, index|
      if index == 0
        # not even 100% sure actually
        prev = initial_state[1]
      else
        prev = intermediate[index-1]
      end
      current = intermediate[index]
      conds.each do |type, bit_ofs|
        ok = case type
        when :z
          current[bit_ofs] == 0
        when :o
          current[bit_ofs] == 1
        when :e
          current[bit_ofs] == prev[bit_ofs]
        end
        p [index, ok, type, current[bit_ofs], prev[bit_ofs]]
        fails += 1 unless ok
      end
    end
    fails == 0
  end

  def self.generate_candidate_pair
    v1 = 16.times.map{ rand(2**32) }

    # Round 1
    CONDITIONS.each_with_index do |conds, index|
    end

    # Generate pair with proper difference
    v2 = [*v1]
    v2[1]  = v2[1].set_bit(31)
    v1[1]  = v2[1].clear_bit(31)
    v1[2]  = v1[2].clear_bit(31).set_bit(28)
    v2[2]  = v2[2].set_bit(31).clear_bit(28)
    v1[12] = v1[12].set_bit(16)
    v2[12] = v2[12].clear_bit(16)
    [
      v1.pack("V*"),
      v2.pack("V*"),
    ]
  end
end
