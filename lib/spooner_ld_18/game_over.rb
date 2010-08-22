class GameOver < GameState
  def initialize
    super

    @game_over_font = Font.new($window, FONT, 240)
    @info_font = Font.new($window, FONT, 36)

    @game_ended = $window.ms

    @words = $window.game_over ? ["HIGH", "SCORE"] : ["GAME", "OVER"]

    on_input(:f1) { push_game_state Help }
    on_input :r do
      Sample["level.wav"].play
      pop_game_state
      switch_game_state LevelTransition.new(1)
    end
  end

  def draw
    previous_game_state.draw
    super

    write_text(@game_over_font, @words[0], -10, @color)
    write_text(@game_over_font, @words[1],  200, @color)
    write_text(@info_font, "(R)estart", 420, Color.new(255, 220, 220, 220))
  end

  def write_text(font, text, y, color)
    x = 20 + ($window.width - font.text_width(text)) / 2
    font.draw(text, x, y, ZOrder::OVERLAY, 1, 1, color)
  end

  def update
    super
    $window.particles.each { |x| x.update_trait }
    @color =  Color::WHITE.dup
    @color.alpha = ((Math.cos(($window.ms - @game_ended) / 300.0) * 50) + 155).round
  end
end