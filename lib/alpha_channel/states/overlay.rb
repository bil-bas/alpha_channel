require_relative "screen"

class Overlay < Screen
  SHADOW_COLOR = Color.rgba 0, 0, 0, 0
  MAX_SHADOW_ALPHA = 175
  FADE_IN_DURATION = 1

  def initialize(inputs)
    super()

    on_input inputs.map {|i| :"released_#{i}"} do
      on_input inputs | [:escape] do
        close
      end
    end

    @color = SHADOW_COLOR.dup
  end

  def update
    super

    @color.alpha += ($window.frame_time * MAX_SHADOW_ALPHA) / FADE_IN_DURATION unless @color.alpha > MAX_SHADOW_ALPHA
  end

  def draw
    previous_game_state.draw
    super

    $window.flush
    $window.pixel.draw 0, 0, 0, $window.width, $window.height, @color
  end
end