require_relative 'enemy'

class Boss < Enemy
  FEAR_RANGE = 100
  FEAR_FORCE = 1

  def control_cost; 15; end
  def max_health; 1000; end
  def kill_score; 5000; end
  def damage; 1200; end
  def force; 4.5; end
  def num_kills; 1000; end # Always ends the level.
  def initial_color; Color.rgb(255, 255, 0); end
  def intensity; 0.7; end
  def boss?; true; end

  def initialize(space, options = {})
    options = {
        mass: 4,
    }.merge! options
    super space, options
  end

  def on_spawn
    Sample["boss_spawn.ogg"].play(0.4)
  end

  def update
    super
    boss_update
  end

  def boss_update
    (parent.pixels - [parent.player]).each do |pixel|
     if pixel != self and not controlled? and not pixel.controlled? and distance_to(pixel) < FEAR_RANGE
        pixel.push(x, y, - FEAR_FORCE * (FEAR_RANGE / distance_to(pixel)))
      end
    end
  end
end