def test_bad_crypto_source_dest_same_length(_args, assert)
  # SOURCE and DEST must be exactly the same length for tr() to work correctly for this
  source_len = HighScore::BadCrypto::SOURCE.length
  dest_len = HighScore::BadCrypto::DEST.length

  assert.equal! source_len, dest_len
end

def test_bad_crypto_hex(_args, assert)
  # Maintain backward compatibility with hex strings for original v2 keys
  # 'abcdef0123456789' -> 'plsdonthackme!?$'
  hex_string = 'abcdef0123456789'
  encrypted = HighScore::BadCrypto.encrypt(hex_string)
  assert.equal! encrypted, 'plsdonthackme!?$'

  decrypted = HighScore::BadCrypto.decrypt(encrypted)
  assert.equal! decrypted, hex_string
end

def test_bad_crypto_fuzzy_bunnies_secret(_args, assert)
  # The "fuzzy bunnies" secret example from v3 API
  original = 'fuzzy bunnies'
  encrypted = HighScore::BadCrypto.encrypt(original)
  decrypted = HighScore::BadCrypto.decrypt(encrypted)

  assert.equal! decrypted, original
end

def test_bad_crypto_symbols(_args, assert)
  original = 'Player-123: Score=9999!'
  encrypted = HighScore::BadCrypto.encrypt(original)
  decrypted = HighScore::BadCrypto.decrypt(encrypted)

  assert.equal! decrypted, original
end

def test_symbols(_args, assert)
  originals = ['test_key', 'test-key', "'test_key'", 'test\key', '"test_key"']
  originals.each do |original|
    encrypted = HighScore::BadCrypto.encrypt(original)
    decrypted = HighScore::BadCrypto.decrypt(encrypted)

    assert.equal! decrypted, original
  end
end
