require 'pixel'

class Player < Pixel
  trait :timer
  attr_reader :energy, :max_energy

  MIN_CAPTURE_DISTANCE = SIZE * 6

  def max_health; 1000; end
  def speed; 1.6; end
  def damage; 5; end
  def safe_distance; SIZE * 4; end
  def initial_color; Color::BLUE; end

  MAX_ENERGY = 1000
  ENERGY_HEAL = 5

  def initialize(space, options = {})
    super(space, options)

    add_inputs(
      [:space, :return] => lambda { controlling? ? lose_control : gain_control }
    )

    @max_energy = @energy = MAX_ENERGY


    @hurt = Sample["hurt_player.wav"]
    @control_on = Sample["control_on.wav"]
    @control_off = Sample["control_off.wav"]
    @control_fail = Sample["control_fail.wav"]
    @death = Sample["death.wav"]

    shape.body.mass *= 2

    lose_control
  end

  def move_controlled
    if holding_any? :left, :a
      if holding_any? :up, :w
        @controlled.move(-0.707, -0.707)
      elsif holding_any? :down, :s
        @controlled.move(-0.707, 0.707)
      else
        @controlled.move(-1, 0)
      end
    elsif holding_any? :right, :d
      if holding_any? :up, :w
        @controlled.move(0.707, -0.707)
      elsif holding_any? :down, :s
        @controlled.move(0.707, 0.707)
      else
        @controlled.move(1, 0)
      end
    elsif holding_any? :up, :w
      @controlled.move(0, -1)
    elsif holding_any? :down, :s
      @controlled.move(0, 1)
    else
      @controlled.move(0, 0)
    end
  end

  def update
    super

    @shape.body.reset_forces # Ensure the player, even if they are controlling something else, has forces removed.
    move_controlled

    if controlling?
      self.energy -= @controlled.control_cost
    else
      self.energy += ENERGY_HEAL
    end
  end

  def draw
    super
    if controlling?
      $window.draw_line(self.x, self.y, self.color, @controlled.x, @controlled.y, @controlled.color, ZOrder::CONTROL)
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
    @death.play(0.5)
    super
  end

  def controlling?
    @controlled != self
  end

  def lose_control
    @controlled ||= self
    if @controlled != self
      @controlled.uncontrol
      @control_off.play(0.5)
    end
    @controlled = self
    color.red = color.green = 0
    self.energy = energy # Get colour back.
  end

  def gain_control
    nearest_distance = Float::INFINITY
    nearest_enemy = nil
    Enemy.all.each do |enemy|
      distance = distance(self.x, self.y, enemy.x, enemy.y)
      if distance < MIN_CAPTURE_DISTANCE and distance < nearest_distance
        nearest_distance = distance
        nearest_enemy = enemy
      end
    end

    if nearest_enemy
      @controlled = nearest_enemy
      @controlled.control(self)
      color.blue = color.red = color.green = 255 # Blueness shoots over to the enemy.
      @control_on.play(0.5)
    else
      @control_fail.play(0.5)
    end
  end
end