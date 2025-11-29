module HighScore
  class PurpleTokenBase
    include BadCrypto # see below

    TICKS_BETWEEN_REFRESHES = 60 * 60 * 5 # 5 minutes

    attr_reader :scores, :position

    def initialize(scores = [])
      fill_scores(scores)
      @queue = []
      @ticks = 0
      @fetch_scores_in_flight = false

      fetch_scores # initial fetch
    end

    def fetch_scores
      return if @fetch_scores_in_flight # prevent multiple requests to fetch scores

      @ticks = 0
      @fetch_scores_in_flight = true

      url = build_url(:get)
      @queue << Request.new(url) do |response|
        @fetch_scores_in_flight = false
        if response.success?
          data = $gtk.parse_json(response.body) || {}
          if data.is_a?(Hash) && data['scores'].is_a?(Array)
            scores = data['scores']&.map { |score| { name: score['player'], score: score['score'] } } || []
            fill_scores(scores)
          else
            invalid_response(response)
          end
        else
          error_response(response)
        end
      end
    end

    def save_score(player, score)
      @position = @scores.index { |s| s.score < score }
      if @position
        @scores.insert(@position, { name: player, score: score })
        @scores = @scores[0..19]
      else
        return 20
      end

      url = build_url(:submit, player: player, score: score)
      @queue << Request.new(url) do |response|
        if response.success?
          fetch_scores
        else
          error_response(response)
        end
      end

      @position
    end

    def high_score?(score, top = 20)
      @scores[top - 1].score < score
    end

    def tick
      @queue.each(&:tick)
      @queue.reject!(&:done?)

      @ticks += 1
      fetch_scores if @ticks > TICKS_BETWEEN_REFRESHES
    end

  private

    def fill_scores(scores)
      @scores = scores + Array.new(20 - scores.length) { { name: '---', score: 0 } }
    end

    def error_response(response)
      puts "Error response from PurpleToken: #{response.code}"
      puts response.body
    end
  end

  class PurpleToken < PurpleTokenBase
    BASE_URI = 'https://purpletoken.com/update/v2/'.freeze
    ENDPOINTS = {
      get: { path: 'get_score/index.php', params: { format: 'json' } },
      submit: { path: 'submit_score/index.php', params: {} }
    }.freeze

    def initialize(key, scores = [])
      @key = decrypt(key)
      super(scores)

      puts "The PurpleToken high score API is provided for free by the kind person at Zimnox (https://www.zimnox.com/). " \
           "Please don't abuse this kindness. The gamekey is the key for this game. You could use this to post any score " \
           "you like, but where's the fun in that?"
    end

  private

    def build_url(endpoint, **params)
      ep = ENDPOINTS[endpoint]
      params_string = params.merge(gamekey: @key).merge(ep.params).map { |k, v| "#{k}=#{v}" }.join('&')
      "#{BASE_URI}#{ep.path}?#{params_string}"
    end

    def invalid_response(response)
      puts "Invalid response from PurpleToken: #{response.body}"
      puts 'Check that your gamekey is correct, marked as Legacy, and encrypted with BadCrypto.'
    end
  end

  class PurpleTokenV3 < PurpleTokenBase
    include Base64

    BASE_URI = 'https://purpletoken.com/update/v3/'.freeze
    ENDPOINTS = {
      get: { path: 'get', params: { format: 'json' } },
      submit: { path: 'submit', params: {} }
    }.freeze

    def initialize(key, secret, scores = [])
      @key = decrypt(key)
      @secret = decrypt(secret)
      super(scores)

      puts 'The PurpleToken high score API is provided for free by the kind person at ' \
           "Zimnox (https://www.zimnox.com/). Please don't abuse this kindness."
    end

  private

    def build_url(endpoint, **params)
      params_string = params.merge(gamekey: @key).map { |k, v| "#{k}=#{v}" }.join('&')
      payload = urlsafe_encode64(params_string)
      signature = SHA256.hexdigest(payload + @secret)

      "#{BASE_URI}#{endpoint}?payload=#{payload}&sig=#{signature}"
    end

    def invalid_response(response)
      puts "Invalid response from PurpleToken: #{response.body}"
      puts 'Check that your gamekey and secret are correct, and encrypted with BadCrypto.'
    end
  end
end
