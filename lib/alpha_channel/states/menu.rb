require_relative 'screen'

class Menu < Screen
  def initialize
    super

    @title_font = Font.create_for_os(FONT, 160)
    @info_font = Font.create_for_os(FONT, 36)

    on_input(KEYS[:help]) { push_game_state Help.new KEYS[:help] }

    on_input :space do
      push_game_state LevelTransition.new(Level::INITIAL_LEVEL)
    end
  end

  def draw
    super

    draw_background

    color = MAIN_TITLE_COLOR.dup
    color.alpha = Math::sin(milliseconds / 400.0) * 75 + 150
    write_text(@title_font, "ALPHA", 50, color)
    write_text(@title_font, "CHANNEL",  150, color)
    write_text(@info_font, "by Spooner",  260, color)

    write_text(@info_font, "High Score",  335, BACKGROUND_LABEL_COLOR)
    draw_high_score
    draw_scan_lines

    $window.flush

    write_text(@info_font, "(SPACE) to play", OPTIONS_Y, OPTIONS_COLOR)
  end
end