# Mock PurpleTokenV3 to access private methods for testing
class TestPurpleTokenV3 < HighScore::PurpleTokenV3
  def signed_request(endpoint, params)
    build_url(endpoint, params)
  end
end

# Override so the tests don't send requests to PurpleToken
class Request
  class Response
    def initialize(url)
      @url = url
    end
  end
end

def test_purpletoken_v3_signed_request_format(_args, assert)
  key = 'test_key'
  secret = 'test_secret'

  instance = TestPurpleTokenV3.new(key, secret)
  url = instance.signed_request(:get)

  assert.true! url.start_with?('https://purpletoken.com/update/v3/get?')
  assert.true! url.include?('payload=')
  assert.true! url.include?('sig=')
end

def test_purpletoken_v3_payload_encoding(_args, assert)
  key = "test_key"
  secret = "test_secret"

  instance = TestPurpleTokenV3.new(key, secret)
  url = instance.signed_request(:get)

  _, params = url.split('?')
  payload_param = params.split('&').find { |p| p.start_with?('payload=') }
  _, payload = payload_param.split('=')

  assert.false! payload.nil?

  decoded = HighScore::Base64.decode(payload)
  assert.true! decoded.include?('gamekey=test_key')
  assert.true! decoded.include?('format=json')
end

def test_purpletoken_v3_signature_generation(_args, assert)
  # Test that the signature is correctly generated
  key = "test_key"
  secret = "test_secret"

  instance = TestPurpleTokenV3.new(key, secret)
  url = instance.signed_request('get', gamekey: 'test_key', format: 'json')

  # Extract payload and signature from URL (without using Regexp)
  params = url.split('?')[1]
  param_parts = params.split('&')

  payload_param = param_parts.find { |p| p.start_with?('payload=') }
  sig_param = param_parts.find { |p| p.start_with?('sig=') }

  payload = payload_param.split('=', 2)[1]
  sig = sig_param.split('=', 2)[1]

  assert.equal! payload.nil?, false
  assert.equal! sig.nil?, false
  assert.equal! sig.length, 64  # SHA256 hex is 64 characters

  # Verify the signature is SHA256(payload + decrypted_secret)
  # BadCrypto.decrypt transforms the secret, so we need to use the decrypted value
  decrypted_secret = HighScore::BadCrypto.decrypt(secret)
  expected_sig = HighScore::SHA256.hexdigest(payload + decrypted_secret)
  assert.equal! sig, expected_sig
end

def test_purpletoken_v3_api_example(_args, assert)
  # Test with the exact example from v3api.txt
  # NOTE: The Base64 in the docs decodes to "gamkey" not "gamekey" - appears to be a typo in docs
  # gamkey=c5f4a0474223a4cc0c93d68a7c80cc541d05b90c&format=json&array=yes&dates=yes&ids=yes
  # secret = "fuzzy bunnies" (now fully supported with extended BadCrypto!)
  # expected payload = "Z2Fta2V5PWM1ZjRhMDQ3NDIyM2E0Y2MwYzkzZDY4YTdjODBjYzU0MWQwNWI5MGMmZm9ybWF0PWpzb24mYXJyYXk9eWVzJmRhdGVzPXllcyZpZHM9eWVz"
  # expected signature = "5888134de8dff7b7afc159c99382ef9ad7bc2bc5e45930630c5267d395242fa0"

  key = "c5f4a0474223a4cc0c93d68a7c80cc541d05b90c"
  # Use the actual "fuzzy bunnies" secret from the docs
  plain_secret = "fuzzy bunnies"
  encrypted_secret = HighScore::BadCrypto.encrypt(plain_secret)

  instance = TestPurpleTokenV3.new(key, encrypted_secret)
  url = instance.signed_request('get',
                                            gamkey: 'c5f4a0474223a4cc0c93d68a7c80cc541d05b90c',
                                            format: 'json',
                                            array: 'yes',
                                            dates: 'yes',
                                            ids: 'yes')

  # Extract payload and signature (without using Regexp)
  params = url.split('?')[1]
  param_parts = params.split('&')

  payload_param = param_parts.find { |p| p.start_with?('payload=') }
  sig_param = param_parts.find { |p| p.start_with?('sig=') }

  payload = payload_param.split('=', 2)[1]
  sig = sig_param.split('=', 2)[1]

  assert.equal! payload.nil?, false
  assert.equal! sig.nil?, false

  # Verify payload matches expected from docs
  expected_payload = "Z2Fta2V5PWM1ZjRhMDQ3NDIyM2E0Y2MwYzkzZDY4YTdjODBjYzU0MWQwNWI5MGMmZm9ybWF0PWpzb24mYXJyYXk9eWVzJmRhdGVzPXllcyZpZHM9eWVz"
  assert.equal! payload, expected_payload

  # Verify signature matches expected from docs
  expected_sig = "5888134de8dff7b7afc159c99382ef9ad7bc2bc5e45930630c5267d395242fa0"
  assert.equal! sig, expected_sig
end

def test_purpletoken_v3_endpoints(_args, assert)
  # Test that different endpoints are correctly used
  key = "test_key"
  secret = "test_secret"

  instance = TestPurpleTokenV3.new(key, secret)

  url_get = instance.signed_request('get', gamekey: 'test_key')
  url_submit = instance.signed_request('submit', gamekey: 'test_key', player: 'test', score: 100)
  url_delete = instance.signed_request('delete', gamekey: 'test_key', score_id: 123)

  assert.equal! url_get.include?("/v3/get?"), true
  assert.equal! url_submit.include?("/v3/submit?"), true
  assert.equal! url_delete.include?("/v3/delete?"), true
end

def test_purpletoken_v3_signature_hex_length(_args, assert)
  # Verify signature is always 64 hex characters (SHA-256)
  key = "test_key"
  secret = "test_secret"

  instance = TestPurpleTokenV3.new(key, secret)
  url = instance.signed_request('get', gamekey: 'test_key')

  # Extract signature (without using Regexp)
  params = url.split('?')[1]
  sig_param = params.split('&').find { |p| p.start_with?('sig=') }
  sig = sig_param.split('=', 2)[1]

  assert.equal! sig.nil?, false
  assert.equal! sig.length, 64
  assert.equal! sig, sig.downcase # Should be lowercase
end
