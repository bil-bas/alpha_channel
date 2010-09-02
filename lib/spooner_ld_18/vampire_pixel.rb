require 'boss'
class VampirePixel < Boss
  def max_health; 400; end
  def kill_score; 2000; end
  def initial_color; Color.new(255, 0, 150, 150); end
  def intensity; 0.5; end
  def damage; 15; end

  def auto_heal; 3; end

  def boss_update
    # Nothing special.
  end

  def fight(pixel)
    # Turn any pixel killed into a vampire, unless a player or controlled.
    pixel_controlled = pixel.controlled?

    super

    if pixel.health == 0 and not pixel.is_a? Player  and not pixel_controlled
      vampire = self.class.create(@space, :x => pixel.x, :y => pixel.y)
      vampire.health = max_health / 2 # Start a bit stronger, so they don't instantly die
    end
  end
end