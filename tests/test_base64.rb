def test_base64_encode_empty(_args, assert)
  assert.equal! HighScore::Base64.encode(""), ""
end

def test_base64_encode_simple(_args, assert)
  # RFC 4648 test vectors
  assert.equal! HighScore::Base64.encode("f"), "Zg=="
  assert.equal! HighScore::Base64.encode("fo"), "Zm8="
  assert.equal! HighScore::Base64.encode("foo"), "Zm9v"
  assert.equal! HighScore::Base64.encode("foob"), "Zm9vYg=="
  assert.equal! HighScore::Base64.encode("fooba"), "Zm9vYmE="
  assert.equal! HighScore::Base64.encode("foobar"), "Zm9vYmFy"
end

def test_base64_encode_hello(_args, assert)
  assert.equal! HighScore::Base64.encode("Hello"), "SGVsbG8="
  assert.equal! HighScore::Base64.encode("Hello World"), "SGVsbG8gV29ybGQ="
  assert.equal! HighScore::Base64.encode("DragonRuby"), "RHJhZ29uUnVieQ=="
end

def test_base64_encode_padding_1_byte(_args, assert)
  # 1 byte should produce 2 characters + 2 padding
  assert.equal! HighScore::Base64.encode("a"), "YQ=="
  assert.equal! HighScore::Base64.encode("M"), "TQ=="
end

def test_base64_encode_padding_2_bytes(_args, assert)
  # 2 bytes should produce 3 characters + 1 padding
  assert.equal! HighScore::Base64.encode("ab"), "YWI="
  assert.equal! HighScore::Base64.encode("Mr"), "TXI="
end

def test_base64_encode_padding_3_bytes(_args, assert)
  # 3 bytes should produce 4 characters, no padding
  assert.equal! HighScore::Base64.encode("abc"), "YWJj"
  assert.equal! HighScore::Base64.encode("Moo"), "TW9v"
end

def test_base64_encode_binary_values(_args, assert)
  # Test with binary data (null bytes, etc)
  assert.equal! HighScore::Base64.encode("\x00"), "AA=="
  assert.equal! HighScore::Base64.encode("\x00\x00"), "AAA="
  assert.equal! HighScore::Base64.encode("\xFF"), "/w=="
  assert.equal! HighScore::Base64.encode("\xFF\xFF"), "//8="
end

def test_base64_encode_purpletoken_example(_args, assert)
  # From v3api.txt - the params string that needs to be encoded (URL-safe, no padding)
  # Note: The example in the docs appears to have "gamkey" not "gamekey" based on the Base64
  input = "gamkey=c5f4a0474223a4cc0c93d68a7c80cc541d05b90c&format=json&array=yes&dates=yes&ids=yes"
  expected = "Z2Fta2V5PWM1ZjRhMDQ3NDIyM2E0Y2MwYzkzZDY4YTdjODBjYzU0MWQwNWI5MGMmZm9ybWF0PWpzb24mYXJyYXk9eWVzJmRhdGVzPXllcyZpZHM9eWVz"
  assert.equal! HighScore::Base64.urlsafe_encode64(input), expected
end

def test_base64_strict_encode64(_args, assert)
  # strict_encode64 should behave the same as encode (no line breaks)
  assert.equal! HighScore::Base64.strict_encode64("foobar"), "Zm9vYmFy"
  assert.equal! HighScore::Base64.strict_encode64("Hello World"), "SGVsbG8gV29ybGQ="
end

def test_base64_decode_simple(_args, assert)
  # RFC 4648 test vectors (decode)
  assert.equal! HighScore::Base64.decode("Zg=="), "f"
  assert.equal! HighScore::Base64.decode("Zm8="), "fo"
  assert.equal! HighScore::Base64.decode("Zm9v"), "foo"
  assert.equal! HighScore::Base64.decode("Zm9vYg=="), "foob"
  assert.equal! HighScore::Base64.decode("Zm9vYmE="), "fooba"
  assert.equal! HighScore::Base64.decode("Zm9vYmFy"), "foobar"
end

def test_base64_decode_hello(_args, assert)
  assert.equal! HighScore::Base64.decode("SGVsbG8="), "Hello"
  assert.equal! HighScore::Base64.decode("SGVsbG8gV29ybGQ="), "Hello World"
end

def test_base64_decode_empty(_args, assert)
  assert.equal! HighScore::Base64.decode(""), ""
end

def test_base64_roundtrip(_args, assert)
  # Encode then decode should return original
  original = "The quick brown fox jumps over the lazy dog"
  encoded = HighScore::Base64.encode(original)
  decoded = HighScore::Base64.decode(encoded)
  assert.equal! decoded, original
end

def test_base64_roundtrip_binary(_args, assert)
  # Roundtrip with binary data
  original = "\x00\x01\x02\x03\xFF\xFE\xFD\xFC"
  encoded = HighScore::Base64.encode(original)
  decoded = HighScore::Base64.decode(encoded)
  assert.equal! decoded, original
end
