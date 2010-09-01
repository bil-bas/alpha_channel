class GameOver < GameState
  MAIN_COLOR = Color.new(255, 175, 225, 175)
  OPTIONS_COLOR = Color.new(255, 125, 150, 125)

  def initialize
    super

    @game_over_font = Font.create_for_os(FONT, 240)
    @info_font = Font.create_for_os(FONT, 36)

    @game_ended = $window.ms

    @words = $window.game_over ? ["HIGH", "SCORE"] : ["GAME", "OVER"]

    @color = MAIN_COLOR

    $window.lives = 0

    on_input([:f1, :h], Help)
    on_input :r do
      pop_game_state
      switch_game_state LevelTransition.new(1)
    end
    on_input :q do
      $window.close
    end
  end

  def draw
    previous_game_state.draw
    super

    write_text(@game_over_font, @words[0], 80, @color)
    write_text(@game_over_font, @words[1],  200, @color)
    write_text(@info_font, "(R)estart or (Q)uit", 430, OPTIONS_COLOR)
  end

  def write_text(font, text, y, color)
    x = ($window.width - font.text_width(text)) / 2
    font.draw(text, x, y, ZOrder::OVERLAY, 1, 1, color)
  end

  def update
    super
    $window.particles.each { |x| x.update_trait; x.update }
    @color.alpha = ((Math.cos(($window.ms - @game_ended) / 300.0) * 80) + 100).round
  end
end