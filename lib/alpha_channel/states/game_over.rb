require_relative "screen"

class GameOver < Screen
  def initialize
    super

    @game_over_font = Font.create_for_os(FONT, 240)
    @info_font = Font.create_for_os(FONT, 36)

    @game_ended = milliseconds

    @words = $window.game_over ? ["HIGH", "SCORE"] : ["GAME", "OVER"]

    @color = GAME_OVER_COLOR

    $window.lives = 0

    on_input(KEYS[:help]) { push_game_state Help.new(KEYS[:help]), finalize: false }
    on_input :r do
      pop_game_state
      switch_game_state LevelTransition.new(Level::INITIAL_LEVEL)
    end
    on_input :q do
      $window.close
    end
  end

  def draw
    previous_game_state.draw
    super

    write_text(@game_over_font, @words[0], 80, @color, zorder: ZOrder::GUI)
    write_text(@game_over_font, @words[1],  200, @color, zorder: ZOrder::GUI)
    write_text(@info_font, "(R)estart or (Q)uit", OPTIONS_Y, OPTIONS_COLOR, zorder: ZOrder::GUI)
  end

  def update
    super
    previous_game_state.update_particles
    @color.alpha = ((Math.cos((milliseconds - @game_ended) / 300.0) * 80) + 100).round
  end
end