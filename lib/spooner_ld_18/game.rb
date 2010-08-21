require 'rubygems' rescue nil

require 'chingu'
require 'texplay'

require 'yaml' # required for ocra.

include Gosu
include Chingu

EDITOR_ENABLED = true

module ZOrder
  ENEMY, PLAYER, CONTROLLED, OVERLAY = (0..100).to_a
end

INSTALL_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
media_dir =  File.join(INSTALL_DIR, 'media')
Image.autoload_dirs << File.join(media_dir)
Sample.autoload_dirs << File.join(media_dir)

ENV['PATH'] = "#{File.join(INSTALL_DIR, 'bin')};#{ENV['PATH']}"

class Game < Window
  def initialize
    super(640, 480, false)
    self.caption = "Spooner LD 18 - Enemies as weapons"

    on_input(:q) { close if holding_any? :left_control, :right_control }
  end

  def setup
    retrofy
    self.factor = 4 # So 160x120
    
    push_game_state Level.new(1)
  end

  def update
    super
    self.caption = current_game_state.class
  end
end

class Level < GameState
  trait :timer
  attr_reader :game_object_map

  def initialize(level)
    @level = level
    
    super()
    
    @file = File.join(ROOT_PATH, "#{self.class}_#{level}.yml")
    load_game_objects(:file => @file)

    @player = Player.create(:x => 75, :y => 100)

    every(3000) { Enemy.create(:x => rand($window.width / $window.factor), :y => rand($window.height / $window.factor)) }

    #on_input(:e, GameStates::Edit.new(:file => @file, :except => [Player]))
    on_input(:f1) { help }
    
    @status = Text.create("Status", :x => 2, :y => 2, :zorder => ZOrder::OVERLAY, :color => 0xa0ffffff, :factor => 2)
  end

  def setup
    @game_object_map = GameObjectMap.new(:game_objects => Enemy.all)
  end

  def update
    super
    @status.text = "Health: %3d; Energy: %3d" % [@player.health, @player.energy]
    after(1) { $window.push_game_state GameOver } if @player.health == 0
  end

  def draw
    super
    @status.draw
    fill(Gosu::Color.new(255, 100, 255, 100), -999)
  end

  def help
    text =<<END_TEXT

    === Spooner's LD-18 game: "Enemies as weapons" ===

    Escape to close this help

    = Controls =

      * Arrow keys or WASD: Move White (or Blue).

      * Space or Return: Take control of Red / Relinquish control of Blue.

      * Control+Q: Exit game.

    = How to play =

      * White is good!

      * Red is evil; It will hurt White!

      * Take control of Red, when it comes near, to make it Blue and be able to move it!

      * Blue hurts Red! It also hurts Grey :(

      * While controlling, White will become Grey, but Red will still hurt it.

      * Controlling Blue is strenuous and will use up your limited energy reserves.
END_TEXT

    push_game_state GameStates::Popup.new(:text => text)
  end
end

class GameOver < GameState
  def initialize
    super
    Text.create("GAME OVER", :x => 35, :y => 150, :zorder => ZOrder::OVERLAY, :color => 0xa0ffffff, :factor => 8)
    Text.create("R to restart", :x => 190, :y => 250, :zorder => ZOrder::OVERLAY, :color => 0xa0ffffff, :factor => 4)
    on_input(:r) { pop_game_state; pop_game_state; push_game_state(Level.new(1) )}
  end

  def draw
    previous_game_state.draw
    super
  end
end

class Character < GameObject
  trait :bounding_box, :debug => false, :scale => 0.22
  traits :collision_detection, :retrofy
  
  SIZE = 8

  attr_reader :health, :damage, :max_health

  def health=(value)
    @health = [[0, value].max, max_health].min
    die if @health == 0
  end

  def die
    destroy
  end

  def left
    self.x = [x - @speed, 0].max
  end

  def right
    self.x = [x + @speed, $window.width / $window.factor].min
  end

  def up
    self.y = [y - @speed, 0].max
  end

  def down
    self.y = [y + @speed, $window.height / $window.factor].min
  end
end

class Player < Character
  trait :timer
  attr_reader :energy, :max_energy

  MIN_CAPTURE_DISTANCE = 50
  
  MAX_HEALTH, MAX_ENERGY = 1000, 1000
  HEALTH_HEAL, ENERGY_HEAL = 10, 5
  ENERGY_CONTROL = 5

  def initialize(options = {})
    super({:zorder => ZOrder::PLAYER }.merge! options)

    add_inputs(
      [:holding_left, :holding_a] => lambda { @controlled.left },
      [:holding_right, :holding_d] => lambda { @controlled.right },
      [:holding_up, :holding_w] => lambda { @controlled.up },
      [:holding_down, :holding_s] => lambda { @controlled.down },
      [:space, :return] => lambda { controlling? ? lose_control : gain_control }
    )

    lose_control

    @max_health = @health = MAX_HEALTH
    @max_energy = @energy = MAX_ENERGY

    @speed = 1
    @damage = 10

    @hurt = Sample["hurt_player.wav"]
    @control_on = Sample["control_on.wav"]
    @control_off = Sample["control_off.wav"]
    @control_fail = Sample["control_fail.wav"]
  end

  def update
    super
    enemy = first_collision(Enemy)
    if enemy
      self.health -= enemy.damage
      enemy.health -= damage
      @hurt.play
    end

    if controlling?      
      self.energy -= ENERGY_CONTROL
    else
      self.energy += ENERGY_HEAL
    end
  end

  def energy=(value)
    @energy = [[0, value].max, @max_energy].min
    lose_control if @energy == 0
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
      @controlled = self
      @control_off.play
    end
    self.image = TexPlay.create_image($window, SIZE, SIZE, :color => :white)
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
      @controlled.control
      self.image = TexPlay.create_image($window, SIZE, SIZE, :color => Color.new(255, 128, 128, 128))
      @control_on.play
    else
      @control_fail.play
    end
  end
end

class Enemy < Character
  def controlled?; @controlled; end

  def initialize(options = {})  
    super(options.merge! :image => image)

    @last_health = @max_health = @health = 400
    
    @speed = 0.5
    @damage = 10

    @hurt = Sample["hurt_controlled.wav"]
    uncontrol
  end

  def control
    @controlled = true
    self.image = TexPlay.create_image($window, SIZE, SIZE, :color => :blue)
    self.zorder = ZOrder::CONTROLLED
  end

  def uncontrol
    @controlled = false
    self.image = TexPlay.create_image($window, SIZE, SIZE, :color => :red)
    self.zorder = ZOrder::ENEMY
  end

  def die
    if controlled?
      uncontrol
      Player.all.first.lose_control if Player.all.first
    end
    super
  end

  def update
    super

    if controlled?
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
      if @health == @last_health and player = Player.all.first
        # Home in on the player's location.
        self.x -= @speed * (self.x - player.x) / (self.x - player.x).abs if self.x != player.x
        self.y -= @speed * (self.y - player.y) / (self.y - player.y).abs if self.y != player.y
      end
      @last_health = @health
    end
  end
end

exit if defined? Ocra

Game.new.show