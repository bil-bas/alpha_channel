require_relative 'boss'

class TheAntiPixel < Boss
  ATTRACTION_RANGE = 200
  ATTRACTION_FORCE = 0.4

  def control_cost; 100; end # Uncontrollable.
  def max_health; 30000; end
  def kill_score; 25000; end
  def damage; 300; end
  def force; 1; end
  def initial_color; Color.rgba(0, 0, 0, 0); end
  def intensity; 0.5; end
  def solid?; false; end
  def play_hurt; ;end # Stop too much grinding as we eat.

  # Appears black, glows white.
  def glow_color
    color = Color::WHITE.dup
    color.alpha = self.color.alpha
    color
  end

  def boss_update
    # Pull all nearby pixels in closer.
    parent.pixels.each do |pixel|
      distance = distance_to(pixel)
      if pixel != self and (1..ATTRACTION_RANGE).include? distance
        force = ATTRACTION_FORCE * (ATTRACTION_RANGE / distance)
        force *= 10 if pixel.is_a? DeadPixel # Make sure you can pull these heavies.
        pixel.push(x, y, force)
      end
    end
  end
end