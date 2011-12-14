require_relative 'screen'

class Menu < Screen
  trait :timer

  def initialize
    super

    @title_font = Font.create_for_os(FONT, 8)
    @info_font = Font.create_for_os(FONT, 36)

    on_input(KEYS[:help]) { push_game_state Help.new(KEYS[:help]), finalize: false }

    on_input :space do
      push_game_state LevelTransition.new(Level::INITIAL_LEVEL)
    end

    @original_title = Image["title.png"]

    create_title

    every(100) { create_title }
  end

  def create_title
    @title = @original_title.dup
    @title.clear dest_select: :white, color_control: proc {|c, x, y|
      alpha = Math::sin(milliseconds / 250.0 + 100 * y) * 0.07 +
          rand() * 0.05 + rand() * 0.05 +
          0.2
      [0, 255, 0, alpha]
    }
  end

  def draw
    super

    draw_background

    @title.draw_rot $window.width / 2, 20, 0, 0, 0.5, 0, 18, 18

    write_text(@info_font, "by Spooner",  260, BACKGROUND_LABEL_COLOR)

    write_text(@info_font, "High Score",  335, BACKGROUND_LABEL_COLOR)
    draw_high_score
    draw_scan_lines

    $window.flush

    write_text(@info_font, "(SPACE) to play", OPTIONS_Y, OPTIONS_COLOR)
  end
end