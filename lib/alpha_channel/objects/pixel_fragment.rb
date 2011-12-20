# A particle uses simplified physics and spins off for a little while before disappearing.
class PixelFragment < GameObject
  SIZE = 8
  SCALE_RATE = SIZE / 1.5 # So it takes 1.5s to decay.

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
    
    @glow = Image["fragment_glow.png"]

    angle = rand 360
    @velocity_x = Math.cos(angle) * (48 + rand(24))
    @velocity_y = Math.sin(angle) * (48 + rand(24))

    @rotation_rate = 120 - rand(240)

    options = {
      zorder: ZOrder::PARTICLES,
      image: $window.pixel,
      factor: SIZE,
      mode: :default,
    }.merge! options

    super options

    parent.add_particle self
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
    @glow.draw_rot(x, y, zorder + 0.01, 0, 0.5, 0.5, 1, 1, color, :additive)
  end
end