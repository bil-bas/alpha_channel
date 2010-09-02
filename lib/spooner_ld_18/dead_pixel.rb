require 'enemy'

class DeadPixel < Enemy
  def max_health; 5000; end
  def damage; 0.5; end
  def force; controlled? ? 42 : 0; end
  def num_kills; 0; end
  def initial_color; Color.new(255, 0, 255, 0); end
  def control_cost; 10; end
  def intensity; 0.2; end
  
  def initialize(space, options = {})
    super(space, options)

    shape.body.mass *= 100 # Dead pixels are a lot harder to push around.
  end

  def on_spawn
    # Do nothing
  end
end
