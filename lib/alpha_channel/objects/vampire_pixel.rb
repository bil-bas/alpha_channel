require_relative 'boss'

class VampirePixel < Boss
  def max_health; 400; end
  def kill_score; 2000; end
  def initial_color; Color.rgb(0, 150, 150); end
  def intensity; 0.5; end
  def damage; 900; end

  def auto_heal; 300 * $window.frame_time; end

  def boss_update
    # Nothing special.a
  end

  def fight(pixel)
    # Turn any pixel killed into a vampire, unless a player or controlled.
    pixel_controlled = pixel.controlled?

    super

    # If the other pixel dies and we are still alive, then create a vampire in its stead!
    if alive? and pixel.dead? and not pixel.player? and not (controlled? or pixel_controlled)
      vampire = self.class.new(@space, x: pixel.x, y: pixel.y)
      vampire.health = max_health / 2 # Start a bit stronger, so they don't instantly die
    end
  end
end