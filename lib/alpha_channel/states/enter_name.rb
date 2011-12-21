class EnterName < Fidgit::GuiState
  MAX_NAME_LENGTH = 8
  CARET_COLOR = Color.rgba(0, 175, 0, 150)

  def initialize
    super()

    vertical align: :center do
      label "Enter name:", font_name: FONT, font_height: 60, color: Screen::GAME_OVER_COLOR

      horizontal padding: 0, spacing: 0, align: :center do
        label "> ", font_name: FONT, font_height: 60, color: Screen::GAME_OVER_COLOR

        @name = text_area background_color: Color::NONE,
                          font_name: FONT, font_height: 80, height: 70, width: 500,
                          caret_color: CARET_COLOR do |area, text|
          filtered = text.strip.gsub(/[^a-z_\d]/i, '').upcase[0...MAX_NAME_LENGTH]
          area.text = filtered unless text == filtered
        end
      end
    end

    on_input [:enter, :return] do
      unless @name.text.empty?
        $window.add_high_score @name.text
        pop_game_state
      end
    end
  end

  def update
    super
    @name.focus nil unless @name.focused?
  end

  def draw
    previous_game_state.previous_game_state.draw
    $window.flush
    super()
  end
end
