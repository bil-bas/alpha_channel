class PixelFragment < Particle
  traits :velocity

  def initialize(options = {})
    @@image ||= TexPlay.create_image($window, Pixel::SIZE / 4, Pixel::SIZE / 4, :color => :white)

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

  def update
    super

    destroy if outside_window? or factor_x <= 0
  end

  def destroy
    $window.remove_particle self
    super
  end
end