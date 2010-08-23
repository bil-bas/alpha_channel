class PixelFragment < Particle
  traits :retrofy, :velocity

  def initialize(options = {})
    x = rand 360
    velocity_x, velocity_y = Math.cos(x), Math.sin(x)
    options = {
      :velocity_x => velocity_x * (0.2 + rand(0.1)),
      :velocity_y => velocity_y * (0.2 + rand(0.1)),
      :zorder => ZOrder::PARTICLES,
      :image => Image["pixel_fragment.png"],
      :scale_rate => -0.1,
      :fade_rate => 0,
      :rotation_rate => 1 - rand(2),
      :mode => :default
    }.merge! options

    $window.add_particle self

    super options
  end

  def update
    super

    destroy if outside_window? or factor_x <= 0.1
  end

  def destroy
    $window.remove_particle self
    super
  end
end