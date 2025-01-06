class Button
  attr_sprite
  attr_reader :on_clicked

  def initialize(x, y, w, h, text, on_clicked)
    @mouse_over = false
    @x = x
    @y = y
    @w = w
    @h = h
    @text = text
    @on_clicked = on_clicked
  end

  def tick
    handle_mouse
  end

  def handle_mouse
    mouse = $args.inputs.mouse
    @mouse_over = mouse.inside_rect?(self)
    return unless @mouse_over

    @on_clicked.call if mouse.up
  end

  def draw_override(ffi)
    if @mouse_over
      ffi.draw_solid(@x, @y, @w, @h, 34, 79, 24, 255)
    else
      ffi.draw_solid(@x, @y, @w, @h, 18, 35, 14, 255)
    end
    # ffi.draw_label_5 x, y, text, size_enum, alignment_enum, r, g, b, a, font, vertical_alignment_enum, blendmode_enum, size_px, angle_anchor_x, angle_anchor_y
    ffi.draw_label_5 @x + @w / 2, @y + @h / 2, @text, nil, 1, 255, 255, 255, 255, '', 1, 1, 22, 0.5, 0.5
  end
end
