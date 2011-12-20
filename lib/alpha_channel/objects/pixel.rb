class Pixel < GameObject
  INITIAL_HEALTH = 10
  PHASE_IN_DURATION = 3 # Number of ms to phase in over.
  SIZE = 32
  HURT_SOUND_DELAY = 50 # ms between hurting sounds.

  attr_reader :health, :last_health, :shape

  def exists?; @exists; end
  def controlled?; false; end
  def solid?; true; end
  def safe_distance; SIZE * 2; end
  def distance_to(other); distance(x, y, other.x, other.y); end
  def boss?; false; end
  def alive?; @health > 0; end
  def dead?; @health == 0; end
  def player?; false; end

  def play_hurt
    if milliseconds - @played_hurt_at > HURT_SOUND_DELAY
      @hurt.play(0.15)
      @played_hurt_at = milliseconds
    end
  end

  # The color a pixel glows is based on its colour affected by
  # its intensity, since some colours naturally glow more.
  def glow_color
    glow = color.dup
    glow.alpha = (color.alpha * intensity).to_i
    glow
  end

  # All pixels auto-heal up to maximum when they are spawned in.
  def auto_heal
    if @amount_left_to_heal > 0
      heal_amount = @amount_to_heal * $window.frame_time / PHASE_IN_DURATION
      @amount_left_to_heal -= heal_amount
      heal_amount
    else
      0
    end
  end

  def initialize(space, options = {})
    @space = space

    options = {
        image: $window.pixel,
        factor: SIZE,
        zorder: ZOrder::PIXEL,
        mass: 1, # Default mass for a pixel.
    }.merge! options

    super(options)

    self.x, self.y = random_position unless options[:x] and options[:y]

    @glow = Image["pixel_glow.png"]

    @last_health = @health = INITIAL_HEALTH
    @amount_to_heal = max_health - INITIAL_HEALTH
    @amount_left_to_heal = @amount_to_heal
    self.health = health # get correct colour shown.

    @played_hurt_at = 0
    init_physics(options[:mass])

    parent.add_pixel self

    on_spawn
  end

  def random_position
    # Gradually reduce the minimum spawn distance, in case objects are pushed a bit too close.
    (0..128).step(4) do |distance_reduction|
      # Try several random positions before trying with a reduced safe distance.
      100.times do
        x, y = rand($window.width - SIZE * 2) + SIZE, rand($window.height - SIZE * 2) + SIZE
        if parent.pixels.all? {|p| distance(x, y, p.x, p.y) > (p.safe_distance - distance_reduction) }
          return [x, y]
        end
      end
    end
  end

  def init_physics(mass)
    body = CP::Body.new(mass * 100, Float::INFINITY)

    vertices = [CP::Vec2.new(-width / 2, -height / 2), CP::Vec2.new(-width / 2, height / 2), CP::Vec2.new(width / 2, height / 2), CP::Vec2.new(width / 2, -height / 2)]
    @shape = CP::Shape::Poly.new(body, vertices, CP::Vec2.new(0,0))
    @shape.body.p = CP::Vec2.new(x, y)
    @shape.collision_type = Pixel
    @shape.object = self

    @space.add_body @shape.body
    @space.add_shape @shape
  end

  def on_spawn
    # By default, do nothing.
  end

  def health=(value)
    return if @health == 0

    play_hurt if value < @health

    @health = [[0, value].max, max_health].min
    self.alpha = (@health * 155.0 / max_health) + 100

    die if @health == 0
  end

  def update
    @shape.body.reset_forces unless controlled?

    super

    self.health += auto_heal

    @last_health = @health
    
    self.x, self.y = @shape.body.p.x, @shape.body.p.y
  end

  def draw
    glow_diameter = 0.4 + 0.8 * @health / max_health
    @glow.draw_rot(x, y, zorder + 1, 0, 0.5, 0.5, glow_diameter, glow_diameter, glow_color, :additive)
    super
  end

  def die
    # Fall apart.
    half_width = width / 2
    ((x - half_width)...(x + half_width)).step(width / 4) do |x|
      ((y - half_width)...(y + half_width)).step(width / 4) do |y|
        PixelFragment.new(intensity, x: x, y: y, color: color)
      end
    end

    @shape.object = nil
    @space.remove_shape @shape
    @space.remove_body @shape.body
    @space = @shape = nil

    parent.remove_pixel self

    destroy
  end

  def hurts?(enemy)
    enemy.class != self.class
  end

  def fight(enemy)
    if enemy.player?
      enemy.fight self # Give priority to the player.
    elsif enemy.boss? and not (self.boss? or self.player?)
      enemy.fight self # Give priority to a boss, unless I am one.
    elsif hurts?(enemy)
      self.health -= enemy.damage * parent.class::PHYSICS_STEP
      enemy.health -= damage * parent.class::PHYSICS_STEP

      fragment_color = [color, enemy.color].sample
      spark(fragment_color, x - (x - enemy.x) / 2, y - (y - enemy.y) / 2)
    end
  end

  def move(right, down)
    push(x + right, y + down, force)
  end

  # Push towards a particular position (negative force to pull).
  def push(x, y, push_force)
    angle = Gosu::angle(self.x, self.y, x, y)
    distance = distance(self.x, self.y, x, y)
    x_offset = offset_x(angle, distance)
    y_offset = offset_y(angle, distance)

    @shape.body.apply_force(CP::Vec2.new((x_offset / distance) * push_force * 20000, (y_offset / distance) * push_force * 20000),
                            CP::Vec2.new(0, 0))
  end

  def spark(color, x, y)
    PixelFragment.generate(parent.class::PHYSICS_STEP, intensity, x: x, y: y, color: color)
  end

  def hit_wall(wall)
    # Ensure you don't get wounded multiple times.
    damage = wall.damage * parent.class::PHYSICS_STEP
    self.health = [last_health - damage, health].min

    x_pos, y_pos = case wall.side
      when :left then [x - SIZE / 2, y]
      when :right then [x + SIZE / 2, y]
      when :top then [x, y - SIZE / 2]
      when :bottom then [x, y + SIZE / 2]
    end

    spark(color, x_pos, y_pos)
  end
end