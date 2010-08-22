class GameOver < GameState
  def initialize
    super
    Text.create("GAME OVER", :x => 0, :y => 0, :zorder => ZOrder::OVERLAY, :max_width => $window.width / 16, :align => :center, :line_spacing => 0, :color => 0xffffffff, :factor => 16)
    Text.create("(R)estart", :x => 0, :y => $window.height / 2 - 32, :zorder => ZOrder::OVERLAY, :max_width => $window.width / 4, :align => :center, :color => 0xffffffff, :factor => 4)

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
  end
end