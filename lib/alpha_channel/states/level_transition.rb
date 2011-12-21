class LevelTransition < GameState
  FADE_OUT_DURATION = 1.5
  FADE_IN_DURATION = 1.5

  def initialize(level, options = {})
    super options

    options = {
        died: false
    }.merge! options
    
    @new_level = Level.new(level, options)
    @overlay_color = Color.rgba(0, 0, 0, 0)
    @alpha = 0.0
    @fading = :out

    @sound = Sample["level.ogg"]
    @sound.play(0.5) unless options[:died]
  end

  # Ensure that particles keep moving.
  def update
    super

    if @fading == :in
      # Fade in.
      @alpha -= ($window.frame_time * 255) / FADE_IN_DURATION
      @overlay_color.alpha = @alpha

      pop_game_state if @alpha <= 0 or DEVELOPMENT_MODE
    else
      # Fade out.
      @alpha += ($window.frame_time * 255) / FADE_OUT_DURATION
      @overlay_color.alpha = @alpha

      if previous_game_state.respond_to? :update_particles
        previous_game_state.update_particles
      end

      if @alpha >= 255 or DEVELOPMENT_MODE
        game_state_manager.pop_until_game_state Menu
        push_game_state @new_level, setup: false
        push_game_state self, finalize: false
        @fading = :in
      end
    end
  end

  def draw
    if @fading == :in
      @new_level.draw
    else
      previous_game_state.draw
    end

    $window.pixel.draw 0, 0, ZOrder::GUI, $window.width, $window.height, @overlay_color
  end
end