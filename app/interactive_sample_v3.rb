require 'lib/high_score.rb'
require_relative 'json.rb'
require_relative 'input.rb'
require_relative 'button.rb'
require_relative 'link.rb'
require_relative 'scroller.rb'

PURPLE_TOKEN_KEY = 'enpmlnnlpl$snkplpcnadohpdt?dnnht!scdt!k!'
PURPLE_TOKEN_SECRET = 'TopUH1PPpz[}{#9s+N#'

def init(args)
  Input.replace_console!
  args.state.purple_token ||= HighScore::PurpleTokenV3.new(PURPLE_TOKEN_KEY, PURPLE_TOKEN_SECRET)

  # Create some widgets
  args.state.widgets ||= [
    args.state.name_input = Input::Text.new(
      x: 20,
      y: 540,
      w: 300,
      text_color: 0xFFFFFF,
      background_color: 0x230E12,
      blurred_color: 0x02071E,
      cursor_color: 0xEDC525,
      focussed: true,
      on_unhandled_key: lambda do |key, input|
        case key
        when :tab
          input.blur
          args.state.score_input.focus
        when :enter
          submit(args)
        end
      end,
      on_clicked: lambda do |_mouse, input|
        args.state.widgets.each { |widget| widget.blur if widget.respond_to?(:blur) }
        input.focus
      end,
      max_length: 40
    ),
    args.state.score_input = Input::Text.new(
      x: 20,
      y: 470,
      w: 300,
      text_color: 0xFFFFFF,
      background_color: 0x230E12,
      blurred_color: 0x02071E,
      cursor_color: 0xEDC525,
      on_unhandled_key: lambda do |key, input|
        case key
        when :tab
          input.blur
          args.state.name_input.focus
        when :enter
          submit(args)
        end
      end,
      on_clicked: lambda do |_mouse, input|
        args.state.widgets.each { |widget| widget.blur if widget.respond_to?(:blur) }
        input.focus
      end,
    ),
    Button.new(220, 420, 100, 30, 'Submit', -> { submit(args) }),
    args.state.key_input = Input::Text.new(
      x: 20,
      y: 290,
      w: 220,
      text_color: 0xFFFFFF,
      background_color: 0x230E12,
      blurred_color: 0x02071E,
      cursor_color: 0xEDC525,
      on_unhandled_key: lambda do |key, input|
        case key
        when :tab
          input.blur
          args.state.secret_input.focus
          args.state.secret_input.select_all
        when :enter
          encrypt_and_use(args)
        end
      end,
      on_clicked: lambda do |_mouse, input|
        args.state.widgets.each { |widget| widget.blur if widget.respond_to?(:blur) }
        input.focus
      end,
    ),
    args.state.secret_input = Input::Text.new(
      x: 260,
      y: 290,
      w: 220,
      text_color: 0xFFFFFF,
      background_color: 0x230E12,
      blurred_color: 0x02071E,
      cursor_color: 0xEDC525,
      on_unhandled_key: lambda do |key, input|
        case key
        when :tab
          input.blur
          args.state.encrypted_key_input.focus
          args.state.encrypted_key_input.select_all
        when :enter
          encrypt_and_use(args)
        end
      end,
      on_clicked: lambda do |_mouse, input|
        args.state.widgets.each { |widget| widget.blur if widget.respond_to?(:blur) }
        input.focus
      end,
    ),
    Button.new(400, 240, 100, 30, 'Use', -> { encrypt_and_use(args) }),
    args.state.encrypted_key_input = Input::Text.new(
      x: 20,
      y: 180,
      w: 220,
      text_color: 0xFFFFFF,
      background_color: 0x230E12,
      blurred_color: 0x02071E,
      cursor_color: 0xEDC525,
      readonly: true,
      on_unhandled_key: lambda do |key, input|
        case key
        when :tab
          input.blur
          args.state.encrypted_secret_input.focus
          args.state.encrypted_secret_input.select_all
        when :enter
          encrypt_and_use(args)
        end
      end,
      on_clicked: lambda do |_mouse, input|
        args.state.widgets.each { |widget| widget.blur if widget.respond_to?(:blur) }
        input.focus
        input.select_all
      end,
    ),
    args.state.encrypted_secret_input = Input::Text.new(
      x: 260,
      y: 180,
      w: 220,
      text_color: 0xFFFFFF,
      background_color: 0x230E12,
      blurred_color: 0x02071E,
      cursor_color: 0xEDC525,
      readonly: true,
      on_unhandled_key: lambda do |key, input|
        case key
        when :tab
          input.blur
          args.state.key_input.focus
          args.state.key_input.select_all
        when :enter
          encrypt_and_use(args)
        end
      end,
      on_clicked: lambda do |_mouse, input|
        args.state.widgets.each { |widget| widget.blur if widget.respond_to?(:blur) }
        input.focus
        input.select_all
      end,
    ),
    Link.new(20, 50, 'Code', 'https://github.com/marcheiligers/dr-high_score'),
    Link.new(80, 50, 'Releases', 'https://github.com/marcheiligers/dr-high_score/releases'),
    Link.new(180, 50, 'Purple Token', 'https://purpletoken.com'),
    args.state.score_display ||= Input::Multiline.new(
      x: 660,
      y: 40,
      w: 560,
      h: 640,
      value: args.state.purple_token.scores.to_json(indent_size: 2),
      selection_start: 0,
      size_px: 20,
      text_color: 0xFFFFFF,
      background_color: 0x230E12,
      blurred_color: 0x02071E,
      cursor_color: 0xEDC525,
      readonly: true,
      on_unhandled_key: lambda do |key, input|
        if key == :tab
          input.blur
          args.state.name_input.focus
        end
      end,
      on_clicked: lambda do |_mouse, input|
        args.state.widgets.each { |widget| widget.blur if widget.respond_to?(:blur) }
        input.focus
      end
    ),
    Scroller.new(args.state.score_display)
  ]
end

def submit(args)
  if args.state.name_input.value.to_s == ''
    args.gtk.notify! "Enter a name"
  elsif args.state.score_input.value.to_s.to_i == 0
    args.gtk.notify! "Enter a valid score"
  else
    args.state.purple_token.save_score(
      args.state.name_input.value.to_s,
      args.state.score_input.value.to_s.to_i
    )
  end
end

def encrypt_and_use(args)
  key = args.state.key_input.value.to_s
  secret = args.state.secret_input.value.to_s
  if key.length != PURPLE_TOKEN_KEY.length
    args.gtk.notify! "Enter a valid key"
  elsif secret == ''
    args.gtk.notify! "Enter a valid secret"
  else
    encrypted_key = HighScore::BadCrypto.encrypt(key)
    encrypted_secret = HighScore::BadCrypto.encrypt(secret)
    args.state.purple_token = HighScore::PurpleToken.new(encrypted_token, encrypted_secret)
    args.state.encrypted_key_input.value = encrypted_key
    args.state.encrypted_secret_input.value = encrypted_secret
  end
end

def tick(args)
  init(args) if args.tick_count == 0

  # Allow the widgets to process inputs and prepare to render (render_target)
  args.state.widgets.each(&:tick)
  args.state.purple_token.tick

  args.outputs.background_color = [15, 19, 36] #0F1324 from Purple token

  json = args.state.purple_token.scores.to_json(indent_size: 2)
  args.state.score_display.value = json if args.state.score_display.value != json

  # Output the widgets
  args.outputs.primitives << args.state.widgets
  args.outputs.solids << [
    { x: 20, y: 645, w: 620, h: 3, r: 255, g: 255, b: 255 },
    { x: 20, y: 400, w: 620, h: 2, r: 255, g: 255, b: 255 },
    { x: 20, y: 130, w: 620, h: 2, r: 255, g: 255, b: 255 },
  ]
  args.outputs.labels << [
    { x: 20, y: 680, text: 'dr-high_score - using Purple Token', r: 255, g: 255, b: 255, size_px: 32 },
    { x: 20, y: 630, text: 'Save a score', r: 255, g: 255, b: 255, size_px: 28 },
    { x: 20, y: 590, text: 'Name', r: 255, g: 255, b: 255 },
    { x: 20, y: 520, text: 'Score', r: 255, g: 255, b: 255 },
    { x: 20, y: 380, text: 'Use your own key and secret', r: 255, g: 255, b: 255, size_px: 28 },
    { x: 20, y: 340, text: 'Key', r: 255, g: 255, b: 255 },
    { x: 20, y: 230, text: 'Encrypted key', r: 255, g: 255, b: 255 },
    { x: 260, y: 340, text: 'Secret', r: 255, g: 255, b: 255 },
    { x: 260, y: 230, text: 'Encrypted secret', r: 255, g: 255, b: 255 },
    { x: 20, y: 110, text: 'Links', r: 255, g: 255, b: 255, size_px: 28 },
  ]
end
