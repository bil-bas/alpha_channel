class Level < GameState
  trait :timer

  LABEL_COLOR = 0xff00ff00

  def initialize(level)
    @level = level

    super()

    @player = Player.create(:x => $window.width / 2, :y => $window.height / 2)
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
    on_input(:f12) { push_game_state GameOver }

    @score_font = Font.create_for_os(FONT, 120)
    @level_font = Font.create_for_os(FONT, 240)
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

    if @player.health == 0
      after(1000) { push_game_state GameOver if current_game_state == self }
    elsif @num_kills >= @level + 3
      $window.score += @level * 1000
      switch_game_state LevelTransition.new(@level + 1)
    end

  end

  def draw
    super
    fill(@background_color, ZOrder::BACKGROUND)

    write_text(@score_font, "%08d" % $window.score, 40)
    write_text(@level_font, "%04d" % @level, 140)
    write_text(@score_font, "%08d" % $window.high_score, 340)
  end

  def write_text(font, text, y)
    x = ($window.width - font.text_width(text)) / 2
    font.draw(text, x, y, ZOrder::LABEL, 1, 1, LABEL_COLOR)
  end

  def finalize
    game_objects.sync
  end
end