class LevelTransition < GameStates::FadeTo
  def initialize(level, options = {})
    options = { :died => false }.merge! options
    
    super(Level.new(level, options), :speed => 3)

    @@sound ||= Sample["level.wav"]
    @@sound.play(0.5) unless options[:died]
  end

  # Ensure that particles keep moving.
  def update
    super
    $window.particles.each { |x| x.update_trait; x.update }
  end
end