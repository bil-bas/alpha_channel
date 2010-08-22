class Level < GameState
  trait :timer

  def initialize(level)
    @level = level

    super()

    @player = Player.create(:x => $window.width / ($window.factor * 2), :y => $window.height / ($window.factor * 2))
    $window.score = 0 if @level == 1
    
    # Bad pixels.
    blockages = [@player]
    (4 + rand(4)).times do
      pos = $window.random_position(blockages)
      blockages << DeadPixel.create(:x => pos[0], :y => pos[1])
    end

    every([5000 - @level * 250, 1000].max) do
      pos = $window.random_position
      Enemy.create(:x => pos[0], :y => pos[1])
    end

    on_input(:p, GameStates::Pause)
    on_input(:f1) { push_game_state Help }

    @status = Text.create("", :x => 2, :y => 2, :zorder => ZOrder::OVERLAY, :color => 0xa0ffffff, :factor => 2)
    @level_label = Text.create("%04d" % @level, :x => 0, :y => 60, :zorder => ZOrder::LABEL, :color => 0xff00ff00, :factor => 22)
    @background_color = Color.new(255, 100, 255, 100)
  end

  def update
    super
    @status.text = "Health: %04d   Energy: %04d   Score: %04d  Level: %04d" %
            [@player.health, @player.energy, $window.score, @level]

    if @player.health == 0
      after(100) { push_game_state GameOver }
    elsif $window.score == @level * Enemy::SCORE * 3
      pop_game_state
      Sample["level.wav"].play
      push_game_state(GameStates::FadeTo.new(Level.new(@level + 1), :speed => 3))
    end

  end

  def draw
    super
    @status.draw
    @level_label.draw
    fill(@background_color, ZOrder::BACKGROUND)
  end
end