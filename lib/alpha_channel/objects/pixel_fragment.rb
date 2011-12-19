# A particle uses simplified physics and spins off for a little while before disappearing.
class PixelFragment < GameObject
  SCALE_RATE = 0.5

  class << self
    # #generate will create particles based on FPS. #new will always do it.
    def generate(elapsed, *args)
      particles_per_second = case fps.div 10
                               when 0    then 5
                               when 1..2 then 15
                               when 3..4 then 25
                               else
                                 40
                             end

      new(*args) if rand() < (particles_per_second * elapsed)
    end
  end

  def initialize(intensity, options = {})
    @intensity = intensity * 0.6
    
    @@image ||= TexPlay.create_image($window, Pixel::SIZE / 4, Pixel::SIZE / 4, :color => :white)
    make_glow unless defined? @@glow

    angle = rand 360
    @velocity_x = Math.cos(angle) * (48 + rand(24))
    @velocity_y = Math.sin(angle) * (48 + rand(24))

    @rotation_rate = 120 - rand(240)

    options = {
      zorder: ZOrder::PARTICLES,
      image: @@image,
      mode: :default,
    }.merge! options

    super options

    parent.add_particle self
  end

  def make_glow
    @@glow = TexPlay.create_image($window, @@image.width * 10, @@image.height * 10)
    @@glow.refresh_cache
    @@glow.clear

    center = @@glow.width / 2
    radius =  @@glow.width / 2

    @@glow.circle center, center, radius, color: :white, filled: true,
        color_control: lambda {|source, dest, x, y|
          distance = distance(center, center, x, y)
          dest[3] = ((1 - (distance / radius)) ** 2) / 8.0
          dest
        }
  end

  def update
    super

    frame_time = $window.frame_time

    self.x += @velocity_x * frame_time
    self.y += @velocity_y * frame_time
    self.factor = factor_x - SCALE_RATE * frame_time
    self.angle += @rotation_rate * frame_time

    destroy if outside_window? or factor_x <= 0
  end

  def destroy
    parent.remove_particle self
    super
  end

  def draw
    super
    color = self.color.dup
    color.alpha = (color.alpha * @intensity).to_i
    @@glow.draw_rot(x, y, zorder + 0.01, 0, 0.5, 0.5, 1, 1, color, :additive)
  end
end