require_relative 'purple_token/request'
require_relative 'base64'
require_relative 'sha256'

module HighScore
  class PurpleTokenV3
    include BadCrypto # see util.rb

    BASE_URI = 'https://purpletoken.com/update/v3/'
    TICKS_BETWEEN_REFRESHES = 60 * 60 * 5 # 5 minutes

    attr_reader :scores, :position

    def initialize(key, secret, scores = [])
      @key = decrypt(key)
      @secret = decrypt(secret)

      scores ||= []
      @scores = scores + Array.new(20 - scores.length) { { name: '---', score: 0 } }
      @queue = []
      @ticks = 0
      @fetch_scores_in_flight = false

      puts "The PurpleToken high score API is provided for free by the kind person at Zimnox (https://www.zimnox.com/). " \
           "Please don't abuse this kindness. The gamekey is the key for this game. You could use this to post any score " \
           "you like, but where's the fun in that?"

      fetch_scores # initial fetch
    end

    def fetch_scores
      return if @fetch_scores_in_flight # prevent multiple requests to fetch scores

      @ticks = 0
      @fetch_scores_in_flight = true

      url = build_signed_request('get', gamekey: @key, format: 'json', array: 'yes')
      @queue << PurpleTokenRequest.new(url) do |response|
        @fetch_scores_in_flight = false
        return unless response[:http_response_code] == 200

        data = $gtk.parse_json(response[:response_data]) || []
        @scores = data.map { |score| { name: score['player'], score: score['score'] } }
        @scores += Array.new(20 - @scores.length) { { name: '---', score: 0 } }
      end
    end

    def save_score(player, score)
      @position = @scores.index { |s| s[:score] < score }
      if @position
        @scores.insert(@position, { name: player, score: score })
        @scores = @scores[0..19]
      else
        return 20
      end

      url = build_signed_request('submit', gamekey: @key, player: player, score: score)
      @queue << PurpleTokenRequest.new(url) do |response|
        return unless response[:http_response_code] == 200

        fetch_scores
      end

      @position
    end

    def high_score?(score, top = 20)
      @scores[top - 1][:score] < score
    end

    def tick
      @queue.each(&:tick)
      @queue.reject!(&:done?)

      @ticks += 1
      fetch_scores if @ticks > TICKS_BETWEEN_REFRESHES
    end

    private

    # Build a signed request for the v3 API
    # endpoint: 'get', 'submit', or 'delete'
    # params: hash of query parameters (without gamekey, which is added automatically)
    def build_signed_request(endpoint, params = {})
      # Build the params string
      params_string = params.map { |k, v| "#{k}=#{v}" }.join('&')

      # Encode to Base64 (URL-safe, no padding)
      payload = Base64.urlsafe_encode64(params_string)

      # Create signature: SHA256(payload + secret)
      signature = SHA256.hexdigest(payload + @secret)

      # Build the final URL
      "#{BASE_URI}#{endpoint}?payload=#{payload}&sig=#{signature}"
    end
  end
end
