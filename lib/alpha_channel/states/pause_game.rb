require_relative "overlay"

class PauseGame < Overlay
  def initialize(inputs)
    super inputs

    @font = Gosu::Font.new($window, FONT, 80)
  end

  def draw
    super

    write_text(@font, "PAUSED", ($window.height - @font.height) / 2, GAME_OVER_COLOR, zorder: ZOrder::GUI)
  end
end