class GameOver < GameState
  def initialize
    super
    is_high = $window.game_over
    label = is_high ? "HIGH SCORE" : "GAME OVER"

    @game_over = Text.create(label, :x => 0, :y => 20, :zorder => ZOrder::OVERLAY, :max_width => $window.width / 14, :align => :center, :line_spacing => 0, :color => Color::WHITE.dup, :factor => 14)
    @restart = Text.create("(R)estart", :x => 0, :y => $window.height / 2 - 45, :zorder => ZOrder::OVERLAY, :max_width => $window.width / 4, :align => :center, :color => Color.new(255, 220, 220, 220), :factor => 4)
    
    @game_ended = $window.ms

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
  end

  def update
    super
    $window.particles.each { |x| x.update_trait }
    @game_over.alpha = ((Math.cos(($window.ms - @game_ended) / 300.0) * 50) + 155).round
  end
end