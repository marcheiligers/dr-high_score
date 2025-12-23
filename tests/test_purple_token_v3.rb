# Mock PurpleTokenV3 to access private methods for testing
class TestPurpleTokenV3 < HighScore::PurpleTokenV3
  def signed_request(endpoint, **params)
    build_url(endpoint, params)
  end
end

# Override so the tests don't send requests to PurpleToken
if $gtk.getenv('SDL_VIDEODRIVER') == 'dummy'
  module HighScore
    class Request
      class Response
        def initialize(url)
          @url = url
          puts "Test Response for #{url}"
        end
      end
    end
  end
end

def test_purpletoken_v3_signed_request_format(_args, assert)
  key = HighScore::BadCrypto.encrypt('test_key')
  secret = HighScore::BadCrypto.encrypt('test_secret')

  instance = TestPurpleTokenV3.new(key, secret)
  url = instance.signed_request(:get)

  assert.true! url.start_with?('https://purpletoken.com/update/v3/get?')
  assert.true! url.include?('payload=')
  assert.true! url.include?('sig=')
end

def test_purpletoken_v3_payload_encoding(_args, assert)
  key = HighScore::BadCrypto.encrypt('test_key')
  secret = HighScore::BadCrypto.encrypt('test_secret')

  instance = TestPurpleTokenV3.new(key, secret)
  url = instance.signed_request(:get)

  _, params = url.split('?')
  payload_param = params.split('&').find { |p| p.start_with?('payload=') }
  _, payload = payload_param.split('=', 2)

  assert.false! payload.nil?

  decoded = Base64.decode64(payload)
  assert.true! decoded.include?('gamekey=test_key')
  assert.true! decoded.include?('format=json')
end

def test_purpletoken_v3_signature_generation(_args, assert)
  key = HighScore::BadCrypto.encrypt('test_key')
  secret = HighScore::BadCrypto.encrypt('test_secret')

  instance = TestPurpleTokenV3.new(key, secret)
  url = instance.signed_request(:get)
  _, params = url.split('?')
  param_parts = params.split('&')

  payload_param = param_parts.find { |p| p.start_with?('payload=') }
  sig_param = param_parts.find { |p| p.start_with?('sig=') }

  _, payload = payload_param.split('=', 2)
  _, sig = sig_param.split('=')

  assert.false! payload.nil?
  assert.false! sig.nil?
  assert.equal! sig.length, 64 # SHA256 hex is 64 characters
  expected_sig = SHA256.hexdigest(payload + 'test_secret')
  assert.equal! sig, expected_sig
end

def test_purpletoken_v3_api_example(_args, assert)
  # Test with the exact example from v3api.txt
  # params are specifically ordered so we can test the example Purple Token provides
  key = HighScore::BadCrypto.encrypt('c5f4a0474223a4cc0c93d68a7c80cc541d05b90c')
  secret = HighScore::BadCrypto.encrypt('fuzzy bunnies')

  instance = TestPurpleTokenV3.new(key, secret)
  url = instance.signed_request(:get, array: 'yes', dates: 'yes', ids: 'yes')

  params = url.split('?')[1]
  param_parts = params.split('&')

  payload_param = param_parts.find { |p| p.start_with?('payload=') }
  sig_param = param_parts.find { |p| p.start_with?('sig=') }

  payload = payload_param.split('=', 2)[1]
  sig = sig_param.split('=', 2)[1]

  assert.equal! payload.nil?, false
  assert.equal! sig.nil?, false

  expected_payload = 'Z2FtZWtleT1jNWY0YTA0NzQyMjNhNGNjMGM5M2Q2OGE3YzgwY2M1NDFkMDViOTBjJmZvcm1hdD1qc29uJmFycmF5PXllcyZkYXRlcz15ZXMmaWRzPXllcw=='
  assert.equal! payload, expected_payload

  expected_sig = 'dcb260adda344e82daa9ffa2f7a03aebca101b9afd4fa327a83ce8c20c30d8ee'
  assert.equal! sig, expected_sig
end

def test_purpletoken_v3_endpoints(_args, assert)
  key = 'test_key'
  secret = 'test_secret'

  instance = TestPurpleTokenV3.new(key, secret)

  url_get = instance.signed_request(:get)
  url_submit = instance.signed_request(:submit, player: 'test', score: 100)

  assert.true! url_get.include?('/v3/get?')
  assert.true! url_submit.include?('/v3/submit?')
end
