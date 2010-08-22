class Pixel < GameObject
  trait :bounding_box, :debug => false, :scale => 0.25
  traits :collision_detection, :retrofy

  SIZE = 8

  attr_reader :health, :damage, :max_health, :last_health

  def initialize(options = {})
    options = {:image => Image["pixel.png"]}.merge! options
    super(options)
  end

  def health=(value)
    @health = [[0, value].max, max_health].min
    self.alpha = ((@health * 155.0 / max_health) + 100).to_i
    die if @health == 0
  end

  def update
    super
    @last_health = @health
  end

  def die
    # Fall apart.
    half_width = width / (2 * $window.factor)
    ((x - half_width)...(x + half_width)).step(width / (4 * $window.factor)) do |x|
      ((y - half_width)...(y + half_width)).step(width / (4 * $window.factor)) do |y|
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
      self.health -= enemy.damage if health == last_health
      enemy.health -= damage if enemy.health == enemy.last_health
      @hurt.play
    end
  end

  def colliding_with_obstacle?
    each_bounding_box_collision(Player, Enemy, DeadPixel) do |me, obstacle|
      return obstacle if me != obstacle
    end
    return nil
  end

  def left
    self.x = [x - @speed, 0 + screen_width / 8].max
    if enemy = colliding_with_obstacle? then self.x = enemy.x + SIZE + 0.001; fight(enemy); end
  end

  def right
    self.x = [x + @speed, $window.width / $window.factor - screen_width / 8].min
    if enemy = colliding_with_obstacle? then self.x = enemy.x - SIZE - 0.001; fight(enemy); end
  end

  def up
    self.y = [y - @speed, 0 + screen_width / 8].max
    if enemy = colliding_with_obstacle? then self.y = enemy.y + SIZE + 0.001; fight(enemy); end
  end

  def down
    self.y = [y + @speed, $window.height / $window.factor - screen_width / 8].min
    if enemy = colliding_with_obstacle? then self.y = enemy.y - SIZE - 0.001; fight(enemy); end
  end
end