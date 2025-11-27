def test_bad_crypto_hex_string_roundtrip(_args, assert)
  # BadCrypto is designed for hex strings (game keys), which ARE reversible
  # SOURCE = 'abcdef0123456789' (hex chars)
  # DEST = 'plsdonthackme!?$'

  hex_string = "abc123def456"
  encrypted = HighScore::BadCrypto.encrypt(hex_string)
  decrypted = HighScore::BadCrypto.decrypt(encrypted)

  assert.equal! decrypted, hex_string
end

def test_bad_crypto_obfuscates_hex(_args, assert)
  # Test that hex strings get obfuscated
  # SOURCE = 'abcdef0123456789'
  # DEST = 'plsdonthackme!?$'

  # 'a' (position 0 in SOURCE) becomes 'p' (position 0 in DEST)
  assert.equal! HighScore::BadCrypto.encrypt("a"), "p"
  assert.equal! HighScore::BadCrypto.decrypt("p"), "a"

  # Full hex string gets obfuscated
  gamekey = "c5f4a047"
  encrypted = HighScore::BadCrypto.encrypt(gamekey)

  # Should not equal original (it's obfuscated)
  assert.equal! (encrypted != gamekey), true

  # But should decrypt back correctly
  assert.equal! HighScore::BadCrypto.decrypt(encrypted), gamekey
end

def test_bad_crypto_non_reversible_for_non_hex(_args, assert)
  # BadCrypto is NOT reversible for strings containing DEST chars
  # This documents the known limitation

  original = "fuzzy bunnies"  # Contains 'n' and 's' which are in DEST
  encrypted = HighScore::BadCrypto.encrypt(original)
  decrypted = HighScore::BadCrypto.decrypt(encrypted)

  # This will NOT round-trip correctly due to 'n' and 's' being in DEST
  assert.equal! (decrypted != original), true
  assert.equal! encrypted, "nuzzy lunnios"
  assert.equal! decrypted, "fuzzy buffiec"
end
