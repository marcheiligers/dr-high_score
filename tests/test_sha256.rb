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
  encoded = 'Z2FtZWtleT1jNWY0YTA0NzQyMjNhNGNjMGM5M2Q2OGE3YzgwY2M1NDFkMDViOTBjJmZvcm1hdD1qc29uJmFycmF5PXllcyZkYXRlcz15ZXMmaWRzPXllcw=='
  secret = 'fuzzy bunnies'
  input = encoded + secret
  expected = 'dcb260adda344e82daa9ffa2f7a03aebca101b9afd4fa327a83ce8c20c30d8ee'

  actual = SHA256.hexdigest(input)
  assert.equal! actual, expected
end
