module HighScore
  module SHA256
    # SHA-256 constants: first 32 bits of the fractional parts of the cube roots of the first 64 primes
    K = [
      0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
      0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
      0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
      0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
      0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
      0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
      0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
      0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
    ].freeze

    # Initial hash values: first 32 bits of the fractional parts of the square roots of the first 8 primes
    H_INIT = [
      0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
      0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
    ].freeze

    # Right rotate operation
    def self.rotr(n, b)
      ((n >> b) | (n << (32 - b))) & 0xFFFFFFFF
    end

    # SHA-256 logical functions
    def self.ch(x, y, z)
      (x & y) ^ (~x & z)
    end

    def self.maj(x, y, z)
      (x & y) ^ (x & z) ^ (y & z)
    end

    def self.sigma0(x)
      rotr(x, 2) ^ rotr(x, 13) ^ rotr(x, 22)
    end

    def self.sigma1(x)
      rotr(x, 6) ^ rotr(x, 11) ^ rotr(x, 25)
    end

    def self.gamma0(x)
      rotr(x, 7) ^ rotr(x, 18) ^ (x >> 3)
    end

    def self.gamma1(x)
      rotr(x, 17) ^ rotr(x, 19) ^ (x >> 10)
    end

    # Preprocess the message
    def self.preprocess(message)
      # Convert string to bytes
      bytes = message.bytes
      msg_len = bytes.length
      bit_len = msg_len * 8

      # Append the '1' bit (0x80)
      bytes << 0x80

      # Append '0' bits until message length ≡ 448 (mod 512)
      # We need (448 - current_bits) mod 512 zero bits
      # That's (56 - current_bytes) mod 64 zero bytes
      while (bytes.length % 64) != 56
        bytes << 0x00
      end

      # Append the original message length as a 64-bit big-endian integer
      # Ruby's integers are arbitrary precision, so we manually extract bytes
      8.times do |i|
        bytes << ((bit_len >> (56 - i * 8)) & 0xFF)
      end

      bytes
    end

    # Process a 512-bit block
    def self.process_block(block, h)
      # Parse block into 16 32-bit words
      w = Array.new(64, 0)

      16.times do |i|
        w[i] = (block[i * 4] << 24) |
               (block[i * 4 + 1] << 16) |
               (block[i * 4 + 2] << 8) |
               block[i * 4 + 3]
      end

      # Extend the first 16 words into the remaining 48 words
      16.upto(63) do |i|
        w[i] = (gamma1(w[i - 2]) + w[i - 7] + gamma0(w[i - 15]) + w[i - 16]) & 0xFFFFFFFF
      end

      # Initialize working variables
      a, b, c, d, e, f, g, h_var = h

      # Main loop (64 rounds)
      64.times do |i|
        t1 = (h_var + sigma1(e) + ch(e, f, g) + K[i] + w[i]) & 0xFFFFFFFF
        t2 = (sigma0(a) + maj(a, b, c)) & 0xFFFFFFFF

        h_var = g
        g = f
        f = e
        e = (d + t1) & 0xFFFFFFFF
        d = c
        c = b
        b = a
        a = (t1 + t2) & 0xFFFFFFFF
      end

      # Add compressed chunk to current hash value
      [
        (h[0] + a) & 0xFFFFFFFF,
        (h[1] + b) & 0xFFFFFFFF,
        (h[2] + c) & 0xFFFFFFFF,
        (h[3] + d) & 0xFFFFFFFF,
        (h[4] + e) & 0xFFFFFFFF,
        (h[5] + f) & 0xFFFFFFFF,
        (h[6] + g) & 0xFFFFFFFF,
        (h[7] + h_var) & 0xFFFFFFFF
      ]
    end

    # Compute SHA-256 hash (returns 32-byte binary string)
    def self.digest(message)
      bytes = preprocess(message)

      # Initialize hash values
      h = H_INIT.dup

      # Process each 512-bit block
      num_blocks = (bytes.length / 64).to_i
      num_blocks.times do |i|
        block = bytes[i * 64, 64]
        h = process_block(block, h)
      end

      # Produce the final hash value (big-endian)
      result = []
      h.each do |word|
        result << ((word >> 24) & 0xFF)
        result << ((word >> 16) & 0xFF)
        result << ((word >> 8) & 0xFF)
        result << (word & 0xFF)
      end

      result.pack('C*')
    end

    # Compute SHA-256 hash (returns lowercase hex string)
    def self.hexdigest(message)
      digest(message).bytes.map { |b| "%02x" % b }.join
    end

    # Compute SHA-256 hash (returns uppercase hex string)
    def self.hexdigest_upper(message)
      digest(message).bytes.map { |b| "%02X" % b }.join
    end

    # Compute SHA-256 hash (returns Base64 encoded string)
    def self.base64digest(message)
      HighScore::Base64.encode(digest(message))
    end
  end
end
