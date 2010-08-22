class LevelTransition < GameStates::FadeTo
  def initialize(level)
    super(Level.new(level), :speed => 3)
  end

  # Ensure that particles keep moving.
  def update
    super
    $window.particles.each { |x| x.update_trait }
  end
end