require_relative "overlay"

class Help < Overlay
  TEXT = YAML::load_file(File.expand_path("help.txt", File.dirname(__FILE__)))

  HEADING_COLOR = Color.rgb(0x88, 0xbb, 0x88)

  HEADING_Y = 0
  BODY_Y = HEADING_Y + 90

  LEFT_INDENT = 15
  def initialize(inputs)
    super inputs

    @pages = TEXT[:pages].map.with_index do |data, i|
      [
          Text.new("#{i.succ}) #{data[:heading]}", x: LEFT_INDENT, y: HEADING_Y, align: :left, size: 75, zorder: ZOrder::GUI,
                   color: HEADING_COLOR),
          Text.new(colorize(data[:body]), x: LEFT_INDENT, y: BODY_Y, align: :left, size: 22, zorder: ZOrder::GUI,
                   color: GAME_OVER_COLOR)
      ]
    end

    @pages.size.times do |i|
      on_input i.succ.to_s.to_sym do
        @current_page = i
      end
    end

    on_input [:b, :escape] do
      pop_game_state
    end

    @current_page = 0
  end

  def colorize(text)
    text.gsub(/(blueness|blue)/i, '<c=4444ff>\1</c>')
        .gsub(/(green)/i,         '<c=00ff00>\1</c>')
        .gsub(/(red)/i,           '<c=ff0000>\1</c>')
        .gsub(/(yellow)/i,        '<c=ffff00>\1</c>')
        .gsub(/(cyan)/i,          '<c=00ffff>\1</c>')
        .gsub(/(magenta)/i,       '<c=ff00ff>\1</c>')
        .gsub(/(black)/i,         '<c=333333>\1</c>')
        .gsub(/(white)/i,         '<c=ffffff>\1</c>')
  end

  def draw
    super
    @pages[@current_page].each(&:draw)

    write_text(@@info_font, "Page (1/2/3) - (B)ack", OPTIONS_Y, OPTIONS_COLOR, zorder: ZOrder::GUI)
  end
end