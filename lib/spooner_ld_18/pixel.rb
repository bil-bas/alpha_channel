class Pixel < GameObject
  INITIAL_HEALTH = 10
  PHASE_IN_DURATION = 3 * 1000 # Number of ms to phase in over.
  SIZE = 32

  attr_reader :health, :damage, :max_health, :last_health
  
  attr_reader :shape

  def initialize(max_health, options = {})
    @@image ||=  TexPlay.create_image($window, SIZE, SIZE, :color => :white)
    options = {:image => @@image, :zorder => ZOrder::PIXEL}.merge! options
    super(options)

    @max_health = max_health
    @last_health = @health = INITIAL_HEALTH
    @amount_to_heal = @max_health - INITIAL_HEALTH
    @amount_left_to_heal = @amount_to_heal
    self.health = health # get correct colour shown.

    body = CP::Body.new(100, 1000000)
    vertices = [CP::Vec2.new(-width / 2, -height / 2), CP::Vec2.new(-width / 2, height / 2), CP::Vec2.new(width / 2, height / 2), CP::Vec2.new(width / 2, -height / 2)]
    @shape = CP::Shape::Poly.new(body, vertices, CP::Vec2.new(0,0))
    @shape.body.p = CP::Vec2.new(x, y)
    @shape.collision_type = :pixel
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

  def die
    # Fall apart.
    half_width = width / 2
    ((x - half_width)...(x + half_width)).step(width / 4) do |x|
      ((y - half_width)...(y + half_width)).step(width / 4) do |y|
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
      # Ensure you don't get wounded multiple times.
      self.health = [last_health - enemy.damage, health].min
      enemy.health = [enemy.last_health - damage, enemy.health].min
           
      if rand(100) < 10
        @hurt.play(0.1)
        color = rand(100) < 50 ? self.color : enemy.color
        unless $window.particles.size > 100
          PixelFragment.create(:x => x - (x - enemy.x) / 2, :y => y - (y - enemy.y) / 2, :color => color.dup, :scale_rate => -0.02)
        end
      end
    end
  end

  def move(x, y)
    @shape.body.reset_forces
    @shape.body.apply_force(CP::Vec2.new(x * @speed * 20000, y * @speed * 20000), CP::Vec2.new(0, 0))
  end
end