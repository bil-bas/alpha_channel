#Patch to allow the creation of fonts to scale correctly across OS.
class Gosu::Font
  TEXT_TO_MEASURE = "8888888888"
  WIDTH_ON_WINDOWS = 650.0
  def self.create_for_os(font, size)
    relative = WIDTH_ON_WINDOWS / Font.new($window, font, 120).text_width(TEXT_TO_MEASURE)

    new($window, font, (size * relative).round)
  end
end