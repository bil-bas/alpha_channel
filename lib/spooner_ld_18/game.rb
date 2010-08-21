require 'rubygems' rescue nil

require 'chingu'
require 'texplay'

include Gosu
include Chingu

EDITOR_ENABLED = true

class Game < Window
  def initialize
    super(640, 480, false)
    self.caption = "Spooner LD 18 - Enemies as weapons"

  end

  def setup
    retrofy
    self.factor = 4 # So 160x120
    
    push_game_state Level.new(1)
  end
end

class Level < GameState
  attr_reader :game_object_map

  def initialize(level)
    @level = level
    
    super
    
    @file = File.join(ROOT_PATH, "#{self.class}_#{level}.yml")
    load_game_objects(:file => @file)

    @player = Player.create(:x => 75, :y => 100)
    (16..104).step(16) do |x|
      Enemy.create(:x => x, :y => 25)
    end

    on_input(:e, GameStates::Edit.new(:file => @file, :except => [Player]))

    @status = Text.create("Status", :x => 2, :y => 2, :color => 0xa0ffffff, :factor => 2)
  end

  def setup
    @game_object_map = GameObjectMap.new(:game_objects => Enemy.all)
  end

  def update
    super
    @status.text = "Health: %3d; Energy: %3d" % [@player.health, @player.energy]
  end

  def draw
    super
    @status.draw
    fill(Gosu::Color.new(255, 100, 255, 100), -999)
  end
end

class Character < GameObject
  trait :bounding_box, :debug => false, :scale => 0.25
  traits :collision_detection, :retrofy
  
  SIZE = 8

  attr_reader :health, :damage

  def health=(value)
    @health = value
    if @health <= 0
      @health = 0
      die
    end
  end

  def die
    destroy
  end

  def left
    self.x -= @speed
  end

  def right
    self.x += @speed
  end

  def up
    self.y -= @speed
  end

  def down
    self.y += @speed
  end
end

class Player < Character
  attr_reader :energy

  MIN_CAPTURE_DISTANCE = 40
  
  MAX_HEALTH, MAX_ENERGY = 100, 1000
  HEALTH_HEAL, ENERGY_HEAL = 1, 10
  CONTROL_COST = 2

  def initialize(options = {})
    super

    add_inputs(
      [:holding_left, :holding_a] => lambda { @controlled.left },
      [:holding_right, :holding_d] => lambda { @controlled.right },
      [:holding_up, :holding_w] => lambda { @controlled.up },
      [:holding_down, :holding_s] => lambda { @controlled.down },
      [:space, :return] => lambda { controlling? ? lose_control : gain_control }
    )

    lose_control

    @health = MAX_HEALTH
    @energy = MAX_ENERGY

    @speed = 1
    @damage = 1
  end

  def update
    super
    enemy = first_collision(Enemy)
    if enemy
      self.health -= enemy.damage
      enemy.health -= damage
    end

    if controlling?
      @energy -= CONTROL_COST
      if @energy <= 0
        @energy = 0
        lose_control
      end
    else
      if @energy < MAX_ENERGY
        @energy += ENERGY_HEAL
      end
    end
  end

  def controlling?
    @controlled != self
  end

  def lose_control
    @controlled ||= self
    @controlled.uncontrol if @controlled != self
    @controlled = self
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
    end
  end
end

class Enemy < Character
  def controlled?; @controlled; end

  def initialize(options = {})  
    super(options.merge! :image => image)

    @health = 40
    
    @speed = 0.5
    @damage = 1

    uncontrol
  end

  def control
    @controlled = true
    self.image = TexPlay.create_image($window, SIZE, SIZE, :color => :blue)
  end

  def uncontrol
    @controlled = false
    self.image = TexPlay.create_image($window, SIZE, SIZE, :color => :red)
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
        end
      end
    elsif player = Player.all.first     
      self.x -= @speed * (self.x - player.x) / (self.x - player.x).abs if self.x != player.x
      self.y -= @speed * (self.y - player.y) / (self.y - player.y).abs if self.y != player.y
    end
  end
end

exit if defined? Ocra

Game.new.show