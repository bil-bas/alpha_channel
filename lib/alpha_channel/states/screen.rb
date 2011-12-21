class Screen < GameState
  BACKGROUND_LABEL_COLOR = Color.rgb(0, 65, 0)
  SCAN_LINES_COLOR = Color.rgb(0, 0, 0)
  BACKGROUND_COLOR = Color.rgb(0, 40, 0)
  OPTIONS_COLOR = Color.rgb(125, 150, 125)
  MAIN_TITLE_COLOR =  Color.rgb(0, 120, 0)
  GAME_OVER_COLOR = Color.rgb(175, 225, 175)

  OPTIONS_Y = 430

  def initialize(*args)
    super(*args)
    @@score_font ||= Font.create_for_os(FONT, 120)
    @@info_font ||= Font.create_for_os(FONT, 36)
  end

  def write_text(font, text, y, color, options = {})
    options = {
        zorder: ZOrder::LABEL,
    }.merge! options

    x = ($window.width - font.text_width(text)) / 2
    font.draw(text, x, y, options[:zorder], 1, 1, color)
  end

  def draw_background
    $window.pixel.draw 0, 0, ZOrder::BACKGROUND, $window.width, $window.height, BACKGROUND_COLOR
  end

  def draw_scan_lines
    @@scan_lines ||= $window.record(1, 1) do
      (0..$window.height).step(4) do |y|
        $window.pixel.draw 0, y, 0, $window.width, 1, SCAN_LINES_COLOR
      end

      @corner = Image["corner.png"]
      @offset = @corner.width / 2
      @corner.draw_rot $window.width - @offset, $window.height - @offset, 0, 0, 0.5, 0.5
      @corner.draw_rot @offset, $window.height - @offset, 0, 90, 0.5, 0.5
      @corner.draw_rot @offset, @offset, 0, 180, 0.5, 0.5
      @corner.draw_rot $window.width - @offset, @offset, 0, 270, 0.5, 0.5
    end

    @@scan_lines.draw 0, 0, ZOrder::SCAN_LINES
  end

  def draw_high_score
    write_text(@@info_font, $window.difficulty,  335, BACKGROUND_LABEL_COLOR)
    write_text(@@score_font, "%08d" % $window.high_score, 344, BACKGROUND_LABEL_COLOR)
  end
end