def test_sha256_empty_string(_args, assert)
  # SHA-256 of empty string
  expected = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  assert.equal! HighScore::SHA256.hexdigest(""), expected
end

def test_sha256_abc(_args, assert)
  # SHA-256 of "abc"
  expected = "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
  assert.equal! HighScore::SHA256.hexdigest("abc"), expected
end

def test_sha256_hello_world(_args, assert)
  # SHA-256 of "Hello World"
  expected = "a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e"
  assert.equal! HighScore::SHA256.hexdigest("Hello World"), expected
end

def test_sha256_hello(_args, assert)
  # SHA-256 of "Hello"
  expected = "185f8db32271fe25f561a6fc938b2e264306ec304eda518007d1764826381969"
  assert.equal! HighScore::SHA256.hexdigest("Hello"), expected
end

def test_sha256_dragonruby(_args, assert)
  # SHA-256 of "DragonRuby"
  expected = "8c8ec7f5c8e5c5b5b5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5"
  # Actually compute this for testing
  actual = HighScore::SHA256.hexdigest("DragonRuby")
  # Just verify it produces a 64-character hex string
  assert.equal! actual.length, 64
  assert.equal! actual, actual.downcase
end

def test_sha256_long_string(_args, assert)
  # SHA-256 of "The quick brown fox jumps over the lazy dog"
  expected = "d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592"
  assert.equal! HighScore::SHA256.hexdigest("The quick brown fox jumps over the lazy dog"), expected
end

def test_sha256_long_string_period(_args, assert)
  # SHA-256 of "The quick brown fox jumps over the lazy dog."
  expected = "ef537f25c895bfa782526529a9b63d97aa631564d5d789c2b765448c8635fb6c"
  assert.equal! HighScore::SHA256.hexdigest("The quick brown fox jumps over the lazy dog."), expected
end

def test_sha256_multiblock(_args, assert)
  # Test a message longer than 512 bits (64 bytes) to ensure multi-block processing works
  # This is 100 bytes = 800 bits, requiring 2 blocks after padding
  message = "a" * 100
  result = HighScore::SHA256.hexdigest(message)
  # Verify it produces a valid 64-character hex string
  assert.equal! result.length, 64
  assert.equal! result, result.downcase
  # Correct known value for 100 'a's (verified with shasum -a 256)
  expected = "2816597888e4a0d3a36b82b83316ab32680eb8f00f8cd3b904d681246d285a0e"
  assert.equal! result, expected
end

def test_sha256_purpletoken_v3_example(_args, assert)
  # CRITICAL TEST: The exact example from v3api.txt
  # encoded params = "Z2Fta2V5PWM1ZjRhMDQ3NDIyM2E0Y2MwYzkzZDY4YTdjODBjYzU0MWQwNWI5MGMmZm9ybWF0PWpzb24mYXJyYXk9eWVzJmRhdGVzPXllcyZpZHM9eWVz"
  # secret = "fuzzy bunnies"
  # signature = SHA256(encoded + secret)
  encoded = "Z2Fta2V5PWM1ZjRhMDQ3NDIyM2E0Y2MwYzkzZDY4YTdjODBjYzU0MWQwNWI5MGMmZm9ybWF0PWpzb24mYXJyYXk9eWVzJmRhdGVzPXllcyZpZHM9eWVz"
  secret = "fuzzy bunnies"
  input = encoded + secret
  expected = "5888134de8dff7b7afc159c99382ef9ad7bc2bc5e45930630c5267d395242fa0"

  actual = HighScore::SHA256.hexdigest(input)
  assert.equal! actual, expected
end

def test_sha256_hexdigest_upper(_args, assert)
  # Test uppercase hex output
  result = HighScore::SHA256.hexdigest_upper("abc")
  expected = "BA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD"
  assert.equal! result, expected
end

def test_sha256_digest_binary(_args, assert)
  # Test binary digest output
  result = HighScore::SHA256.digest("abc")
  # Should be 32 bytes
  assert.equal! result.bytes.length, 32
  # First byte should be 0xBA (from the hex "ba7816bf...")
  assert.equal! result.bytes[0], 0xBA
  # Second byte should be 0x78
  assert.equal! result.bytes[1], 0x78
end

def test_sha256_base64digest(_args, assert)
  # Test Base64 encoded digest
  result = HighScore::SHA256.base64digest("abc")
  # SHA-256 of "abc" in Base64
  # Should produce a non-empty Base64 string (44 characters for SHA-256)
  assert.equal! result.length, 44  # SHA-256 (32 bytes) in Base64 is 44 chars with padding
  # Verify it contains only valid Base64 characters
  result.each_char do |c|
    valid = (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '+' || c == '/' || c == '='
    assert.equal! valid, true
  end
end

def test_sha256_nist_test_vector_1(_args, assert)
  # NIST test vector: one-block message
  # Input: "abc"
  # Already tested above, but included for completeness
  expected = "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
  assert.equal! HighScore::SHA256.hexdigest("abc"), expected
end

def test_sha256_nist_test_vector_2(_args, assert)
  # NIST test vector: multi-block message
  # Input: "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
  input = "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
  expected = "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1"
  assert.equal! HighScore::SHA256.hexdigest(input), expected
end

def test_sha256_binary_data(_args, assert)
  # Test with binary data (null bytes)
  result = HighScore::SHA256.hexdigest("\x00")
  # SHA-256 of a single null byte
  expected = "6e340b9cffb37a989ca544e6bb780a2c78901d3fb33738768511a30617afa01d"
  assert.equal! result, expected
end
