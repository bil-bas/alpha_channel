require_relative 'boss'

class OmniPixel < ShooterPixel
  NUM_LIVES = 3
  
  # First life is slow, second is faster.
  def force; super * (@lives == NUM_LIVES ? 1 : 1.5); end
  def max_health; (@lives == NUM_LIVES ? 200 : 500); end
  def damage; (@lives == NUM_LIVES ? 2 : 8); end

  def initial_color; Color::WHITE; end
  def glow_color
    glow = super
    glow.red = (Math.sin($window.ms / 500.0) * 100).to_i + 155
    glow.green = (Math.sin($window.ms / 600.0) * 100).to_i + 155
    glow.blue = (Math.sin($window.ms / 700.0) * 100).to_i + 155
    glow
  end

  def initialize(space, options = {})
    @lives = options[:lives] || NUM_LIVES
    super
  end

  # N lives as omni, then respawn as anti.
  def die
    super
    @lives -= 1
    if @lives > 0
      x, y = $window.random_position
      if @lives > 1      
        self.class.create(@space, :lives => @lives, :x => x, :y => y)
      else
        TheAntiPixel.create(@space, :x => x, :y => y)
      end
    end
  end
end