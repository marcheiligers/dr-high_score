class Scroller
  attr_sprite

  def initialize(multiline)
    @multiline = multiline
    @mouse_down = false
    @x = @multiline.x + @multiline.w + 20
    @y = @multiline.y
    @w = 20
    @h = @multiline.h
  end

  def tick
    @x = @multiline.x + @multiline.w + 20
    @y = @multiline.y
    @h = @multiline.h
    handle_mouse
  end

  def handle_mouse
    mouse = $args.inputs.mouse
    @mouse_over = mouse.inside_rect?(self)
    return if @multiline.content_h < @multiline.h

    th = thumb_rect
    if !@mouse_down && mouse.down && @mouse_over
      if mouse.inside_rect?(th)
        @mouse_offset_y = th.y - mouse.y
        @mouse_down = true
      elsif mouse.y < th.y
        @multiline.scroll_y -= @multiline.h
      else
        @multiline.scroll_y += @multiline.h
      end
    elsif @mouse_down
      @mouse_down = false if mouse.up
      max = @h - th.h
      pos = (mouse.y - @y + @mouse_offset_y).cap_min_max(0, max)
      @multiline.scroll_y = (pos / max) * (@multiline.scroll_h - @h)
    end
  end

  def thumb_rect
    if @multiline.content_h < @h
      { x: @x, y: @y, w: @w, h: @h }
    else
      { x: @x, y: (@multiline.scroll_y / @multiline.scroll_h) * @h + @y, w: @w, h: (@h / @multiline.scroll_h) * @h }
    end
  end

  def draw_override(ffi)
    ffi.draw_solid(@x, @y, @w, @h, 14, 18, 35, 255)

    color = @mouse_down || @mouse_over ? [35, 14, 18, 255] : [2, 7, 30, 255]
    ffi.draw_solid(*thumb_rect.values, *color)
  end
end
