class G::Window < G::Widget

  @wm_window : Wm::Window? = nil
  getter wm_window

  @main_widget : G::Widget? = nil
  getter main_widget

  def main_widget=(@main_widget : G::Widget)
    @main_widget.not_nil!.app = @app
  end

  def initialize(@x : Int32, @y : Int32,
                 @width : Int32, @height : Int32,
                 @flags = Wm::IPC::Data::WindowFlags::None)
  end

  def bitmap
    @wm_window.not_nil!.bitmap
  end

  def setup_event
    if @wm_window.nil?
      @wm_window = app.client.create_window(@x, @y, @width, @height, @flags).not_nil!
    end
  end

  def io_event(io : IO::FileDescriptor)
    if main_widget = @main_widget
      main_widget.io_event io
    end
  end

  def wm_message_event(ev : Wm::IPC::Message)
    if main_widget = @main_widget
      main_widget.wm_message_event ev
    end
  end

  def mouse_event(ev : G::MouseEvent)
    if main_widget = @main_widget
      main_widget.mouse_event ev
    end
  end

  def key_event(ev : G::KeyboardEvent)
    if main_widget = @main_widget
      main_widget.key_event ev
    end
  end

  def draw_event
    if main_widget = @main_widget
      main_widget.draw_event
      unless main_widget.bitmap.null?
        Painter.blit_img bitmap, @width, @height,
                         main_widget.bitmap,
                         main_widget.width, main_widget.height,
                         0, 0
      end
    end
  end

end