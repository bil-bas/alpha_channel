class Pixel < GameObject
  INITIAL_HEALTH = 10
  PHASE_IN_DURATION = 3 * 1000 # Number of ms to phase in over.
  SIZE = 32

  def solid?; true; end
  def safe_distance; SIZE * 2; end
  def glow_color
    glow = color.dup
    glow.alpha = (color.alpha * intensity).to_i
    glow
  end

  attr_reader :health, :last_health
  
  attr_reader :shape

  def initialize(space, options = {})
    @space = space

    @@image ||=  TexPlay.create_image($window, SIZE, SIZE, :color => :white)

    make_glow unless defined? @@glow

    options = {:image => @@image, :zorder => ZOrder::PIXEL}.merge! options
    super(options)

    @last_health = @health = INITIAL_HEALTH
    @amount_to_heal = max_health - INITIAL_HEALTH
    @amount_left_to_heal = @amount_to_heal
    self.health = health # get correct colour shown.

    body = CP::Body.new(100, Float::INFINITY)
    vertices = [CP::Vec2.new(-width / 2, -height / 2), CP::Vec2.new(-width / 2, height / 2), CP::Vec2.new(width / 2, height / 2), CP::Vec2.new(width / 2, -height / 2)]
    @shape = CP::Shape::Poly.new(body, vertices, CP::Vec2.new(0,0))
    @shape.body.p = CP::Vec2.new(x, y)
    @shape.collision_type = :pixel

    @space.add_body @shape.body
    @space.add_shape @shape

    on_spawn
  end

  def on_spawn
    # By default, do nothing.
  end

  def make_glow
    @@glow = TexPlay.create_image($window, @@image.width * 5, @@image.height * 5)

    #
    center = @@glow.width / 2
    radius =  @@glow.width / 2
    pixel_width = @@image.width / 2 # Radius of the pixel.
    pixel_radius = radius - pixel_width # Radius of the glow outside the pixel itself.

    @@glow.circle center, center, radius, :color => :white, :filled => true,
      :color_control => lambda {|source, dest, x, y|
        # Glow starts at the edge of the pixel (well, its radius, since glow is circular, not rectangular)
        distance = distance(center, center, x, y) - pixel_width
        dest[3] = (1 - (distance / pixel_radius)) ** 2
        dest
    }

    # Cut out the sprite itself, so we don't super-illuminate.
    edge = (@@glow.width - @@image.width) / 2
    @@glow.rect edge, edge, edge + @@image.width - 1, edge + @@image.height - 1,
                :fill => true, :color => :alpha
  end

  def health=(value)
    return if @health == 0

    @health = [[0, value].max, max_health].min
    self.alpha = ((@health * 155.0 / max_health) + 100).to_i
    die if @health == 0
  end

  def update
    super

    if @amount_left_to_heal > 0
      heal_amount = @amount_to_heal * $window.milliseconds_since_last_tick / PHASE_IN_DURATION
      self.health += heal_amount
      @amount_left_to_heal -= heal_amount
    end

    @last_health = @health
    
    self.x, self.y = @shape.body.p.x, @shape.body.p.y
  end

  def draw
    super
    @@glow.draw(x - @@glow.width / 2, y - @@glow.height / 2, zorder + 1, 1, 1, glow_color, :additive)
  end

  def die
    # Fall apart.
    half_width = width / 2
    ((x - half_width)...(x + half_width)).step(width / 4) do |x|
      ((y - half_width)...(y + half_width)).step(width / 4) do |y|
        PixelFragment.create(intensity, :x => x, :y => y, :color => color)
      end
    end

    @space.remove_shape @shape
    @space.remove_body @shape.body

    destroy
  end

  def hurts?(enemy)
    enemy.class != self.class
  end

  def fight(enemy)
    if enemy.is_a? Player
      enemy.fight self # Makes the sound right if the player is hit.
    elsif self.hurts?(enemy)
      self.health -= enemy.damage
      enemy.health -= damage

      @hurt.play(0.1)
      color = rand(100) < 50 ? self.color : enemy.color
      spark(color, x - (x - enemy.x) / 2, y - (y - enemy.y) / 2)
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
    unless $window.particles.size > 100
      PixelFragment.create(intensity, :x => x, :y => y, :color => color.dup, :scale_rate => -0.02)
    end
  end

  def hit_wall(wall)
    # Ensure you don't get wounded multiple times.
    self.health = [last_health - wall.damage, health].min

    @hurt.play(0.1)

    x_pos, y_pos = case wall.side
      when :left then [x - SIZE / 2, y]
      when :right then [x + SIZE / 2, y]
      when :top then [x, y - SIZE / 2]
      when :bottom then [x, y + SIZE / 2]
    end

    spark(color, x_pos, y_pos)
  end
end