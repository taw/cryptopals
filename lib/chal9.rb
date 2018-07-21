class Chal9
  def call(input, n)
    return input if input.size >= n
    padding_size = n - input.size
    raise if padding_size > 255
    padding = padding_size.chr * padding_size
    input + padding
  end
end
