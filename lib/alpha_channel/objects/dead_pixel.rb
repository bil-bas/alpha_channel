require_relative 'enemy'

class DeadPixel < Enemy
  def max_health; 10000; end
  def damage; 30; end
  def force; controlled? ? 18 : 0; end
  def num_kills; 0; end
  def initial_color; Color.rgb(0, 255, 0); end
  def control_cost; 10; end
  def intensity; 0.2; end
  
  def initialize(space, options = {})
    options = {
        mass: 10, # Dead pixels are a lot harder to push around.
    }.merge! options

    super(space, options)
  end

  def on_spawn
    # Do nothing
  end
end
