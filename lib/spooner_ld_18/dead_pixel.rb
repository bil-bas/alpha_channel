require 'pixel'

class DeadPixel < Pixel
  def initialize(options = {})
    super({:color => Color.new(255, 0, 180, 0)}.merge! options )
    @original_health = @max_health = @health = 5000
    @damage = 0.5
  end

  def safe_distance
    SIZE * 2
  end
end
