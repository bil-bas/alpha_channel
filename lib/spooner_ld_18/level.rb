require 'wall'
require 'boss'
require 'pause_game'

class Level < GameState
  trait :timer

  LABEL_COLOR = Color.new(255, 0, 65, 0)
  SCAN_LINES_COLOR = Color.new(255, 0, 0, 0)
  BACKGROUND_COLOR = Color.new(255, 0, 40, 0)

  def initialize(level)
    @level = level

    super()

    # Set up Chipmunk physics.
    @space = CP::Space.new
    @space.damping = 0.05

    @player = Player.create(@space, :x => $window.width / 2, :y => $window.height / 2)
    $window.score = 0 if @level == 1
    
    # Bad pixels.
    blockages = [@player]
    (3 + rand(10)).times do
      pos = $window.random_position(blockages)
      blockages << DeadPixel.create(@space, :x => pos[0], :y => pos[1])
    end

    after(1000) { generate_enemy }

    on_input(:p, PauseGame)
    on_input(:f1) { push_game_state Help }
    on_input(:f12) { push_game_state GameOver }

    @score_font = Font.create_for_os(FONT, 120)
    @level_font = Font.create_for_os(FONT, 360)

    @num_kills = 0

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

    [
      [0, 0, 0, $window.height, :left],
      [0, $window.height, $window.width, $window.height, :bottom],
      [$window.width, $window.height, $window.width, 0, :right],
      [$window.width, 0, 0, 0, :top]
    ].each do |x1, y1, x2, y2, side|
      wall = Wall.create(@space, x1, y1, x2, y2, side)
    end

    @space.add_collision_func(:pixel, :wall) do |pixel_shape, side_shape|
      pixel = Pixel.all.find { |p| p.shape == pixel_shape }
      wall = Wall.all.find {|w| w.shape == side_shape }
      pixel.hit_wall(wall) if pixel and wall
      true # We always want a collision.
    end

    @dt = 1.0 / 60.0
  end

  def generate_enemy
    x, y = $window.random_position

    # Boss spawns on 5/10/15/20, only after you've killed someone.
    enemy_type = if (@level % 5) == 0 and @num_kills > 0 and Boss.all.empty?
      Boss # Only one boss at a time.
    else
      Enemy
    end

    enemy_type.create(@space, :x => x, :y => y)

    after(500 + rand([4000 - @level * 250, 250].max)) { generate_enemy }
  end

  def add_kills(value)
    @num_kills += value
  end

  def update
    super

    if @player.health == 0
      after(1000) { push_game_state GameOver if current_game_state == self }
    elsif Boss.all.empty? and @num_kills >= (@level / 3) + 4
      # Only win if the boss has been killed or enough reds are killed.
      $window.score += @level * 1000
      switch_game_state LevelTransition.new(@level + 1)
    end

    period = $window.milliseconds_since_last_tick / 1000.0
    @space.step period
  end

  def draw
    super
    fill(BACKGROUND_COLOR, ZOrder::BACKGROUND)

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

  def finalize
    game_objects.sync
  end
end