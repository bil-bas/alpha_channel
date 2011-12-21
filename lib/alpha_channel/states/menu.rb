require_relative 'screen'

class Menu < Screen
  trait :timer

  def initialize
    super

    on_input(KEYS[:help]) { push_game_state Help.new(KEYS[:help]), finalize: false }

    on_input [:p, :space] do
      push_game_state LevelTransition.new(Level::INITIAL_LEVEL)
    end

    on_input :s do
      push_game_state HighScores
    end

    on_input :q do
      $window.close
    end

    $window.difficulties.each_with_index do |difficulty, i|
      on_input (i + 1).to_s.to_sym do
        $window.difficulty = difficulty
      end
    end

    @title = Image["title.png"]

    update_title

    every(100) { update_title }
  end

  def update_title
    @title.clear dest_ignore: :transparent,
        color_control: proc {|c, x, y|
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

    write_text(@@info_font, "by Spooner",  260, BACKGROUND_LABEL_COLOR)

    write_text(@@info_font, "(1) Easy - (2) Normal - (3) Hard", 305, OPTIONS_COLOR, zorder: ZOrder::GUI)

    draw_high_score
    draw_scan_lines

    write_text(@@info_font, "(P)lay - (S)cores - (Q)uit", OPTIONS_Y, OPTIONS_COLOR, zorder: ZOrder::GUI)
  end
end