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

    after(1000) { generate_enemy }

    on_input(:p, GameStates::Pause)
    on_input(:f1) { push_game_state Help }

    @score_label = Text.create("%08d" % $window.score, :x => 0, :y => 15, :zorder => ZOrder::LABEL, :max_width => $window.width / 11, :align => :center, :color => 0xff00ff00, :factor => 11)
    @level_label = Text.create("%04d" % @level, :x => 10, :y => 120, :zorder => ZOrder::LABEL, :max_width => $window.width / 22, :align => :center, :color => 0xff00ff00, :factor => 22)
    @background_color = Color.new(255, 100, 255, 100)

    @num_kills = 0
  end

  def generate_enemy
    pos = $window.random_position
    Enemy.create(:x => pos[0], :y => pos[1])
    after(1000 + rand([5000 - @level * 500, 1000].max)) { generate_enemy }
  end

  def add_kill
    @num_kills += 1
  end

  def update
    super

    @score_label.text = "%08d" % $window.score

    if @player.health == 0
      push_game_state GameOver
    elsif @num_kills >= @level + 3
      Sample["level.wav"].play
      switch_game_state GameStates::FadeTo.new(Level.new(@level + 1), :speed => 3)
    end

  end

  def draw
    super
    fill(@background_color, ZOrder::BACKGROUND)
  end
end