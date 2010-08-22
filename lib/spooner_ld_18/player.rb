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