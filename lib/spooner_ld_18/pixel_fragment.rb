class PixelFragment < Particle
  traits :velocity

  def initialize(options = {})
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
    @@glow = TexPlay.create_image($window, @@image.width * 9, @@image.height * 9, :color => :white)

    center = @@glow.width / 2
    radius =  @@glow.width / 2

    @@glow.each do |c, x, y|
      distance = distance(center, center, x, y)
      c[3] = if distance > radius
        0
      else
        (1 - Math.sin(distance / radius * Math::PI / 2)) / 8
      end
    end
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
    @@glow.draw(x - @@glow.width / 2, y - @@glow.height / 2, zorder + 1, 1, 1, color, :additive)
  end
end