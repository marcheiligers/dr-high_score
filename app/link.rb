class Link
  attr_sprite
  attr_reader :width

  def initialize(x, y, text, url)
    @mouse_over = false
    @x = x
    @y = y
    @text = text
    @url = url

    @w, @h = $gtk.calcstringbox(text, font: '', size_px: 22)
  end

  def tick
    handle_mouse
  end

  def handle_mouse
    mouse = $args.inputs.mouse
    @mouse_over = mouse.inside_rect?(self)
    return unless @mouse_over

    $args.gtk.openurl(@url) if mouse.up
  end

  def draw_override(ffi)
    color = @mouse_over ? [34, 79, 24, 255] : [255, 255, 255, 255]

    ffi.draw_solid(@x, @y, @w, 2, *color)
    # ffi.draw_label_5 x, y, text, size_enum, alignment_enum, r, g, b, a, font, vertical_alignment_enum, blendmode_enum, size_px, angle_anchor_x, angle_anchor_y
    ffi.draw_label_5 @x, @y + @h / 2, @text, nil, 0, *color, '', 1, 1, 22, 0, 0.5
  end
end
