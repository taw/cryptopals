class Chal64
  def self.gcm_mul_matrix(c)
    c = GCMField.new(c)
    GF2Matrix.build(128) do |i|
      (c * GCMField.new(i)).value
    end
  end

  def self.gcm_square_matrix
    GF2Matrix.build(128) do |i|
      i = GCMField.new(i)
      (i * i).value
    end
  end
end
