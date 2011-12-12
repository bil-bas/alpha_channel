class PixelFragment < Particle
  traits :velocity

  def initialize(intensity, options = {})
    @intensity = intensity
    
    @@image ||= TexPlay.create_image($window, Pixel::SIZE / 4, Pixel::SIZE / 4, :color => :white)
    make_glow unless defined? @@glow

    x = rand 360
    velocity_x, velocity_y = Math.cos(x), Math.sin(x)
    options = {
      :velocity_x => velocity_x * (0.8 + rand(0.4)),
      :velocity_y => velocity_y * (0.8 + rand(0.4)),
      :zorder => ZOrder::PARTICLES,
      :image => @@image,
      :scale_rate => -0.005,
      :fade_rate => 0,
      :rotation_rate => 2 - rand(4),
      :mode => :default
    }.merge! options

    $window.add_particle self

    super options
  end

  def make_glow
    @@glow = TexPlay.create_image($window, @@image.width * 10, @@image.height * 10)
    @@glow.refresh_cache
    @@glow.clear

    center = @@glow.width / 2
    radius =  @@glow.width / 2

    @@glow.circle center, center, radius, :color => :white, :filled => true,
      :color_control => lambda {|source, dest, x, y|
        distance = distance(center, center, x, y)
        dest[3] = ((1 - (distance / radius)) ** 2) / 8.0
        dest
      }
  end

  def update
    super

    destroy if outside_window? or factor_x <= 0
  end

  def destroy
    $window.remove_particle self
    super
  end

  def draw
    super
    color = self.color.dup
    color.alpha = (color.alpha * @intensity).to_i
    @@glow.draw(x - @@glow.width / 2, y - @@glow.height / 2, zorder + 0.01, 1, 1, color, :additive)
  end
end