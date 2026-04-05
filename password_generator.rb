class PasswordGenerator
  LOWERCASE = ("a".."z").to_a
  UPPERCASE = ("A".."Z").to_a
  NUMBERS   = ("0".."9").to_a
  SYMBOLS   = %w[! @ # $ % ^ & * ( ) - _ = + { } [ ] : ; < > ?]

  def initialize(length:, min_uppercase:, min_numbers:, min_symbols:, allow_symbols:)
    @length = length
    @min_uppercase = min_uppercase
    @min_numbers = min_numbers
    @min_symbols = min_symbols
    @allow_symbols = allow_symbols
  end

  def generate
    chars = []

    # Required characters
    chars += UPPERCASE.sample(@min_uppercase)
    chars += NUMBERS.sample(@min_numbers)
    chars += SYMBOLS.sample(@min_symbols) if @allow_symbols

    # Build allowed pool
    allowed_pool = LOWERCASE.dup
    allowed_pool += UPPERCASE if @min_uppercase > 0
    allowed_pool += NUMBERS if @min_numbers > 0
    allowed_pool += SYMBOLS if @allow_symbols

    # Fill remaining length
    remaining = @length - chars.length
    chars += allowed_pool.sample(remaining)

    # Shuffle for randomness
    chars.shuffle.join
  end
end