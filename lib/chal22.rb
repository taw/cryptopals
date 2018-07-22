class Chal22
  def hack(start, value)
    (start-200..start+200).each do |seed|
      rng = Chal21.new
      rng.seed(seed)
      return seed if rng.extract_number == value
    end
    raise "Could not reverse"
  end
end
