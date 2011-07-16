require 'wall'
require 'boss'
require 'the_anti_pixel'
require 'vampire_pixel'
require 'shooter_pixel'
require 'omni_pixel'
require 'pause_game'

class Level < GameState
  trait :timer

  attr_reader :level, :player

  LABEL_COLOR = Color.new(255, 0, 65, 0)
  SCAN_LINES_COLOR = Color.new(255, 0, 0, 0)
  BACKGROUND_COLOR = Color.new(255, 0, 40, 0)
  
  BOSS_LEVELS =  {
          4 => Boss,
          8 => VampirePixel,
          12 => ShooterPixel,
          16 => TheAntiPixel,
          20 => OmniPixel,
  }

  INITIAL_LEVEL = 1
  LAST_LEVEL = 20

  def initialize(level, options = {})
    options = { :died => false }.merge! options
    
    @level = level
    @died = options[:died]

    super()

    # Set up Chipmunk physics.
    @space = CP::Space.new
    @space.damping = 0.05

    @player = Player.create(@space, :x => $window.width / 2, :y => $window.height / 2)

    # Bad pixels.
    blockages = [@player]
    (3 + rand(10)).times do
      pos = $window.random_position(blockages)
      blockages << DeadPixel.create(@space, :x => pos[0], :y => pos[1])
    end

    after(1000) { generate_enemy }

    on_input(:p, PauseGame)
    on_input([:f1, :h], Help)

    # Switch to boss levels (debugging).
    (1..5).each do |button|
      on_input :"#{button}" do       
        switch_game_state LevelTransition.new(button * 4) if holding?(:left_control)
      end
    end

    @score_font = Font.create_for_os(FONT, 120)
    @level_font = Font.create_for_os(FONT, 360)

    @num_kills = 0

    blockages.each do |object|
      @space.add_body object.shape.body
      @space.add_shape object.shape
    end

    @space.add_collision_func(:pixel, :pixel) do |shape1, shape2|
      pixels = game_objects.of_class(Pixel)
      pixel1 = pixels.find { |p| p.shape == shape1 }
      pixel2 = pixels.find { |p| p.shape == shape2 }

      if pixel1 and pixel2
        pixel1.fight(pixel2) if  pixel1.hurts?(pixel2)
        pixel1.solid? and pixel2.solid? # Only collide if both are solid.
      else
        false # Either pixel has already been destroyed, so don't collide.
      end
    end

    [
      [0, 0, 0, $window.height, :left],
      [0, $window.height, $window.width, $window.height, :bottom],
      [$window.width, $window.height, $window.width, 0, :right],
      [$window.width, 0, 0, 0, :top]
    ].each do |x1, y1, x2, y2, side|
      wall = Wall.create(@space, x1, y1, x2, y2, side)
    end

    @space.add_collision_func(:pixel, :wall) do |pixel_shape, side_shape|
      pixel = game_objects.of_class(Pixel).find { |p| p.shape == pixel_shape }
      wall = Wall.all.find {|w| w.shape == side_shape }
      pixel.hit_wall(wall) if pixel and wall
      true # We always want a collision.
    end
  end
  
  def setup
    if @died
      $window.lives -= 1
    elsif @level == INITIAL_LEVEL
      $window.score = 0
      $window.lives = Game::INITIAL_LIVES
    end
  end
  
  def finalize
    game_objects.each(&:destroy)
  end

  def generate_enemy
    x, y = $window.random_position

    # Boss spawns on 5/10/15/20, only after you've killed someone.
    enemy_type = if BOSS_LEVELS[@level] and @num_kills > 0 and Boss.all.empty?
      BOSS_LEVELS[@level] # Only one boss at a time.
    else
      Enemy
    end

    enemy_type.create(@space, :x => x, :y => y)

    # Spawn faster per level, but slower if boss is out. 
    after(500 + rand(4000 - @level * 150 + (Boss.all.empty? ? 0 : 2000))) { generate_enemy }
  end

  def add_kills(value)
    @num_kills += value
  end

  def update
    super

    if @player.health == 0
      if $window.lives == 1
        after(1000) { push_game_state GameOver if current_game_state == self }
      else
        switch_game_state(LevelTransition.new(@level, :died => true))
      end
    elsif Boss.all.empty? and @num_kills >= (@level / 4) + 5
      # Only win if the boss has been killed or enough reds are killed.
      $window.score += @level * 1000
      $window.lives += 1 if BOSS_LEVELS[@level]
      switch_game_state LevelTransition.new(@level + 1)
    end

    period = $window.milliseconds_since_last_tick / 1000.0
    @space.step period

	game_objects.of_class(Pixel).each {|p| p.shape.body.reset_forces }
  end

  def draw
    super
    fill(BACKGROUND_COLOR, ZOrder::BACKGROUND)

    # Draw the current number of lives.
    life_color = Player::INITIAL_COLOR.dup
    life_color.alpha = (life_color.alpha * 0.35).to_i

    # Remaining lives are shown as a block.
    spare_lives = $window.lives - 1
    left = ($window.width - spare_lives * Player::SIZE * 2) / 2.0 
    spare_lives.times do |i|
      Player.image.draw left + (i * 2 * Player::SIZE), - Player::SIZE / 4, ZOrder::LIVES, 1.5, 1, LABEL_COLOR
    end

    #
    write_text(@score_font, "%08d" % $window.score, 36)
    write_text(@level_font, "%02d" % @level, 92)
    write_text(@score_font, "%08d" % $window.high_score, 344)

    # Draw scan-lines over both.
    (0..$window.height).step(4) do |y|
      $window.draw_line(0, y, SCAN_LINES_COLOR, $window.width, y, SCAN_LINES_COLOR, ZOrder::SCAN_LINES)
    end
  end

  def write_text(font, text, y)
    x = ($window.width - font.text_width(text)) / 2
    font.draw(text, x, y, ZOrder::LABEL, 1, 1, LABEL_COLOR)
  end
end