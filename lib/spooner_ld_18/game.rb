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

    @player = Player.create(:x => 75, :y => 50)
    Enemy.create(:x => 50, :y => 50)
    Enemy.create(:x => 100, :y => 50)

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
  trait :bounding_box, :debug => true
  traits :collision_detection, :retrofy

  attr_reader :health

  def health=(value)
    @health -= value
    if health <= 0
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

  def initialize(options = {})
    image = TexPlay.create_image($window, 8, 8, :color => :white)
    super(options.merge! :image => image)

    add_inputs(
      :holding_left => lambda { @controlled.left },
      :holding_right => lambda { @controlled.right },
      :holding_up => lambda { @controlled.up },
      :holding_down => lambda { @controlled.down }
    )

    @controlled = self

    @health = 100
    @energy = 99

    @speed = 0.5
  end

  def update
    super
    each_collision(Enemy) do |player, enemy|
      @health -= 1
      enemy.health -= 1
    end
  end
end

class Enemy < Character 
  def initialize(options = {})  
    image = TexPlay.create_image($window, 8, 8, :color => :red)
    super(options.merge! :image => image)

    @health = 40
    
    @speed = 1
  end
end

exit if defined? Ocra

Game.new.show