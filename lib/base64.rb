module HighScore
  module Base64
    # Standard Base64 alphabet
    ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    PAD = "="

    # Encode a string to Base64
    def self.encode(str)
      return "" if str.nil? || str.empty?

      result = []
      bytes = str.bytes

      # Process 3 bytes at a time
      i = 0
      while i < bytes.length
        # Get up to 3 bytes
        b1 = bytes[i] || 0
        b2 = bytes[i + 1]
        b3 = bytes[i + 2]

        # Convert 3 bytes (24 bits) into 4 base64 characters (6 bits each)
        # First character: top 6 bits of b1
        result << ALPHABET[b1 >> 2]

        if b2.nil?
          # Only 1 byte: bottom 2 bits of b1, padded with 4 zeros
          result << ALPHABET[(b1 & 0x03) << 4]
          result << PAD
          result << PAD
        elsif b3.nil?
          # 2 bytes: bottom 2 bits of b1 + top 4 bits of b2
          result << ALPHABET[((b1 & 0x03) << 4) | (b2 >> 4)]
          # Bottom 4 bits of b2, padded with 2 zeros
          result << ALPHABET[(b2 & 0x0F) << 2]
          result << PAD
        else
          # 3 bytes: bottom 2 bits of b1 + top 4 bits of b2
          result << ALPHABET[((b1 & 0x03) << 4) | (b2 >> 4)]
          # Bottom 4 bits of b2 + top 2 bits of b3
          result << ALPHABET[((b2 & 0x0F) << 2) | (b3 >> 6)]
          # Bottom 6 bits of b3
          result << ALPHABET[b3 & 0x3F]
        end

        i += 3
      end

      result.join
    end

    # Encode without line breaks (same as encode for URL usage)
    def self.strict_encode64(str)
      encode(str)
    end

    # Encode without line breaks or padding (for URL-safe usage)
    def self.urlsafe_encode64(str)
      result = encode(str)
      # Remove trailing padding for URL-safe usage
      while result.end_with?('=')
        result = result[0..-2]
      end
      result
    end

    # Decode a Base64 string
    def self.decode(str)
      return "" if str.nil? || str.empty?

      # Remove leading/trailing whitespace
      str = str.strip

      # Build reverse lookup table
      reverse = {}
      idx = 0
      ALPHABET.each_char do |c|
        reverse[c] = idx
        idx += 1
      end

      result = []
      bytes = str.chars

      # Process 4 characters at a time
      i = 0
      while i < bytes.length
        # Get up to 4 characters
        c1 = bytes[i]
        c2 = bytes[i + 1]
        c3 = bytes[i + 2]
        c4 = bytes[i + 3]

        break if c1.nil? || c2.nil?

        # Skip padding
        v1 = reverse[c1] || 0
        v2 = reverse[c2] || 0
        v3 = c3 && c3 != PAD ? (reverse[c3] || 0) : nil
        v4 = c4 && c4 != PAD ? (reverse[c4] || 0) : nil

        # First byte: top 6 bits from v1 + top 2 bits from v2
        result.push(((v1 << 2) | (v2 >> 4)) & 0xFF)

        if v3
          # Second byte: bottom 4 bits from v2 + top 4 bits from v3
          result.push(((v2 << 4) | (v3 >> 2)) & 0xFF)

          if v4
            # Third byte: bottom 2 bits from v3 + all 6 bits from v4
            result.push(((v3 << 6) | v4) & 0xFF)
          end
        end

        i += 4
      end

      result.pack('C*')
    end
  end
end
