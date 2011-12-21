require_relative "screen"

class HighScores < Screen
  def initialize
    super

    @difficulty = $window.difficulty
    @online = true

    @title_font = Font.create_for_os(FONT, 70)
    @score_font = Font.create_for_os(FONT, 24)

    $window.difficulties.each_with_index do |difficulty, i|
      on_input (i + 1).to_s.to_sym do
        @difficulty = difficulty
      end
    end
    on_input :o do
      @online = true
    end

    on_input :l do
      @online = false
    end

    on_input [:b, :escape] do
      pop_game_state
    end
  end

  def draw
    super

    draw_background
    draw_scan_lines

    write_text(@title_font, "#{@difficulty} - #{@online ? "online" : "local"}", 0, BACKGROUND_LABEL_COLOR)

    scores = @online ? $window.online_high_scores(@difficulty) : $window.offline_high_scores(@difficulty)
    20.times do |i|
      y = 60 + i * 14.5
      @score_font.draw "#{i.succ.to_s.rjust(2, '0')}", 100, y, ZOrder::LABEL, 1, 1, BACKGROUND_LABEL_COLOR

      if scores[i]
        score = scores[i]
        label = "#{score[:score].to_s.rjust(Level::MAX_SCORE_WIDTH, '0')}    #{score[:name].rjust(EnterName::MAX_NAME_LENGTH)}  -  #{score[:text]}"
        @score_font.draw label, 140, y, ZOrder::LABEL, 1, 1, BACKGROUND_LABEL_COLOR
      end
    end

    write_text(@@info_font, "(O)nline - (L)ocal", OPTIONS_Y - 70, OPTIONS_COLOR, zorder: ZOrder::GUI)
    write_text(@@info_font, "(1) Easy - (2) Normal - (3) Hard", OPTIONS_Y - 35, OPTIONS_COLOR, zorder: ZOrder::GUI)
    write_text(@@info_font, "(B)ack", OPTIONS_Y, OPTIONS_COLOR, zorder: ZOrder::GUI)
  end
end