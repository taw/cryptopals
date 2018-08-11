class Chal53
  # 24 bit hash should have 2^24 resistance to second preimage
  F = Chal52::F

  def initialize
    @f = F.new
  end

  def intermediate_hashes(msg)
    result = {}
    chunks = @f.pad_message(msg).byteslices(16)
    state = @f.initial_state

    chunks.each_with_index do |chunk, i|
      # Could even have a collision here, but this is not the attack we're trying to do,
      # so politely ignore that
      warn "Already colliding internally #{result[state]} #{i}" if result[state]
      result[state] = i
      state = @f.reduce(state, chunk)
    end

    result
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

  def find_length_block_collision(state, target_length)
    state_short = state
    state_long = state

    prefix = (0...target_length).map {|i| "EXTEND %08d\n" % i }.join
    state_long = state
    prefix.byteslices(16).each do |chunk|
      state_long = @f.reduce(state_long, chunk)
    end

    state_merged, chunk1, chunk2 = find_merge_collision(state_short, state_long)
    [state_merged, chunk1, prefix + chunk2]
  end

  def generate_extension_map(k)
    state = @f.initial_state
    result = []
    (0...k).each do |i|
      state, short, long = find_length_block_collision(state, 2**i)
      result << [short, long]
    end
    [state, *result]
  end

  def hack(msg)
    k = 12
    intermediate = intermediate_hashes(msg)
    map_final_state, *map_pairs = generate_extension_map(k)
    h, chunk, i = find_multitarget_collision(map_final_state, intermediate)
    chunk_size_target = i - k - 1
    map_pairs.map.with_index{|chunks,i| chunks[chunk_size_target[i]] }.join + chunk + msg[i*16..-1]
  end
end
