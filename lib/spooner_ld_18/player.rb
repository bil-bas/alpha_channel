require 'pixel'

class Player < Pixel
  trait :timer
  attr_reader :energy, :max_energy

  MIN_CAPTURE_DISTANCE = 50

  MAX_HEALTH, MAX_ENERGY = 1000, 1000
  ENERGY_HEAL = 5
  ENERGY_CONTROL = 3

  def initialize(options = {})
    super({:color => Color::BLUE.dup}.merge! options)

    add_inputs(
      [:space, :return] => lambda { controlling? ? lose_control : gain_control }
    )

    @last_health = @max_health = @health = MAX_HEALTH
    @max_energy = @energy = MAX_ENERGY

    @speed = 0.5
    @damage = 5

    @hurt = Sample["hurt_player.wav"]
    @control_on = Sample["control_on.wav"]
    @control_off = Sample["control_off.wav"]
    @control_fail = Sample["control_fail.wav"]
    @death = Sample["death.wav"]

    lose_control
  end

  def move_controlled
    if holding_any? :left, :a
      if holding_any? :up, :w
        @controlled.left(0.707)
        @controlled.up(0.707)
      elsif holding_any? :down, :s
        @controlled.left(0.707)
        @controlled.down(0.707)
      else
        @controlled.left
      end
    elsif holding_any? :right, :d
      if holding_any? :up, :w
        @controlled.right(0.707)
        @controlled.up(0.707)
      elsif holding_any? :down, :s
        @controlled.right(0.707)
        @controlled.down(0.707)
      else
        @controlled.right
      end
    elsif holding_any? :up, :w
      @controlled.up
    elsif holding_any? :down, :s
      @controlled.down
    end

  end

  def update
    super

    move_controlled

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
        $window.draw_line(self.x, self.y, self.color, @controlled.x, @controlled.y, @controlled.color, ZOrder::CONTROL)
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
    @death.play
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