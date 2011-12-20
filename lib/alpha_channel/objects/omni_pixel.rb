require_relative 'boss'

class OmniPixel < ShooterPixel
  NUM_LIVES = 3
  
  # First life is slow, second is faster.
  def force; super * (@lives == NUM_LIVES ? 1 : 1.5); end
  def max_health; (@lives == NUM_LIVES ? 200 : 500); end
  def damage; (@lives == NUM_LIVES ? 120 : 480); end

  def initial_color; Color::WHITE; end
  def glow_color
    glow = super
    glow.red = Math.sin(milliseconds / 500.0) * 100 + 155
    glow.green = Math.sin(milliseconds / 600.0) * 100 + 155
    glow.blue = Math.sin(milliseconds / 700.0) * 100 + 155
    glow
  end

  def initialize(space, options = {})
    @lives = options[:lives] || NUM_LIVES
    super(space, options)
  end

  # N lives as omni, then respawn as anti.
  def die
    @lives -= 1
    if @lives > 0
      if @lives > 1      
        self.class.new(@space, lives: @lives)
      else
        TheAntiPixel.new(@space)
      end
    end

    super
  end
end