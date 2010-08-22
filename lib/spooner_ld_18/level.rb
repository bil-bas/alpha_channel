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

    @score_label = Text.create("%08d" % $window.score, :x => 0, :y => 15, :zorder => ZOrder::LABEL, :max_width => $window.width / 11, :align => :center, :color => 0xff00ff00, :factor => 11)
    @level_label = Text.create("%04d" % @level, :x => 10, :y => 120, :zorder => ZOrder::LABEL, :max_width => $window.width / 22, :align => :center, :color => 0xff00ff00, :factor => 22)
    @background_color = Color.new(255, 100, 255, 100)
  end

  def update
    super

    $window.score += 0.02 * @level
    @score_label.text = "%08d" % $window.score

    if @player.health == 0
      push_game_state GameOver
    elsif $window.score == @level * Enemy::SCORE * 4
      pop_game_state
      Sample["level.wav"].play
      push_game_state(GameStates::FadeTo.new(Level.new(@level + 1), :speed => 3))
    end

  end

  def draw
    super
    fill(@background_color, ZOrder::BACKGROUND)
  end
end