require 'enemy'

class Boss < Enemy
  FEAR_RANGE = 100
  FEAR_FORCE = 1

  def control_cost; $window.current_game_state.level / 2 + 5; end
  def max_health; 1000; end
  def kill_score; $window.current_game_state.level * 1000; end
  def damage; $window.current_game_state.level + 10; end
  def force; 4.5; end
  def num_kills; 1000; end # Always ends the level.
  def initial_color; Color.new(255, 255, 255, 0); end
  def intensity; 0.7; end

  def initialize(space, options = {})
    super space, options

    shape.body.mass *= 4
  end

  def on_spawn
    Sample["boss_spawn.wav"].play(0.4)
  end

  def die
    $window.lives += 1
    super
  end

  def update
    super
    boss_update
  end

  def boss_update
    Enemy.all.each do |pixel|
     if pixel != self and not pixel.controlled? and distance_to(pixel) < FEAR_RANGE
        pixel.push(x, y, - FEAR_FORCE * (FEAR_RANGE / distance_to(pixel)))
      end
    end
  end
end