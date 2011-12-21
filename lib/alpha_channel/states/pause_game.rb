require_relative "overlay"

class PauseGame < Overlay
  def initialize(inputs)
    super inputs

    @font = Gosu::Font.new($window, FONT, 80)

    on_input :q do
      game_state_manager.pop_until_game_state Menu
    end
  end

  def draw
    super

    write_text(@font, "PAUSED", ($window.height - @font.height) / 2, GAME_OVER_COLOR, zorder: ZOrder::GUI)

    write_text(@@info_font, "(Q)uit to menu", OPTIONS_Y, OPTIONS_COLOR, zorder: ZOrder::GUI)

  end
end