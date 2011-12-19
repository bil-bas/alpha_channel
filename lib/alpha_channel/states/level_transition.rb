class LevelTransition < GameState
  TRANSITION_DURATION = 3000.0 # 3s to fade in/out.
  FADE_OUT_DURATION = TRANSITION_DURATION / 2
  FADE_IN_DURATION = TRANSITION_DURATION / 2

  def initialize(level, options = {})
    super options

    options = { :died => false }.merge! options
    
    @new_level = Level.new(level, options)
    @overlay_color = Color.rgba(0, 0, 0, 0)
    @previous_time = milliseconds
    @fading = :out

    @@sound ||= Sample["level.ogg"]
    @@sound.play(0.5) unless options[:died]
  end

  # Ensure that particles keep moving.
  def update
    super

    $window.particles.each { |x| x.update_trait; x.update }

    time_expended = [milliseconds - @previous_time, 100].min

    if @fading == :in
      # Fade in.
      @overlay_color.alpha -= (time_expended * 255) / FADE_IN_DURATION

      pop_game_state if @overlay_color.alpha <= 0
    else
      # Fade in.
      @overlay_color.alpha += (time_expended * 255) / FADE_OUT_DURATION

      if @overlay_color.alpha >= 255
        game_state_manager.pop_until_game_state Menu
        push_game_state @new_level, setup: false
        push_game_state self, finalize: false
        @fading = :in
      end
    end

    @previous_time = milliseconds
  end

  def draw
    if @fading == :in
      @new_level.draw
    else
      previous_game_state.draw
    end

    $window.flush
    $window.pixel.draw 0, 0, 0, $window.width, $window.height, @overlay_color
  end
end