require 'enemy'

class Boss < Enemy
  def control_cost; 15; end
  def max_health; 1000; end
  def kill_score; 10000; end
  def damage; 25; end
  def speed; 5; end
  def num_kills; 1000; end # Always ends the level.
  def initial_color; Color.new(255, 255, 255, 0); end

  def initialize(space, options = {})
    super space, options

    shape.body.mass *= 4
  end
end