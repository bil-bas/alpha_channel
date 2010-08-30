class PauseGame < GameStates::Pause
  def initialize
    super
    @font = Gosu::Font.new($window, FONT, 24)
  end
end