class Chal52
  class IteratedHash
    # SHA1 style padding except with 128bit blocks and 32bit size in bytes
    # (it doesn't make it easier than full SHA1 padding would)
    def pad_message(message)
      extra_zeroes = -(message.size + 5) % 16
      message.b + "\x80".b + "\x00".b * extra_zeroes + [message.size].pack("V")
    end

    def unpadded_hexdigest(msg)
      msg.byteslices(16).reduce(initial_state) do |state, chunk|
        reduce(state, chunk)
      end.to_hex
    end

    def hexdigest(msg)
      unpadded_hexdigest pad_message(msg)
    end

    def find_block_collision(state)
      hashes = {}
      i = 0
      while true
        chunk = "%016d" % i
        h = reduce(state, chunk)
        if hashes[h]
          return [hashes[h], chunk, h]
        end
        hashes[h] = chunk
        i += 1
      end
    end

    def extend_block_collision(state, collisions)
      a, b, new_state = find_block_collision(state)
      [new_state, collisions.flat_map{|msg| [msg+a, msg+b]}]
    end
  end

  # 24bit
  class F < IteratedHash
    def initial_state
      "ABC"
    end

    def reduce(state, chunk)
      AES.encrypt_block(chunk, state + "\x00"*13)[0, 3]
    end
  end

  # 32bit
  class G < IteratedHash
    def initial_state
      "0124"
    end

    def reduce(state, chunk)
      AES.encrypt_block(chunk, state + "\x00"*12)[0, 4]
    end
  end

  # 56bit
  class FG
    def initialize
      @f = F.new
      @g = G.new
    end

    def hexdigest(msg)
      @f.hexdigest(msg) + @g.hexdigest(msg)
    end

    def find_collision
      state = @f.initial_state
      f_collisions = [""]
      # Too unlikely to get double collission in fewer blocks so just fast forward
      16.times do
        state, f_collisions = @f.extend_block_collision(state, f_collisions)
      end
      while true
        hashes = {}
        f_collisions.each do |msg|
          h = @g.hexdigest(msg)
          if hashes[h]
            return [hashes[h], msg]
          end
          hashes[h] = msg
        end
        # Wasn't enough? Try some more
        state, f_collisions = @f.extend_block_collision(state, f_collisions)
      end
    end
  end
end
