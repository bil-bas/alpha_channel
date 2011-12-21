require_relative "screen"

class GameOver < Screen
  def initialize
    super
    @game_over_font = Font.create_for_os(FONT, 240)
    @info_font = Font.create_for_os(FONT, 36)

    @game_ended = milliseconds

    @words = $window.high_score? ? %w[HIGH SCORE] : %w[GAME OVER]
    @color = GAME_OVER_COLOR

    on_input(KEYS[:help]) { push_game_state Help.new(KEYS[:help]), finalize: false }
    on_input :r do
      pop_game_state
      switch_game_state LevelTransition.new(Level::INITIAL_LEVEL)
    end
    on_input :q do
      $window.close
    end

    @entered_name = false
  end

  def draw
    previous_game_state.draw
    super

    write_text(@game_over_font, @words[0], 80, @color, zorder: ZOrder::GUI)
    write_text(@game_over_font, @words[1],  200, @color, zorder: ZOrder::GUI)
    write_text(@info_font, "(R)estart or (Q)uit", OPTIONS_Y, OPTIONS_COLOR, zorder: ZOrder::GUI)
  end

  def update
    if $window.high_score? and not @entered_name
      @entered_name = true
      push_game_state EnterName
    else
      super
      previous_game_state.update_particles
      @color.alpha = ((Math.cos((milliseconds - @game_ended) / 300.0) * 80) + 100).round
    end
  end
end