module HighScore
  class Request
    TICKS_BETWEEN_RETRIES = 60 # 1 second * 2 ** retries
    MAX_RETRIES = 8

    def initialize(url, &callback)
      @url = url
      @callback = callback

      @ticks = 0
      @retries = 0

      send_request
    end

    def tick
      @ticks += 1

      case @state
      when :busy
        check_request
      when :error
        send_request if @ticks > (2 ** @retries) * TICKS_BETWEEN_RETRIES # exponential backoff
      end
    end

    def check_request
      return unless @response.complete?

      if @response.success_code?
        @state = :success
        @callback.call(@response)
      else
        @state = :error
        @retries += 1
        @callback.call(@response) if @retries > MAX_RETRIES
      end
    end

    def send_request
      @state = :busy
      @response = Response.new(@url)
    end

    def done?
      @state == :success || @retries > MAX_RETRIES
    end

    class Response
      def initialize(url)
        @url = url
        @response = $gtk.http_get(url)
      end

      def complete?
        @response&.fetch(:complete, false) || false
      end

      def success?
        complete? && success_code?
      end

      def code
        @response&.fetch(:http_response_code, 0) || 0
      end

      def success_code?
        code >= 200 && code < 300
      end

      def body
        @response&.fetch(:response_data, nil) || nil
      end
    end
  end
end
