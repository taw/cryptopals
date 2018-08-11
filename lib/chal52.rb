class Chal52
  class IteratedHash
    def hexdigest(msg)
      AES.pad(msg).byteslices(16).reduce(initial_state) do |state, chunk|
        reduce(state, chunk)
      end.to_hex
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

    def extend_block_collision(state, *collisions)
      a, b, new_state = find_block_collision(state)
      [new_state, *collisions, [a, b]]
    end
  end

  # 16bit
  class F < IteratedHash
    def initial_state
      "AB"
    end

    def reduce(state, chunk)
      AES.encrypt_block(chunk, state + "\x00"*14)[0, 2]
    end
  end

  # 24bit
  class G < IteratedHash
    def initial_state
      "012"
    end

    def reduce(state, chunk)
      AES.encrypt_block(chunk, state + "\x00"*13)[0, 3]
    end
  end

  # 40bit
  class FG
    def hexdigest(msg)
      F.new.hexdigest(msg) + G.new.hexdigest(msg)
    end
  end
end
