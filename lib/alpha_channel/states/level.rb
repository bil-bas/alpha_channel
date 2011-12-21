require_relative 'screen'

require_relative '../wall'
require_relative '../objects/boss'
require_relative '../objects/the_anti_pixel'
require_relative '../objects/vampire_pixel'
require_relative '../objects/shooter_pixel'
require_relative '../objects/omni_pixel'
require_relative 'pause_game'

class Level < Screen
  trait :timer

  attr_reader :level, :player, :pixels, :particles

  MAX_SCORE_WIDTH = 8
  
  BOSS_LEVELS =  {
          4 => Boss,
          8 => VampirePixel,
          12 => ShooterPixel,
          16 => TheAntiPixel,
          20 => OmniPixel,
  }

  INITIAL_LEVEL = 1
  LAST_LEVEL = 20

  PHYSICS_STEP = 1 / 240.0

  def initialize(level, options = {})
    options = {
        died: false,
    }.merge! options
    
    @level = level
    $window.level = level

    @died = options[:died]

    super()

    init_physics

    @pixels = []
    @particles = Set.new

    @player = Player.new(@space, x: $window.width / 2, y: $window.height / 2)
    (3 + rand(10)).times { DeadPixel.new(@space) }

    after(1000) { generate_enemy }

    on_input(KEYS[:pause]) { push_game_state PauseGame.new(KEYS[:pause]) }
    on_input(KEYS[:help]) { push_game_state Help.new(KEYS[:help]) }

    # Switch to boss levels (debugging).
    if DEVELOPMENT_MODE
      (1..5).each do |button|
        on_input :"#{button}" do
          switch_game_state Level.new(button * 4) if holding?(:left_control)
        end
      end
      on_input :x do
        @player.health = 0
      end
    end

    @level_font = Font.create_for_os(FONT, 360)
    @num_kills = 0
  end

  def remove_pixel(pixel)
    @pixels.delete pixel
  end

  def add_pixel(pixel)
    @pixels << pixel
  end

  def add_particle(particle)
    @particles << particle
  end

  def remove_particle(particle)
    @particles.delete particle
  end

  def update_particles
    @particles.each {|x| x.update_trait; x.update }
  end

  def init_physics
    # Set up Chipmunk physics.
    @space = CP::Space.new
    @space.damping = 0.05

    @space.on_collision(Pixel, Pixel) do |pixel1, pixel2|
      pixel1.fight(pixel2) if pixel1.hurts?(pixel2)
      pixel1.solid? and pixel2.solid? # Only collide if both are solid.
    end

    # Walls are just there for physics. Don't need to be updated or drawn; just kept.
    @walls = []
    [
      [0, 0, 0, $window.height, :left],
      [0, $window.height, $window.width, $window.height, :bottom],
      [$window.width, $window.height, $window.width, 0, :right],
      [$window.width, 0, 0, 0, :top]
    ].each do |x1, y1, x2, y2, side|
      @walls << Wall.new(@space, x1, y1, x2, y2, side)
    end

    @space.on_collision(Pixel, Wall) do |pixel, wall|
      pixel.hit_wall(wall)
      true # We always want a collision.
    end

    @physics_time = 0.0 # The amount of time we have backlogged for physics.
  end
  
  def setup
    if @died
      $window.lives -= 1
    elsif @level == INITIAL_LEVEL
      $window.score = 0
      $window.lives = Game::INITIAL_LIVES
    end
  end

  def boss_on_level?
    pixels.any?(&:boss?)
  end

  def generate_enemy
    # Boss spawns on 5/10/15/20, only after you've killed someone.
    if BOSS_LEVELS[@level] and @num_kills > 0 and not boss_on_level?
      BOSS_LEVELS[@level].new(@space) # Only one boss at a time.
    else
      Enemy.new(@space)
    end

    # Spawn faster per level, but slower if boss is out. 
    after(500 + rand(4000 - @level * 150 + (boss_on_level? ? 2000 : 0))) { generate_enemy }
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
        switch_game_state(LevelTransition.new(@level, died: true))
      end
    elsif not boss_on_level? and @num_kills >= (@level / 4) + 5
      # Only win if the boss has been killed or enough reds are killed.
      $window.score += @level * 1000
      $window.lives += 1 if BOSS_LEVELS[@level]
      switch_game_state LevelTransition.new(@level + 1)
    else
      update_particles
      # reset the forces on all objects before applying new ones.
      @pixels.each(&:reset_forces)
      @pixels.each(&:update)

      @physics_time += $window.frame_time
      num_steps = (@physics_time / PHYSICS_STEP).round
      @physics_time -= num_steps * PHYSICS_STEP
      num_steps.times { @space.step PHYSICS_STEP }
    end
  end

  def draw
    super
    draw_background

    # Draw the current number of lives.
    life_color = Player::INITIAL_COLOR.dup
    life_color.alpha = (life_color.alpha * 0.35).to_i

    # Remaining lives are shown as a block.
    spare_lives = $window.lives - 1
    left = ($window.width - spare_lives * Player::SIZE * 2) / 2.0 
    spare_lives.times do |i|
      $window.pixel.draw left + (i * 2 * Player::SIZE), - Player::SIZE / 4, ZOrder::LIVES, Player::SIZE * 1.5, Player::SIZE, BACKGROUND_LABEL_COLOR
    end

    write_text(@@score_font, "%0#{MAX_SCORE_WIDTH}d" % $window.score, 36, BACKGROUND_LABEL_COLOR)
    write_text(@level_font, "%02d" % @level, 92, BACKGROUND_LABEL_COLOR)

    draw_high_score
    draw_scan_lines

    @particles.each(&:draw)
    @pixels.each(&:draw)
  end
end