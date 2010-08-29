require 'pixel'

class DeadPixel < Pixel
  MAX_HEALTH = 5000
  
  def initialize(options = {})
    options = {
            :color => Color.new(255, 0, 180, 0)
    }.merge! options
    super(MAX_HEALTH, options)
    
    @damage = 0.5

    shape.body.mass *= 10 # Dead pixels are a lot harder to push around.
  end

  def safe_distance
    SIZE * 2
  end

  def fight(other)
    other.fight(self)
  end
end
