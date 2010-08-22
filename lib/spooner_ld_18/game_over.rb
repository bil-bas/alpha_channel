class GameOver < GameState
  def initialize
    super
    @game_over = Text.create("GAME OVER", :x => 0, :y => 0, :zorder => ZOrder::OVERLAY, :max_width => $window.width / 16, :align => :center, :line_spacing => 0, :color => Color::WHITE.dup, :factor => 16)
    @restart = Text.create("(R)estart", :x => 0, :y => $window.height / 2 - 32, :zorder => ZOrder::OVERLAY, :max_width => $window.width / 4, :align => :center, :color => Color.new(255, 220, 220, 220), :factor => 4)

    @game_ended = $window.ms

    on_input(:f1) { push_game_state Help }
    on_input :r do
      Sample["level.wav"].play
      pop_game_state
      pop_game_state
      push_game_state(GameStates::FadeTo.new(Level.new(1), :speed => 2))
    end
  end

  def draw
    previous_game_state.draw
    super
  end

  def update
    super
    previous_game_state.game_objects.select { |x| x.is_a? Particle }.each { |x| x.update_trait }
    @game_over.alpha = ((Math.sin(($window.ms - @game_ended) / 300.0) * 50) + 155).round
  end
end