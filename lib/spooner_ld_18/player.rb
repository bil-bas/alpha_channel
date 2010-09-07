require 'pixel'

class Player < Pixel
  trait :timer
  attr_reader :energy, :max_energy

  MIN_CAPTURE_DISTANCE = SIZE * 6
  INITIAL_COLOR = Color.new(255, 50, 50, 255)

  def max_health; 1000; end
  def force; 1.6; end
  def damage; 5; end
  def safe_distance; SIZE * 4; end
  def initial_color; INITIAL_COLOR; end
  def intensity; 1; end

  def self.image; @@image; end

  MAX_ENERGY = 1000
  ENERGY_HEAL = 5

  def initialize(space, options = {})
    super(space, options)

    add_inputs(
      [:space, :return] => lambda { controlling? ? lose_control : gain_control }
    )

    @max_energy = @energy = MAX_ENERGY


    @hurt = Sample["hurt_player.ogg"]
    @control_on = Sample["control_on.ogg"]
    @control_off = Sample["control_off.ogg"]
    @control_fail = Sample["control_fail.ogg"]
    @death = Sample["death.ogg"]

    shape.body.mass *= 2

    make_beam unless defined? @@beam

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
      distance = distance_to(@controlled)
      beam_color = Color.new(0, 0, 0, 0)
      color_self = color
      color_controlled = @controlled.color
      
      (1..distance).step(8) do |dist|
        controlled_proportion = dist / distance
        self_proportion = 1 - controlled_proportion
        x_pos = x + ((@controlled.x - x) * controlled_proportion)
        y_pos = y + ((@controlled.y - y) * controlled_proportion)

        beam_color.red = (color_self.red * self_proportion + color_controlled.red * controlled_proportion).to_i
        beam_color.blue = (color_self.blue * self_proportion + color_controlled.blue * controlled_proportion).to_i
        beam_color.green = (color_self.green * self_proportion + color_controlled.green * controlled_proportion).to_i
        beam_color.alpha = (color_self.alpha * self_proportion + color_controlled.alpha * controlled_proportion).to_i

        thickness = 1 + controlled_proportion * 2
        @@beam.draw(x_pos - (@@beam.width * thickness / 2), y_pos - (@@beam.width * thickness / 2), ZOrder::CONTROL,
                    thickness, thickness, beam_color, :additive)
      end
    end
  end

  def energy=(value)
    @energy = [[0, value].max, max_energy].min
    if controlling?
      lose_control if @energy == 0
    else
      color.blue = (((@energy * 205) / max_energy) + 50.0).to_i unless controlling?
      color.red = color.green = 50
    end
  end

  def die
    @death.play(0.5)
    lose_control
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
      color.blue = color.red = color.green = 75 # Blueness shoots over to the enemy.
      @control_on.play(0.5)
    else
      @control_fail.play(0.5)
    end
  end

  def make_beam
    @@beam = TexPlay.create_image($window, @@image.width, @@image.height)

    center = @@beam.width / 2
    radius =  @@beam.width / 2

    @@beam.circle center, center, radius, :color => :white, :filled => true,
      :color_control => lambda {|source, dest, x, y|
        distance = distance(center, center, x, y)
        dest[3] = ((1 - (distance / radius)) ** 2) / 2
        dest
    }
  end
end