class GameOver < GameState
  def initialize
    super
    Text.create("GAME OVER", :x => 35, :y => 130, :zorder => ZOrder::OVERLAY, :color => 0xa0ffffff, :factor => 8)
    Text.create("R to restart", :x => 50, :y => 230, :zorder => ZOrder::OVERLAY, :color => 0xa0ffffff, :factor => 8)

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