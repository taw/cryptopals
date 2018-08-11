class Chal54
  # 24 bit hash should have 2^24 resistance to second preimage
  F = Chal52::F

  class Nostradamus
    def initialize(total_length)
      @f = F.new
      @total_length = total_length
      @tree = conflicting_pair(k)
      state = @tree.first
      # Could this be 2 chunks?
      # Just assume nice alignment
      final_chunk = @f.pad_message("x" * total_length)[-16..-1]
      @prediction_hash = @f.reduce(state, final_chunk)
      @target_map = {}
      generate_target_map(@tree, "")
    end

    def generate_target_map(node, info)
      if node.size == 1
        @target_map[node[0]] = info
      else
        state_merged, chunk1, state1, chunk2, state2 = node
        generate_target_map(state1, chunk1+info)
        generate_target_map(state2, chunk2+info)
      end
    end

    def random_state
      Random::DEFAULT.bytes(3)
    end

    def find_multitarget_collision(state, target_map)
      i = 0
      while true
        chunk = "%016d" % i
        h = @f.reduce(state, chunk)
        if target_map[h]
          return [h, chunk, target_map[h]]
        end
        i += 1
      end
    end

    def find_merge_collision(state_left, state_right)
      hashes_left = {}
      hashes_right = {}

      i = 0
      while true
        chunk = "%016d" % i
        hl = @f.reduce(state_left, chunk)
        hr = @f.reduce(state_right, chunk)

        if hashes_left[hr]
          return [hr, hashes_left[hr], chunk]
        end
        if hashes_right[hl]
          return [hl, chunk, hashes_right[hl]]
        end
        hashes_left[hl] = chunk
        hashes_right[hr] = chunk
        i += 1
      end
    end

    def conflicting_pair(k)
      return [random_state] if k == 0
      state1 = conflicting_pair(k-1)
      state2 = conflicting_pair(k-1)
      state_merged, chunk1, chunk2 = find_merge_collision(state1.first, state2.first)
      [state_merged, chunk1, state1, chunk2, state2]
    end

    def prediction_hash
      @prediction_hash.to_hex
    end

    def create_prediction(message)
      glue_length = @total_length - message.size - 16 - 16*k
      message += " " * glue_length
      state = @f.unpadded_hexdigest(message).from_hex
      h, chunk, blocks = find_multitarget_collision(state, @target_map)
      message + chunk + blocks
    end

    # Precomputation Cost is: 2^(k + (b/2))
    # Postcomputation Cost is: 2^(b-k)
    def k
      8
    end
  end
end
