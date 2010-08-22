require 'rubygems' rescue nil

require 'chingu'

require 'yaml' # required for ocra.

include Gosu
include Chingu

module ZOrder
  BACKGROUND, LABEL, PIXEL, CONTROL, PARTICLES, OVERLAY = (0..100).to_a
end

INSTALL_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
media_dir =  File.join(INSTALL_DIR, 'media')
Image.autoload_dirs << File.join(media_dir)
Sample.autoload_dirs << File.join(media_dir)

ENV['PATH'] = "#{File.join(INSTALL_DIR, 'bin')};#{ENV['PATH']}"

class Game < Window
  def initialize
    super(640, 480, false)

    on_input(:q) { close if holding_any? :left_control, :right_control }
  end

  def setup
    retrofy
    self.factor = 4 # So 160x120

    Sample["level.wav"].play
    push_game_state(GameStates::FadeTo.new(Level.new(1), :speed => 2))
  end

  def random_position(extra_objects = [])
    min_distance = {Player => 30, DeadPixel => 25, Enemy => 20}
    all = Player.all + Enemy.all + DeadPixel.all + extra_objects
    loop do
      pos = [rand(($window.width / $window.factor) - 16) + 8, rand(($window.height / $window.factor) - 16) + 8]
      too_close = false
      all.each do |other|
        if distance(*pos, other.x, other.y) < min_distance[other.class]
          too_close = true
          break
        end
      end
      return pos unless too_close
    end
  end

  def update
    super
    self.caption = "PIXHELL (spooner.github.com LD 18 - 'Enemies as weapons') [FPS: #{fps}]"
  end
end



class Level < GameState
  trait :timer

  def initialize(level)
    @level = level
    
    super()

    @player = Player.create(:x => $window.width / ($window.factor * 2), :y => $window.height / ($window.factor * 2))

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

    on_input(:f1) { help }
    on_input(:p, GameStates::Pause)
    
    @status = Text.create("", :x => 2, :y => 2, :zorder => ZOrder::OVERLAY, :color => 0xa0ffffff, :factor => 2)
    @level_label = Text.create("%04d" % @level, :x => 0, :y => 60, :zorder => ZOrder::LABEL, :color => 0xff00ff00, :factor => 22)
    @background_color = Color.new(255, 100, 255, 100)
  end

  def update
    super
    @status.text = "Health: %04d   Energy: %04d   Score: %04d  Level: %04d" %
            [@player.health, @player.energy, @player.score, @level]

    if @player.health == 0
      after(100) { push_game_state GameOver } 
    elsif @player.score == @level * 20 + 20
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

  def help
    text =<<END_TEXT

    === PIXHELL (Spooner's LD-18 game: "Enemies as weapons") ===

    It is hell being a pixel. Why can't they all just get along?

    = Controls =

      * Arrow keys or WASD: Move self (or a controlled Red).

      * Space or Return: Take/relinquish control of Red.
           
      * P: Pause

      * Control+Q: Exit game.

    = How to play =

      * Red is evil; Red wants to hurt you!

      * Take control of Red, when it comes near, and use it to protect yourself from the other Reds!

      * Controlling Red is strenuous and will use up your limited energy reserves (Blueness).

      * All colours hurt colours that aren't the same. Green isn't too painful, though :)


    (Escape to close this help)
END_TEXT

    push_game_state GameStates::Popup.new(:text => text)
  end
end

class GameOver < GameState
  def initialize
    super
    Text.create("GAME OVER", :x => 35, :y => 130, :zorder => ZOrder::OVERLAY, :color => 0xa0ffffff, :factor => 8)
    Text.create("R to restart", :x => 50, :y => 230, :zorder => ZOrder::OVERLAY, :color => 0xa0ffffff, :factor => 8)
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

class Pixel < GameObject
  trait :bounding_box, :debug => false, :scale => 0.25
  traits :collision_detection, :retrofy
  
  SIZE = 8

  attr_reader :health, :damage, :max_health, :last_health

  def initialize(options = {})
    options = {:image => Image["pixel.png"]}.merge! options
    super(options)
  end

  def health=(value)
    @health = [[0, value].max, max_health].min
    self.alpha = ((@health * 155.0 / max_health) + 100).to_i
    die if @health == 0
  end

  def update
    super
    @last_health = @health
  end

  def die
    # Fall apart.
    half_width = width / (2 * $window.factor)
    ((x - half_width)...(x + half_width)).step(width / (4 * $window.factor)) do |x|
      ((y - half_width)...(y + half_width)).step(width / (4 * $window.factor)) do |y|
        PixelFragment.create(:x => x, :y => y, :color => color)
      end
    end

    destroy
  end

  def hurts?(enemy)
    enemy.class != self.class
  end

  def fight(enemy)
    if self.hurts?(enemy)
      self.health -= enemy.damage if health == last_health
      enemy.health -= damage if enemy.health == enemy.last_health
      @hurt.play
    end
  end

  def colliding_with_obstacle?
    each_bounding_box_collision(Player, Enemy, DeadPixel) do |me, obstacle|
      return obstacle if me != obstacle
    end
    return nil
  end

  def left
    self.x = [x - @speed, 0 + screen_width / 8].max
    if enemy = colliding_with_obstacle? then self.x = enemy.x + SIZE + 0.001; fight(enemy); end
  end

  def right
    self.x = [x + @speed, $window.width / $window.factor - screen_width / 8].min
    if enemy = colliding_with_obstacle? then self.x = enemy.x - SIZE - 0.001; fight(enemy); end
  end

  def up
    self.y = [y - @speed, 0 + screen_width / 8].max
    if enemy = colliding_with_obstacle? then self.y = enemy.y + SIZE + 0.001; fight(enemy); end
  end

  def down
    self.y = [y + @speed, $window.height / $window.factor - screen_width / 8].min
    if enemy = colliding_with_obstacle? then self.y = enemy.y - SIZE - 0.001; fight(enemy); end
  end
end

class Player < Pixel
  trait :timer
  attr_reader :energy, :max_energy
  attr_accessor :score

  MIN_CAPTURE_DISTANCE = 50
  
  MAX_HEALTH, MAX_ENERGY = 1000, 1000
  ENERGY_HEAL = 5
  ENERGY_CONTROL = 3

  def initialize(options = {})
    super({:color => Color::BLUE.dup}.merge! options)

    add_inputs(
      [:holding_left, :holding_a] => lambda { @controlled.left },
      [:holding_right, :holding_d] => lambda { @controlled.right },
      [:holding_up, :holding_w] => lambda { @controlled.up },
      [:holding_down, :holding_s] => lambda { @controlled.down },
      [:space, :return] => lambda { controlling? ? lose_control : gain_control }
    )

    @last_health = @max_health = @health = MAX_HEALTH
    @max_energy = @energy = MAX_ENERGY

    @speed = 0.5
    @damage = 10
    @score = 0

    @hurt = Sample["hurt_player.wav"]
    @control_on = Sample["control_on.wav"]
    @control_off = Sample["control_off.wav"]
    @control_fail = Sample["control_fail.wav"]

    lose_control
  end

  def update
    super

    if controlling?      
      self.energy -= ENERGY_CONTROL
    else
      self.energy += ENERGY_HEAL
    end
  end

  def draw
    super
    if controlling?
      $window.scale($window.factor) do
        $window.draw_line(self.x, self.y, @controlled.color, @controlled.x, @controlled.y, self.color, ZOrder::CONTROL)
      end
    end
  end

  def energy=(value)
    @energy = [[0, value].max, max_energy].min
    if controlling?
      lose_control if @energy == 0
    else
      color.blue = (((@energy * 155.0) / max_energy) + 100).to_i unless controlling?
      color.red = color.green = 255 - color.blue
    end 
  end

  def die
    Sample["death.wav"].play
    super
  end

  def controlling?
    @controlled != self
  end

  def lose_control
    @controlled ||= self
    if @controlled != self
      @controlled.uncontrol
      @control_off.play
    end
    @controlled = self
    color.red = color.green = 0
    self.energy = energy # Get colour back.
  end

  def gain_control
    nearest_distance = 99999999
    nearest_enemy = nil
    Enemy.all.each do |enemy|
      distance = distance(self.x, self.y, enemy.x, enemy.y)
      if distance < MIN_CAPTURE_DISTANCE and not self.collides?(enemy) and distance < nearest_distance
        nearest_distance = distance
        nearest_enemy = enemy
      end
    end

    if nearest_enemy
      @controlled = nearest_enemy
      @controlled.control(self)
      color.blue = color.red = color.green = 255 # Blueness shoots over to the enemy.
      @control_on.play
    else
      @control_fail.play
    end
  end
end

class Enemy < Pixel
  def controlled?; not @controller.nil?; end

  def initialize(options = {})
    options = { :color => Color::RED.dup, :max_health => 400 }.merge! options
    super options

    @last_health = @max_health = @health = 400
    
    @speed = 0.3
    @damage = 10

    @hurt = Sample["hurt_controlled.wav"]
    uncontrol
  end

  def control(controller)
    @controller = controller
    color.red = 0
  end

  def uncontrol
    @controller = nil
    color.red = 255
    color.blue = 0
  end

  def die
    if player = Player.all.first       
      player.lose_control if controlled?     
      player.score += 10 
    end

    super
  end

  def hurts?(enemy)
    super or ((enemy.class == self.class) and (controlled? or enemy.controlled?))
  end

  def update
    super

    if controlled?
      color.blue = (((@controller.energy * 155.0) / @controller.max_energy) + 100).to_i
      color.red = 255 - color.blue
      # You now damage other enemies.
      each_collision(Enemy) do |me, enemy|
        if enemy != self
          self.health -= enemy.damage
          enemy.health -= damage
          @hurt.play
        end
      end
    else
      # Don't move if wounded.
      if health == last_health and player = Player.all.first
        # Home in on the player's location.
        left if player.x < x
        right if player.x > x
        up if player.y < y
        down if player.y > y
     end
    end
  end
end

class DeadPixel < Pixel
  def initialize(options = {})
    super({:color => Color.new(255, 0, 180, 0)}.merge! options )
    @original_health = @max_health = @health = 5000
    @damage = 2
  end
end

class PixelFragment < Particle
  traits :retrofy, :velocity

  def initialize(options = {})
    x = rand 360
    velocity_x, velocity_y = Math.cos(x), Math.sin(x)
    options = {
      :velocity_x => velocity_x * (0.2 + rand(0.1)),
      :velocity_y => velocity_y * (0.2 + rand(0.1)),
      :zorder => ZOrder::PARTICLES,
      :image => "pixel_fragment.png",
      :scale_rate => -0.1,
      :fade_rate => 0,
      :rotation_rate => 1 - rand(2),
      :mode => :default
    }.merge! options
    
    super options
  end

  def update
    super

    destroy if outside_window? or factor_x <= 0.1
  end
end

exit if defined? Ocra

Game.new.show