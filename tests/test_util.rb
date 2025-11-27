def test_bad_crypto_source_dest_same_length(_args, assert)
  # SOURCE and DEST must be exactly the same length for tr() to work correctly
  source_len = HighScore::BadCrypto::SOURCE.length
  dest_len = HighScore::BadCrypto::DEST.length

  assert.equal! source_len, dest_len
end

def test_bad_crypto_basic_char_mapping(_args, assert)
  # Test individual character mappings for the first 16 (hex) chars
  #'a' at position 0 in SOURCE should map to 'p' at position 0 in DEST
  assert.equal! HighScore::BadCrypto.encrypt("a"), "p"
  assert.equal! HighScore::BadCrypto.decrypt("p"), "a"

  # 'b' at position 1 should map to 'l'
  assert.equal! HighScore::BadCrypto.encrypt("b"), "l"
  assert.equal! HighScore::BadCrypto.decrypt("l"), "b"
end

def test_bad_crypto_hex_string_roundtrip(_args, assert)
  # BadCrypto maintains backward compatibility with hex strings
  # First 16 chars of SOURCE/DEST are unchanged: 'abcdef0123456789' -> 'plsdonthackme!?$'

  hex_string = 'abcdef0123456789'
  encrypted = HighScore::BadCrypto.encrypt(hex_string)
  decrypted = HighScore::BadCrypto.decrypt(encrypted)

  assert.equal! decrypted, hex_string
end

def test_bad_crypto_hex_mapping_unchanged(_args, assert)
  # Verify original hex mappings are preserved for backward compatibility
  assert.equal! HighScore::BadCrypto.encrypt("a"), "p"
  assert.equal! HighScore::BadCrypto.decrypt("p"), "a"

  # Full hex gamekey from docs
  gamekey = "c5f4a0474223a4cc0c93d68a7c80cc541d05b90c"
  encrypted = HighScore::BadCrypto.encrypt(gamekey)
  decrypted = HighScore::BadCrypto.decrypt(encrypted)

  assert.equal! decrypted, gamekey
  assert.equal! (encrypted != gamekey), true  # It IS obfuscated
end

def test_bad_crypto_lowercase_letters(_args, assert)
  # Test extended lowercase support (g-z)
  original = "hello world"
  encrypted = HighScore::BadCrypto.encrypt(original)
  decrypted = HighScore::BadCrypto.decrypt(encrypted)

  assert.equal! decrypted, original
  assert.equal! (encrypted != original), true  # It IS obfuscated
end

def test_bad_crypto_uppercase_letters(_args, assert)
  # Test uppercase letter support
  original = "Hello World"
  encrypted = HighScore::BadCrypto.encrypt(original)
  decrypted = HighScore::BadCrypto.decrypt(encrypted)

  assert.equal! decrypted, original
  assert.equal! (encrypted != original), true  # It IS obfuscated
end

def test_bad_crypto_fuzzy_bunnies(_args, assert)
  # The "fuzzy bunnies" example from v3 API docs now works!
  original = "fuzzy bunnies"
  encrypted = HighScore::BadCrypto.encrypt(original)
  decrypted = HighScore::BadCrypto.decrypt(encrypted)

  assert.equal! decrypted, original
  assert.equal! (encrypted != original), true  # It IS obfuscated
end

def test_bad_crypto_mixed_content(_args, assert)
  # Test mixed letters, numbers, symbols, and spaces
  original = "Player-123: Score=9999!"
  encrypted = HighScore::BadCrypto.encrypt(original)
  decrypted = HighScore::BadCrypto.decrypt(encrypted)

  assert.equal! decrypted, original
  assert.equal! (encrypted != original), true  # It IS obfuscated
end

def test_bad_crypto_common_symbols(_args, assert)
  # Test common US keyboard symbols
  original = "test@email.com (score: 100%)"
  encrypted = HighScore::BadCrypto.encrypt(original)
  decrypted = HighScore::BadCrypto.decrypt(encrypted)

  assert.equal! decrypted, original
end
