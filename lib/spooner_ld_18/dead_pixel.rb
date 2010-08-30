require 'enemy'

class DeadPixel < Enemy
  def max_health; 5000; end
  def damage; 0.5; end
  def speed; controlled? ? 100 : 0; end
  def num_kills; 0; end
  def initial_color; Color.new(255, 0, 255, 0); end
  
  def initialize(space, options = {})
    super(space, options)

    shape.body.mass *= 100 # Dead pixels are a lot harder to push around.
  end

  def fight(other)
    other.fight(self)
  end
end
