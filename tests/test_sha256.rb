def test_sha256_test_vectors(_args, assert)
  # https://di-mgt.com.au/sha_testvectors.html
  expected = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
  assert.equal! SHA256.hexdigest(''), expected

  expected = 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad'
  assert.equal! SHA256.hexdigest('abc'), expected

  input = 'abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq'
  expected = '248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1'
  assert.equal! SHA256.hexdigest(input), expected

  input = 'abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu'
  expected = 'cf5b16a778af8380036ce59e7b0492370b249b11e8f07a51afac45037afee9d1'
  assert.equal! SHA256.hexdigest(input), expected
end

def test_sha256_purpletoken_v3_example(_args, assert)
  # Example: https://purpletoken.com/api.php
  encoded = 'Z2Fta2V5PWM1ZjRhMDQ3NDIyM2E0Y2MwYzkzZDY4YTdjODBjYzU0MWQwNWI5MGMmZm9ybWF0PWpzb24mYXJyYXk9eWVzJmRhdGVzPXllcyZpZHM9eWVz'
  secret = 'fuzzy bunnies'
  input = encoded + secret
  expected = '5888134de8dff7b7afc159c99382ef9ad7bc2bc5e45930630c5267d395242fa0'

  actual = SHA256.hexdigest(input)
  assert.equal! actual, expected
end
