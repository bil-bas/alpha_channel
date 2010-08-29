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
    (3 + rand(10)).times do
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

    # Set up Chipmunk physics.
    @space = CP::Space.new
    @space.damping = 0.05

    blockages.each do |object|
      @space.add_body object.shape.body
      @space.add_shape object.shape
    end

    @space.add_collision_func(:pixel, :pixel) do |shape1, shape2|
      pixel1 = Pixel.all.find { |p| p.shape == shape1 }
      pixel2 = Pixel.all.find { |p| p.shape == shape2 }
      
      pixel1.fight(pixel2) if pixel1 and pixel2 and pixel1.hurts?(pixel2)

      true # We always want a collision.
    end

    @dt = 1.0 / 60.0
  end

  def generate_enemy
    pos = $window.random_position
    enemy = Enemy.create(:x => pos[0], :y => pos[1])
    
    @space.add_body enemy.shape.body
    @space.add_shape enemy.shape

    after(500 + rand([4000 - @level * 250, 500].max)) { generate_enemy }
  end

  def add_kill
    @num_kills += 1
  end

  def update
    super

    if @player.health == 0
      after(1000) { push_game_state GameOver if current_game_state == self }
    elsif @num_kills >= (@level / 3) + 4
      $window.score += @level * 1000
      switch_game_state LevelTransition.new(@level + 1)
    end

    period = $window.milliseconds_since_last_tick / 10000.0
    10.times { @space.step period }
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