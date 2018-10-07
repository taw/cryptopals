class Chal47
  class Oracle
    def initialize(private_key)
      @private_key = private_key
      @nlen = Chal47.pad_len_for_key @private_key.n
      @b = 256**(@nlen-2)
      @ptmin = @b*2
      @ptmax = @b*3-1
    end

    def call(ct)
      pt = @private_key.decrypt(ct)
      pt >= @ptmin and pt <= @ptmax
      # pt_bin = ("%0#{@nlen*2}x"  % pt).from_hex
      # Chal47.somewhat_correct_padding?(pt_bin, @nlen)
    end
  end

  class Attacker
    attr_reader :public_key, :oracle, :n, :e, :nlen, :b

    def initialize(public_key, oracle)
      @public_key = public_key
      @oracle = oracle

      # Step 0 - prepare some maths
      @n = public_key.n
      @e = public_key.e
      @nlen = Chal47.pad_len_for_key(@public_key.n)
      @b = 256**(@nlen-2)
    end

    def reset_oracle_call_counter
      @tries = 0
    end

    def increase_oracle_call_counter
      @tries += 1
      @total_tries += 1
      # puts "T: #{@tries}" if @tries % 1000 == 0
      # puts "TT: #{@total_tries}" if @total_tries % 1000 == 0
    end

    def oracle_call(msg)
      increase_oracle_call_counter
      @oracle.call(msg)
    end

    def call(message)
      @total_tries = 0
      # Step 1: Blinding.
      #
      # It's already done since we're attacking message not signature
      # but we really ought to validate
      c0 = message
      si = 1
      ci = message
      mi = [[2*@b, (3*@b-1)]]
      i = 1

      raise unless message > 0 and message < @public_key.n
      raise unless @oracle.call(message)

      while true
        possibilities = mi.map{|mn,mx| mx-mn+1}.sum
        # puts "TODO: #{possibilities} possibilities in #{mi.size} ranges"

        # Step 2: Searching for PKCS conforming messages.
        if i == 1
          # Step 2.a: Starting the search.
          min_s1 = @n.ceil_div(3*@b)
          reset_oracle_call_counter
          si = (min_s1..Float::INFINITY).find{|si_candidate|
            raise "Too many attempts" if @tries > 100000 # Shouldn't be > 2**16 unless I'm confused
            oracle_call( (c0 * si_candidate.powmod(@e, @n)) % @n )
          }
          # puts "Step 2a took #{@tries} Oracle calls"
        elsif mi.size > 1
          # Step 2.b: Searching with more than one interval left.
          min_si = si+1
          reset_oracle_call_counter
          si = (min_si..Float::INFINITY).find{|si_candidate|
            raise "Too many attempts" if @tries > 100000 # Shouldn't be > 2**16 unless I'm confused
            oracle_call( (c0 * si_candidate.powmod(@e, @n)) % @n )
          }
          # puts "Step 2b took #{@tries} Oracle calls"
        else
          # Step 2.c: Searching with one interval left.
          found_si = false
          reset_oracle_call_counter
          mn, mx = mi[0]
          min_ri = 2 * ((mx*si - 2*@b + n - 1) / n)
          (min_ri..Float::INFINITY).each do |ri|
            min_si = (2*@b + ri*@n).ceil_div mx
            max_si = (3*@b + ri*@n) / mn
            (min_si..max_si).each do |si_candidate|
              if oracle_call( (c0 * si_candidate.powmod(@e, @n)) % @n )
                si = si_candidate
                found_si = true
              end
            end
            break if found_si
          end
          # puts "Step 3b took #{@tries} Oracle calls"
        end

        # Step 3: Narrowing the set of solutions.
        mi_next = []
        mi.each do |mn, mx|
          rs = ((mn*si - 3*b + 1 + @n - 1)/@n) .. ((mx*si - 2*@b)/@n)
          rs.each do |r|
            mn_next = [mn, (2*@b + r*@n).ceil_div(si)].max
            mx_next = [mx, (3*@b - 1 + r*@n)/si].min
            mi_next << [mn_next, mx_next]
          end
        end
        mi = normalize_ranges(mi_next)

        # Step 4: Computing the solution.
        if mi.size == 1 and mi[0][0] == mi[0][1]
          puts "Hack took #{@total_tries} Oracle calls"
          pt = mi[0][0]
          pt_bin = ("%0#{@nlen*2}x"  % pt).from_hex
          return Chal47.remove_padding(pt_bin)
        else
          # continue looping
          i += 1
        end
      end
    end

    def normalize_ranges(ranges)
      output = []
      ranges = ranges.sort_by(&:first)
      while ranges.size > 2
        r0 = ranges.shift
        r1 = ranges[0]
        if r0[1]+1 < r1[0]
          # no overlap, so add first to output and retry
          output << r0
        else
          # overlaps (or immediately follows), so merge
          # A..B + C..D -> A..D
          ranges[0] = [r0[0], r1[1]]
        end
      end
      output + ranges
    end
  end

  class << self
    def pad_len_for_key(n)
      (n.to_s(2).size + 7)/8
    end

    def remove_padding(msg)
      raise "Incorrect padding" unless msg[0, 2] == "\x00\x02".b
      msg = msg[2..-1]
      msg = msg[1..-1] while msg.size > 0 and msg[0] == "\xFF".b
      raise "Incorrect padding" unless msg[0] == "\x00".b
      msg = msg[1..-1]
      msg
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
