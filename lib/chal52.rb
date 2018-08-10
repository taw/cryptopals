class Chal52
  # 16bit
  class F
    def initial_state
      "ABCD"
    end

    def reduce(state, chunk)
      AES.encrypt_block(chunk, state + "\x00"*12)[0, 4]
    end

    def hexdigest(msg)
      AES.pad(msg).byteslices(16).reduce(initial_state) do |state, chunk|
        reduce(state, chunk)
      end.to_hex
    end
  end

  # 24bit
  class G
    def initial_state
      "012345"
    end

    def reduce(state, chunk)
      AES.encrypt_block(chunk, state + "\x00"*10)[0, 6]
    end

    def finalize(state)
      state.to_hex
    end

    def hexdigest(msg)
      AES.pad(msg).byteslices(16).reduce(initial_state) do |state, chunk|
        reduce(state, chunk)
      end.to_hex
    end
  end

  # 40bit
  class FG
    def hexdigest(msg)
      F.new.hexdigest(msg) + G.new.hexdigest(msg)
    end
  end
end
