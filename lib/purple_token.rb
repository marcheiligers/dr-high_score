module HighScore
  class PurpleToken
    include BadCrypto # see below

    BASE_URI = 'https://purpletoken.com/update/v2/'
    TICKS_BETWEEN_REFRESHES = 60 * 60 * 5 # 5 minutes

    attr_reader :scores, :position

    def initialize(key, scores = [])
      @key = decrypt(key)

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

      url = "#{BASE_URI}get_score/index.php?gamekey=#{@key}&format=json"
      @queue << Request.new(url) do |response|
        @fetch_scores_in_flight = false
        return unless response[:http_response_code] == 200

        data = $gtk.parse_json(response[:response_data]) || {}
        @scores = data['scores']&.map { |score| { name: score['player'], score: score['score'] } } || []
        @scores += Array.new(20 - scores.length) { { name: '---', score: 0 } }
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

      url = "#{BASE_URI}submit_score/index.php?gamekey=#{@key}&player=#{player}&score=#{score}"
      @queue << Request.new(url) do |response|
        return unless response[:http_response_code] == 200

        fetch_scores
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
  end
end
